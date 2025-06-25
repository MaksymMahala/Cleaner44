import SwiftUI
import Photos

struct AlbumInsideView: View {
    let album: AlbumDisplayInfo
    @State private var assets: [PHAsset] = []
    @State private var selectedAssets: Set<String> = []
    @ObservedObject var cleanerViewModel: CleanerViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var sortOption: String = ""
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
                    Text(album.title)
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
                
                //SORT
                HStack(spacing: 12) {
                    Menu {
                        Button("Sort by Date") {
                            assets.sort(by: { $0.creationDate ?? Date.distantPast > $1.creationDate ?? Date.distantPast })
                        }
                        Button("Sort by Size") {
                            assets.sort(by: { getSize(of: $0) > getSize(of: $1) })
                        }
                    } label: {
                        Image("sort")
                    }
                    
                    Button(action: toggleSelectAll) {
                        HStack(spacing: 8) {
                            Image(selectedAssets.count == assets.count ? "selectAll" : "selectAllEmpty")
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                
                if assets.isEmpty {
                    ProgressView("Loading...")
                        .onAppear(perform: loadAssets)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(assets, id: \.localIdentifier) { asset in
                                AlbumAssetCell(
                                    asset: asset,
                                    isSelected: selectedAssets.contains(asset.localIdentifier),
                                    onTap: {
                                        if selectedAssets.contains(asset.localIdentifier) {
                                            selectedAssets.remove(asset.localIdentifier)
                                        } else {
                                            selectedAssets.insert(asset.localIdentifier)
                                        }
                                    }
                                )
                                .padding(.horizontal, 4)
                                
                            }
                            
                        }
                        .padding(.horizontal, 12)
                    }
                }
            }
            .navigationBarHidden(true)
            Button(action: deleteSelected) {
                ZStack {
                    Image("Clean")
                    Text("Clean")
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundStyle(.cFFFFFF)
                        .opacity(selectedAssets.isEmpty ? 0.5 : 1)
                }
            }
            .frame(width: 130, height: 130)
            .disabled(selectedAssets.isEmpty)
        }
    }
    
    private func loadAssets() {
        let fetchResult = PHAsset.fetchAssets(in: album.collection, options: nil)
        var allAssets: [PHAsset] = []
        
        fetchResult.enumerateObjects { asset, _, _ in
            allAssets.append(asset)
        }
        
        DispatchQueue.main.async {
            self.assets = allAssets
        }
        
    }
    
    private func deleteSelected() {
        let assetsToDelete = assets.filter { selectedAssets.contains($0.localIdentifier) }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSFastEnumeration)
        }) { success, error in
            if success {
                DispatchQueue.main.async {
                    assets.removeAll { selectedAssets.contains($0.localIdentifier) }
                    selectedAssets.removeAll()
                }
            } else {
                print("Failed to delete: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    
    private func toggleSelectAll() {
        if selectedAssets.count == assets.count {
            selectedAssets.removeAll()
        } else {
            selectedAssets = Set(assets.map { $0.localIdentifier })
        }
    }
    
    private func getSize(of asset: PHAsset) -> Int64 {
        let resources = PHAssetResource.assetResources(for: asset)
        if let size = resources.first?.value(forKey: "fileSize") as? CLong {
            return Int64(size)
        }
        return 0
    }
}


