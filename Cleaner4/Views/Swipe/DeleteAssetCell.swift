import SwiftUI
import Photos

struct DeleteAssetCell: View {
    let asset: PHAsset
    @State private var image: UIImage?
    
    private var fileSizeString: String {
        let resources = PHAssetResource.assetResources(for: asset)
        if let size = resources.first?.value(forKey: "fileSize") as? CLong {
            let byteCount = Int64(size)
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useGB, .useMB]
            formatter.countStyle = .file
            return formatter.string(fromByteCount: byteCount)
        }
        return ""
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Group {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle().fill(Color.gray)
                    }
                }
                .frame(width: geometry.size.width, height: 246)
                .clipped()
                .cornerRadius(20)
                .onAppear {
                    PHImageManager.default().requestImage(
                        for: asset,
                        targetSize: CGSize(width: Int(geometry.size.width), height: 246),
                        contentMode: .aspectFill,
                        options: nil
                    ) { result, _ in
                        self.image = result
                    }
                }

                HStack(alignment: .bottom) {
                    Text(fileSizeString)
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.cFFFFFF)
                    Spacer()
                }
                .padding(12)
            }
        }
        .frame(height: 246)
    }
}
