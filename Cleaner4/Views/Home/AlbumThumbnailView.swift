import SwiftUI
import Photos

struct AlbumThumbnailView: View {
    let asset: PHAsset?
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
        }
        .frame(width: 60, height: 60)
        .cornerRadius(8)
        .onAppear {
            guard let asset else { return }
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 60, height: 60), contentMode: .aspectFill, options: nil) { img, _ in
                self.image = img
            }
        }
    }
}
