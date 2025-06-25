import SwiftUI
import Photos

struct TrashView: View {
    @ObservedObject var storageViewModel: StorageUsageViewModel
    @ObservedObject var cleanerViewModel: CleanerViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var assetImages: [String: UIImage] = [:]
    @State private var assetSizes: [String: Int64] = [:]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("mainBg")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("backButton")
                    }
                    Text("Trash")
                        .font(.custom("Inter-SemiBold", size: 24))
                        .foregroundColor(.cFFFFFF)
                    Spacer()
                    if !PurchaseManager.instance.userPurchaseIsActive {
                        Button(action: {
                            cleanerViewModel.showSubscriptionScreenView = true
                        }, label: {
                            Image("crown")
                        })
                    }
                }
                .padding(.horizontal)
                
                if storageViewModel.trash.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Text("No deleted photos yet")
                            .font(.custom("Inter-SemiBold", size: 28))
                            .foregroundColor(.cFFFFFF)
                        Text("After selecting the photos you don't like, they will be displayed here for further cleaning.")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.cADAEFF)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(28)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(Array(storageViewModel.trash), id: \.self) { id in
                                if let asset = fetchAsset(by: id) {
                                    DeleteAssetCell(
                                        asset: asset
                                    )
                                    .padding(.horizontal, 4)
                                }
                            }
                        }
                        .padding(.horizontal,12)
                    }
                }
            }
            
            Button(action: deleteAll) {
                ZStack {
                    Image("Clean")
                    Text("Clean\nAll")
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundStyle(.cFFFFFF)
                        .opacity(storageViewModel.trash.isEmpty ? 0.5 : 1)
                }
            }
            .frame(width: 130, height: 130)
            .disabled(storageViewModel.trash.isEmpty)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: loadThumbnails)
    }
    
    private func fetchAsset(by id: String) -> PHAsset? {
        let result = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        return result.firstObject
    }
    
    private func loadThumbnails() {
        for id in storageViewModel.trash {
            if let asset = fetchAsset(by: id) {
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 60, height: 60), contentMode: .aspectFill, options: nil) { img, _ in
                    if let img = img {
                        assetImages[id] = img
                    }
                }
                let resources = PHAssetResource.assetResources(for: asset)
                if let size = resources.first?.value(forKey: "fileSize") as? CLong {
                    assetSizes[id] = Int64(size)
                }
            }
        }
    }
    
    private func deleteAll() {
        let assets = storageViewModel.trash.compactMap { fetchAsset(by: $0) }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }) { success, error in
            if success {
                DispatchQueue.main.async {
                    storageViewModel.trash.removeAll()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

#Preview {
    TrashView(storageViewModel: StorageUsageViewModel(), cleanerViewModel: CleanerViewModel())
}
