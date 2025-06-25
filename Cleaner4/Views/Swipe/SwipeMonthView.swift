import SwiftUI
import Photos

struct SwipeMonthView: View {
    @ObservedObject var cleanerViewModel: CleanerViewModel
    @ObservedObject var storageViewModel = StorageUsageViewModel()
    @State private var groupedAlbums: [String: [PHAsset]] = [:]
    @State private var sortedMonths: [(month: String, date: Date)] = []
    @State private var thumbnails: [String: UIImage] = [:]
    
    var body: some View {
        
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(sortedMonths, id: \.month) { item in
                    let month = item.month
                    let index = sortedMonths.firstIndex(where: { $0.month == month }) ?? 0
                    let isLocked = index > 1 && !PurchaseManager.instance.userPurchaseIsActive
                    NavigationLink(destination: SwipeView(month: month, assets: groupedAlbums[month] ?? [], storageViewModel: storageViewModel, cleanerViewModel: cleanerViewModel)) {
                        HStack(spacing: 12) {
                            if let image = thumbnails[month] {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 68, height: 68)
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay {
                                        if isLocked {
                                            ZStack {
                                                Color.c000000.opacity(0.6)
                                                    .cornerRadius(8)
                                                Image("lock")
                                            }
                                        }
                                    }
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 68, height: 68)
                            }
                            
                            VStack(alignment: .leading, spacing: 14) {
                                Text(month)
                                    .font(.custom("Inter-Medium", size: 16))
                                    .foregroundColor(.cFFFFFF)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(selectedCount(for: month))/\(groupedAlbums[month]?.count ?? 0) photos")
                                        .font(.custom("Inter-Regular", size: 16))
                                        .foregroundColor(.cADAEFF)
                                    
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color.cFFFFFF.opacity(0.2))
                                            .frame(height: 8)
                                        
                                        GeometryReader { geometry in
                                            GradientColors.gradient3horizontal
                                                .frame(width: geometry.size.width * CGFloat(photosProgress(for: month)))
                                                .cornerRadius(24)
                                        }
                                        .frame(height: 8)
                                    }
                                    .frame(height: 8)
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .disabled(isLocked)
                }
                
            }
        }
        .padding(.top, 50)
        .onAppear(perform: fetchAssetsGroupedByMonth)
    }
    
    private func photosProgress(for month: String) -> Double {
        let total = groupedAlbums[month]?.count ?? 0
        guard total > 0 else { return 0 }
        return Double(selectedCount(for: month)) / Double(total)
    }
    
    private func fetchAssetsGroupedByMonth() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let allAssets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            var groups: [String: [PHAsset]] = [:]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            
            allAssets.enumerateObjects { asset, _, _ in
                if let date = asset.creationDate {
                    let month = dateFormatter.string(from: date)
                    groups[month, default: []].append(asset)
                }
            }
            
            let sorted = groups.compactMap { key, _ -> (String, Date)? in
                if let date = dateFormatter.date(from: key) {
                    return (key, date)
                }
                return nil
            }.sorted(by: { $0.1 > $1.1 })
            
            
            DispatchQueue.main.async {
                self.groupedAlbums = groups
                self.sortedMonths = sorted
                
                // Load thumbnails for each month
                for (month, assets) in groups {
                    if let asset = assets.first {
                        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 48, height: 48), contentMode: .aspectFill, options: nil) { image, _ in
                            if let image = image {
                                DispatchQueue.main.async {
                                    self.thumbnails[month] = image
                                }
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    private func selectedCount(for month: String) -> Int {
        let ids = groupedAlbums[month]?.map { $0.localIdentifier } ?? []
        return ids.filter { storageViewModel.trash.contains($0) }.count
    }
}

#Preview {
    SwipeMonthView(cleanerViewModel: CleanerViewModel())
}
