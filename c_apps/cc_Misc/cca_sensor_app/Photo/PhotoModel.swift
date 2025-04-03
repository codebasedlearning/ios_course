// (C) 2024 A.Voß, a.voss@fh-aachen.de, ios@codebasedlearning.dev

import Foundation
import SwiftUI

/*
 Again, we need permission, i.e. 
 'Privacy - Camera usage description' -> 'We need access to your camera to take photos.'
 */

@Observable
class PhotoCaptureViewModel {
    var image: UIImage?
    var showImagePicker: Bool = false
    var sourceType: UIImagePickerController.SourceType = .camera
}

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var parent: PhotoCaptureViewModel

    init(parent: PhotoCaptureViewModel) {
        self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            parent.image = image
        }
        parent.showImagePicker = false
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.showImagePicker = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Bindable var viewModel: PhotoCaptureViewModel

    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(parent: viewModel)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = viewModel.sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
