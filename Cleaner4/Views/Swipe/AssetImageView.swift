import SwiftUI
import Photos

struct AssetImageView: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.gray
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.7)
        
        .onAppear {
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 900, height: 1200), contentMode: .aspectFill, options: nil) { img, _ in
                if let img = img {
                    image = img
                }
            }
        }
    }
}
