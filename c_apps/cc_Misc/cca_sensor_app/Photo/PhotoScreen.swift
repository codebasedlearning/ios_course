// (C) 2024 A.Voß, a.voss@fh-aachen.de, ios@codebasedlearning.dev

import SwiftUI

struct PhotoScreen: View {
    @State var photoModel = PhotoCaptureViewModel()
        
    var body: some View {
        VStack {
            if let image = photoModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Text("No Image")
                    .foregroundColor(.gray)
                    .frame(width: 300, height: 300)
                    .background(Color.black.opacity(0.1))
            }
            Button("Take Photo") {
                photoModel.showImagePicker = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        // this is the way to show modal dialogs
        .sheet(isPresented: $photoModel.showImagePicker) {
            ImagePicker(viewModel: photoModel)
        }
    }
}

#Preview {
    PhotoScreen()
}
