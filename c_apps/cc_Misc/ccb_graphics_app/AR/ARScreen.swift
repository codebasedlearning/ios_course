// (C) 2025 A.Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import RealityKit
import ARKit

struct ARScreen: View {
    var body: some View {
        VStack(spacing:0) {
            Divider()
            HeaderText(text: "AR")
                .padding(.bottom, 5)
            ARViewContainer()
            //.edgesIgnoringSafeArea(.all)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @State private var lastScale: CGFloat = 1.0
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        // Start AR session
                //let configuration = ARWorldTrackingConfiguration()
                //arView.session.run(configuration)
        
        // cube model
        let mesh = MeshResource.generateBox(size: 0.3, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .red, roughness: 0.0, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        //model.transform.translation.y = 0.05
        model.position = SIMD3(0, 0, -1)
        
        // create horizontal plane anchor
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)
        
        // add plane anchor to the scene
        arView.scene.anchors.append(anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
        
}


#Preview {
    ARScreen()
}
