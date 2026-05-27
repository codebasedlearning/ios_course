// (C) 2025 Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import AVFoundation
import CblUI

/*
 tbd:  - There is some strange cam window size, it has to adapt to the
         remaining screen space.
       - To get the code type (barcode, qr, ...) would be cool.
 */

struct ScannerScreen: View {
    @State private var scannedCode: String?
    @State private var showPermissionAlert = false
    
    var body: some View {
        CblScreen(title: "Scanner", image: "scanner") {
            if let code = scannedCode {
                Text("Scanned Code:")
                    .padding(5)
                Text("\(code)")
                    .padding(15)
                Button("Start Scanning") {
                    scannedCode = nil
                }
                .buttonStyle(ScreenButtonStyle())
            } else {
                GeometryReader { geo in
                    ZStack {
                        ScannerView { code in
                            self.scannedCode = code
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                        
                        FocusRectangleView()
                            .padding()
                    }
                }
            }
        }.onAppear {
            scannedCode = "-"
            checkCameraPermission()
        }
        .onDisappear {
            scannedCode = nil
        }
        
        .alert(isPresented: $showPermissionAlert) {
            Alert(title: Text("Camera Permission"), message: Text("Please enable camera access in Settings to use this feature."), dismissButton: .default(Text("OK")))
        }
    }
    
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera
            break
        case .notDetermined:
            // The user has not yet been asked for camera access
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        self.showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            // The user has previously denied access
            self.showPermissionAlert = true
        @unknown default:
            break
        }
    }
    
}

class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var parent: ScannerView
    var session: AVCaptureSession?  // held here so dismantleUIView can stop it

    init(parent: ScannerView) {
        self.parent = parent
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            DispatchQueue.main.async {
                self.parent.didFindCode(stringValue)
            }
        }
    }
}

struct FocusRectangleView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(Color.green, lineWidth: 4)
            .frame(width: 250, height: 250)
            .opacity(0.75)
    }
}

struct ScannerView: UIViewRepresentable {
    var didFindCode: (String) -> Void
    
    func makeCoordinator() -> ScannerCoordinator {
        return ScannerCoordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let session = AVCaptureSession()
        let videoCaptureDevice = AVCaptureDevice.default(for: .video)
        let videoInput: AVCaptureDeviceInput
        
        guard let videoCaptureDevice = videoCaptureDevice else {
            return view
        }
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return view
        }
        
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        } else {
            return view
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .code128]
        } else {
            return view
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill

        DispatchQueue.main.async {
            previewLayer.frame = view.layer.bounds
            view.layer.addSublayer(previewLayer)
        }

        // startRunning() is blocking — must not run on the main thread
        context.coordinator.session = session
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // keep the preview layer in sync with the view's bounds (e.g. on rotation)
        if let previewLayer = uiView.layer.sublayers?.first(where: { $0 is AVCaptureVideoPreviewLayer }) {
            previewLayer.frame = uiView.layer.bounds
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: ScannerCoordinator) {
        coordinator.session?.stopRunning()
    }
}
