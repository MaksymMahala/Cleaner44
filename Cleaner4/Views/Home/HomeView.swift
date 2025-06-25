import SwiftUI
import Photos

struct HomeView: View {
    @ObservedObject var storageViewModel: StorageUsageViewModel
    @ObservedObject var cleanerViewModel: CleanerViewModel
    @State private var albums: [AlbumDisplayInfo] = []
    @State private var scanning: Bool = false

    var body: some View {
        ZStack {
            if scanning {
                DotJumpingView()
            } else {
                VStack {
                    Spacer()
                        .frame(height: 50)
                    StorageView(viewModel: storageViewModel)
                        .padding(.horizontal, 16)
                    Spacer()
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Album rows
                            ForEach(albums.indices, id: \.self) { index in
                                let album = albums[index]
                                let isLocked = index > 1 && !PurchaseManager.instance.userPurchaseIsActive

                                NavigationLink(
                                    destination: AlbumInsideView(album: album, cleanerViewModel: cleanerViewModel),
                                    label: {
                                        HStack(spacing: 12) {
                                            AlbumThumbnailView(asset: album.thumbnailAsset)
                                                .overlay {
                                                    if isLocked {
                                                        ZStack {
                                                            Color.c000000.opacity(0.6)
                                                            Image("lock")
                                                        }
                                                    }
                                                }
                                            Text("\(album.count) \(album.title)")
                                                .font(.custom("Inter-Medium", size: 16))
                                                .foregroundStyle(.cFFFFFF)

                                            Spacer()

                                            Text(formatSize(album.size))
                                                .font(.custom("Inter-Medium", size: 16))
                                                .foregroundStyle(.cFFFFFF)

                                            Image("chevron")
                                        }
                                        .padding(.horizontal)
                                    }
                                )
                                .disabled(isLocked)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            scanning = true
            cleanerViewModel.requestAccessToContacts()
            storageViewModel.performIfGalleryAccessAllowed {
            }
            
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized || status == .limited else { return }
                
                let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
                let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
                
                var infos: [AlbumDisplayInfo] = []
                
                [userAlbums, smartAlbums].forEach { collections in
                    collections.enumerateObjects { collection, _, _ in
                        let assets = PHAsset.fetchAssets(in: collection, options: nil)
                        var assetArray: [PHAsset] = []
                        var totalSize: Int64 = 0
                        
                        assets.enumerateObjects { asset, _, _ in
                            assetArray.append(asset)
                            let resources = PHAssetResource.assetResources(for: asset)
                            if let resource = resources.first,
                               let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {
                                totalSize += Int64(unsignedInt64)
                            }
                        }
                        
                        
                        if !assetArray.isEmpty {
                            infos.append(AlbumDisplayInfo(
                                title: collection.localizedTitle ?? "Untitled",
                                count: assetArray.count,
                                size: totalSize,
                                thumbnailAsset: assetArray.first,
                                collection: collection
                            ))
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.albums = infos
                    scanning = false
                }
            }
        }


        
    }
}

//# MARK: - Size Formatter
func formatSize(_ bytes: Int64) -> String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useGB, .useMB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: bytes)
}

#Preview {
    HomeView(storageViewModel: StorageUsageViewModel(), cleanerViewModel: CleanerViewModel())
}




