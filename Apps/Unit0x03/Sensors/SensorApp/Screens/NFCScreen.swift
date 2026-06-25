// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import CoreNFC
import CblUI

/*
 Core NFC lets the app read NDEF-formatted tags (the cheap NFC stickers/
 cards you can buy, also some transit/loyalty cards). There is no pairing
 or "connection" like with Bluetooth - the OS pops up a system sheet, the
 user holds the phone near the tag for about a second, done.

 Setup needed beyond this file (already added to the project):
  - Capability "Near Field Communication Tag Reading", i.e. an
    entitlement com.apple.developer.nfc.readersession.formats = ["NDEF"]
  - Info.plist key NFCReaderUsageDescription

 Two things that will bite you when trying this on your own:
  - The Simulator has no NFC radio - you need a physical iPhone 7 or later.
  - A free/personal-team signing identity is not enough; Core NFC needs a
    real (paid) Apple Developer Program team, otherwise the session start
    fails with a sandbox error.
 */

struct NFCScreen: View {
    @StateObject private var nfcReader = NFCReaderManager()

    var body: some View {
        CblScreen(title: "NFC Reader", image: "lego_background") {
            VStack(spacing: 15) {
                Spacer()
                Image(systemName: "wave.3.right.circle")
                    .font(.system(size: 60))
                    .foregroundColor(CblTheme.light)

                if !nfcReader.isAvailable {
                    Text("NFC is not available on this device.")
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text(nfcReader.statusText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if !nfcReader.scannedPayloads.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(Array(nfcReader.scannedPayloads.enumerated()), id: \.offset) { _, payload in
                                Text(payload)
                            }
                        }
                        .padding()
                    }

                    Button("Scan NFC Tag") {
                        nfcReader.beginScanning()
                    }
                    .buttonStyle(ScreenButtonStyle())
                }
                Spacer()
            }
        }
    }
}

/**
 Thin wrapper around NFCNDEFReaderSession: starts a session, decodes
 whatever NDEF records the first tag carries, and shows the result (or
 the error) back to the view.
 */
class NFCReaderManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var isAvailable: Bool = NFCNDEFReaderSession.readingAvailable
    @Published var statusText: String = "Tap 'Scan NFC Tag' and hold the device near a tag."
    @Published var scannedPayloads: [String] = []

    private var session: NFCNDEFReaderSession?

    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            statusText = "NFC is not available on this device."
            return
        }
        scannedPayloads = []
        statusText = "Hold your iPhone near an NFC tag…"

        // invalidateAfterFirstRead: true keeps this example simple - one
        // tag, then the session ends. Set it to false and call
        // session.restartPolling() if you want to read multiple tags
        // in a row without the user re-tapping the button.
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near an NFC tag."
        session?.begin()
    }

    // called once a tag with at least one NDEF message was found
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var payloads: [String] = []
        for message in messages {
            for record in message.records {
                // the payload's encoding depends on the record type (text,
                // URI, ...) - this is the naive decode, just enough to show
                // *something* readable for this teaching example
                if let text = String(data: record.payload, encoding: .utf8) {
                    payloads.append(text)
                } else {
                    payloads.append(record.payload.map { String(format: "%02x", $0) }.joined())
                }
            }
        }

        DispatchQueue.main.async {
            self.scannedPayloads = payloads.isEmpty ? ["Tag found, but it has no readable NDEF records."] : payloads
            self.statusText = "Tag read."
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            // .userCanceled / .sessionTimeout just mean the session ended,
            // that is not really an "error" from the user's perspective
            if let readerError = error as? NFCReaderError,
               readerError.code == .readerSessionInvalidationErrorUserCanceled {
                self.statusText = "Scan cancelled."
            } else {
                self.statusText = "Scan failed: \(error.localizedDescription)"
            }
            self.session = nil
        }
    }
}

/*

 A few more things worth knowing:

 - NFCNDEFReaderSession only reads tags already formatted with NDEF
   (NFC Data Exchange Format) - most NFC stickers/cards you can buy are.
   For raw/proprietary tags (ISO7816, FeliCa, MiFare, ...) you'd reach
   for NFCTagReaderSession with format "TAG" instead, which needs an
   extra entitlement request that Apple has to approve separately.

 - Apple Pay / payment-card "tap to pay" data is not readable this way -
   it lives in the Secure Element, Core NFC never gets near it.

 - You can also *write* NDEF messages (NFCNDEFReaderSession has a
   connect/writeNDEF path on NFCNDEFTag), e.g. to provision your own
   stickers - out of scope for this simple reader example.

 */
