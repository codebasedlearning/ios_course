// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CoreNFC
import CblUI

/*
 This is the ISO 7816 sibling of NFCScreen: contactless bank/EMV cards do
 NOT speak NDEF (see NFCScreen.swift) - they speak ISO 7816 smart-card
 commands (APDUs) riding on top of ISO 14443. Same radio, different
 language.

 What this screen deliberately does NOT do: extract a card number, expiry
 date, or any other cardholder data. It sends exactly one APDU - the same
 one every contactless terminal sends first, SELECT "2PAY.SYS.DDF01", the
 EMV "Proximity Payment System Environment" (PPSE) directory - and shows
 you which payment scheme(s) the card advertises (e.g. "VISA DEBIT"), plus
 the tag's hardware UID and ATR historical bytes. That's roughly the same
 amount of information the card's printed logo already gives you, just
 read electronically. Going further (GET PROCESSING OPTIONS, READ RECORD,
 ...) is where you start touching real account data - out of scope for a
 "look, ISO 7816 exists" teaching example, mostly because at that point
 you're not building a demo anymore, you're building a skimmer.

 Setup needed beyond this file (already added to the project):
  - com.apple.developer.nfc.readersession.formats now also lists "TAG"
    (see SensorApp.entitlements)
  - Info.plist key com.apple.developer.nfc.readersession.iso7816.select-identifiers
    = ["325041592E5359532E4444463031"], the hex encoding of "2PAY.SYS.DDF01".
    This is the *only* AID this app is allowed to SELECT - the OS enforces
    the whitelist, we can't widen it from inside the app. (Added via an
    INFOPLIST_KEY_ build setting - see the comment next to it in the
    project for why that's the one part of this change worth double-
    checking yourself in Xcode's target "Info" tab.)

 Same device/account caveats as NFCScreen: needs a real iPhone 7+ with a
 paid Apple Developer team - no Simulator, no free/personal team.
 */

struct SmartCardScreen: View {
    @StateObject private var cardReader = SmartCardReaderManager()

    var body: some View {
        CblScreen(title: "Smart Card", image: "lego_background") {
            VStack(spacing: 15) {
                Spacer()
                Image(systemName: "creditcard.and.123")
                    .font(.system(size: 60))
                    .foregroundColor(CblTheme.light)

                if !cardReader.isAvailable {
                    Text("NFC is not available on this device.")
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text(cardReader.statusText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if !cardReader.resultLines.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(Array(cardReader.resultLines.enumerated()), id: \.offset) { _, line in
                                Text(line).font(.footnote)
                            }
                        }
                        .padding()
                    }

                    Button("Scan Card") {
                        cardReader.beginScanning()
                    }
                    .buttonStyle(ScreenButtonStyle())
                }
                Spacer()
            }
        }
    }
}

/**
 Talks ISO 7816 to whatever contactless smart card shows up: sends a
 SELECT PPSE APDU and picks the payment-scheme directory apart. Stops
 there - no GET PROCESSING OPTIONS, no READ RECORD, no PAN.
 */
class SmartCardReaderManager: NSObject, ObservableObject, NFCTagReaderSessionDelegate {
    @Published var isAvailable: Bool = NFCNDEFReaderSession.readingAvailable
    @Published var statusText: String = "Tap 'Scan Card' and hold the device near a contactless card."
    @Published var resultLines: [String] = []

    private var session: NFCTagReaderSession?

    // EMV's "Proximity Payment System Environment" directory - every
    // contactless EMV card answers to this, regardless of brand/issuer.
    // This is also the one and only AID declared in Info.plist's
    // select-identifiers - SELECT-ing anything else throws a security
    // violation, by design.
    private static let ppseAID = "2PAY.SYS.DDF01".data(using: .ascii)!

    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            statusText = "NFC is not available on this device."
            return
        }
        resultLines = []
        statusText = "Hold your iPhone near a contactless card…"

        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: nil)
        session?.alertMessage = "Hold your iPhone near a contactless card."
        session?.begin()
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // nothing to do here, just required by the protocol
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }

        guard case let .iso7816(iso7816Tag) = tag else {
            // a plain MIFARE transit/loyalty tag, FeliCa, ... - those don't
            // speak ISO 7816 SELECT-by-DF-name, so they end up here instead
            session.invalidate(errorMessage: "That's not an ISO 7816 smart card.")
            return
        }

        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }
            self.selectPPSE(on: iso7816Tag, session: session)
        }
    }

    private func selectPPSE(on tag: NFCISO7816Tag, session: NFCTagReaderSession) {
        // CLA=00 INS=A4 (SELECT) P1=04 (select by DF name) P2=00, no Le
        let apdu = NFCISO7816APDU(instructionClass: 0x00,
                                   instructionCode: 0xA4,
                                   p1Parameter: 0x04,
                                   p2Parameter: 0x00,
                                   data: Self.ppseAID,
                                   expectedResponseLength: -1)

        // CoreNFC already performed this exact SELECT itself before handing
        // us the tag (that's how select-identifiers works), but it doesn't
        // expose that response to us - so we ask again ourselves to get the
        // actual FCI bytes back. Re-selecting the same application twice in
        // a row is harmless and standard practice.
        tag.sendCommand(apdu: apdu) { [weak self] response, sw1, sw2, error in
            guard let self = self else { return }

            if let error = error {
                session.invalidate(errorMessage: "SELECT PPSE failed: \(error.localizedDescription)")
                return
            }
            guard sw1 == 0x90, sw2 == 0x00 else {
                session.invalidate(errorMessage: String(format: "Card declined SELECT PPSE (SW=%02X%02X) - probably not a payment card.", sw1, sw2))
                return
            }

            let lines = self.describePPSE(response: response, tag: tag)
            DispatchQueue.main.async {
                self.resultLines = lines
                self.statusText = "Card read."
            }
            session.alertMessage = "Card detected."
            session.invalidate()
        }
    }

    // walks the BER-TLV response: FCI (6F) -> FCI proprietary template (A5)
    // -> issuer discretionary data (BF0C, optional) -> one or more
    // application templates (61), each holding an AID (4F) and a label (50)
    private func describePPSE(response: Data, tag: NFCISO7816Tag) -> [String] {
        var lines: [String] = []

        lines.append("UID: \(tag.identifier.map { String(format: "%02X", $0) }.joined())")
        if let historical = tag.historicalBytes, !historical.isEmpty {
            lines.append("ATR historical bytes: \(historical.map { String(format: "%02X", $0) }.joined())")
        }

        guard let fci = TLV.find([0x6F], in: response)?.value,
              let fciProprietary = TLV.find([0xA5], in: fci)?.value else {
            lines.append("Could not parse the PPSE response (unexpected card data format).")
            return lines
        }
        let directory = TLV.find([0xBF, 0x0C], in: fciProprietary)?.value ?? fciProprietary

        let apps = TLV.findAll([0x61], in: directory)
        if apps.isEmpty {
            lines.append("No payment applications listed in the PPSE directory.")
        }
        for app in apps {
            let aid = TLV.find([0x4F], in: app.value)?.value
            let label = TLV.find([0x50], in: app.value)?.value
            let aidHex = aid.map { $0.map { String(format: "%02X", $0) }.joined() } ?? "?"
            let labelText = label.flatMap { String(data: $0, encoding: .ascii) }?.trimmingCharacters(in: .whitespaces) ?? "(no label)"
            lines.append("Application: \(labelText) — AID \(aidHex)")
        }
        return lines
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            if let readerError = error as? NFCReaderError,
               readerError.code == .readerSessionInvalidationErrorUserCanceled {
                self.statusText = "Scan cancelled."
            } else {
                // a security-violation error here almost always means the
                // select-identifiers entry in Info.plist doesn't match the
                // AID this code tries to SELECT - see the file header.
                self.statusText = "Scan failed: \(error.localizedDescription)"
            }
            self.session = nil
        }
    }
}

/**
 Minimal BER-TLV reader, just enough to pick EMV directory data apart.
 ISO 7816 (and EMV on top of it) encodes everything as Tag-Length-Value,
 nested arbitrarily deep - this only parses one level at a time, which is
 all `describePPSE` above ever needs.
 */
struct TLV {
    let tag: [UInt8]
    let value: Data

    static func parseLevel(_ data: Data) -> [TLV] {
        var result: [TLV] = []
        let bytes = Array(data)
        var i = 0
        while i < bytes.count {
            var tagBytes: [UInt8] = [bytes[i]]
            let firstByte = bytes[i]
            i += 1
            // a tag continues into further bytes if the low 5 bits of the
            // first byte are all set, then keeps going while bit 7 is set
            if firstByte & 0x1F == 0x1F {
                while i < bytes.count {
                    let b = bytes[i]
                    tagBytes.append(b)
                    i += 1
                    if b & 0x80 == 0 { break }
                }
            }
            guard i < bytes.count else { break }

            var length = 0
            let lengthByte = bytes[i]
            i += 1
            if lengthByte & 0x80 == 0 {
                length = Int(lengthByte)
            } else {
                let numLengthBytes = Int(lengthByte & 0x7F)
                guard i + numLengthBytes <= bytes.count else { break }
                for _ in 0..<numLengthBytes {
                    length = (length << 8) | Int(bytes[i])
                    i += 1
                }
            }
            guard i + length <= bytes.count else { break }

            result.append(TLV(tag: tagBytes, value: Data(bytes[i..<(i + length)])))
            i += length
        }
        return result
    }

    static func find(_ tag: [UInt8], in data: Data) -> TLV? {
        parseLevel(data).first { $0.tag == tag }
    }

    static func findAll(_ tag: [UInt8], in data: Data) -> [TLV] {
        parseLevel(data).filter { $0.tag == tag }
    }
}

/*

 A few more things worth knowing:

 - The "select-identifiers" whitelist is enforced by the OS, not by this
   code - try to SELECT an AID you didn't declare and you get
   NFCReaderErrorSecurityViolation, no matter what the app asks for.

 - Real terminals continue with GET PROCESSING OPTIONS and READ RECORD
   after SELECT to get the actual PAN/expiry/cardholder data - that's two
   more APDUs and a fair amount of TLV-juggling away from here, and very
   much "handle real payment data responsibly" territory rather than
   "iOS sensor demo" territory.

 - Apple Pay / Wallet card data is never reachable this way either - same
   as with NFCScreen, it lives in the Secure Element.

 */
