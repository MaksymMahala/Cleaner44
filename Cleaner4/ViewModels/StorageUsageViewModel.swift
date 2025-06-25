import SwiftUI
import Photos

class StorageUsageViewModel: ObservableObject {
    @Published var totalDiskSpace: Int64 = 0
    @Published var photosAndVideosSpace: Int64 = 0
    @Published var totalFileCount: Int = 0
        @Published  var trash: Set<String> = []

    var usedDiskSpacePercentage: Double {
        let fileManager = FileManager.default
        if let attributes = try? fileManager.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let totalSpace = attributes[.systemSize] as? Int64,
           let freeSpace = attributes[.systemFreeSize] as? Int64 {
            let usedSpace = totalSpace - freeSpace
            return Double(usedSpace) / Double(totalSpace)
        }
        return 0
    }
    
    var usedDiskSpacePercentageFormatted: String {
        let percent = Double(usedDiskSpace) / Double(totalDiskSpace) * 100
        return String(format: "%.2f%%", percent)
    }
    
    init() {
        calculateStorageUsage()
    }
    
    
    //MARK: - ProgressView
    var usedDiskSpace: Int64 {
        if let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let totalSpace = attributes[.systemSize] as? Int64,
           let freeSpace = attributes[.systemFreeSize] as? Int64 {
            return totalSpace - freeSpace
        }
        return 0
    }
    
    var totalDiskSpaceReadable: String {
        return bytesToGigabytes(totalDiskSpace)
    }
    
    var usedDiskSpaceReadable: String {
        return bytesToGigabytes(usedDiskSpace)
    }
    
    
    private func calculateStorageUsage() {
        DispatchQueue.global(qos: .userInitiated).async {
            let totalSpace = self.getTotalDiskSpace()
            let (usedSpace, fileCount) = self.calculatePhotosAndVideosSpace()
            DispatchQueue.main.async {
                self.totalDiskSpace = totalSpace
                self.photosAndVideosSpace = usedSpace
                self.totalFileCount = fileCount
            }
        }
    }
    
    private func getTotalDiskSpace() -> Int64 {
        if let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let space = attributes[.systemSize] as? Int64 {
            return space
        }
        return 0
    }
    
    private func calculatePhotosAndVideosSpace() -> (Int64, Int) {
        let fetchOptions = PHFetchOptions()
        let assets = PHAsset.fetchAssets(with: fetchOptions)
        
        var totalSize: Int64 = 0
        var fileCount = 0
        let manager = PHImageManager.default()
        
        assets.enumerateObjects { asset, _, _ in
            fileCount += 1
            let resources = PHAssetResource.assetResources(for: asset)
            for resource in resources {
                if let size = resource.value(forKey: "fileSize") as? Int64 {
                    totalSize += size
                }
            }
        }
        
        return (totalSize, fileCount)
    }
    
    func bytesToGigabytes(_ bytes: Int64) -> String {
        let gigabytes = Double(bytes) / (1024 * 1024 * 1024)
        return String(format: "%.2f", gigabytes)
    }
    
    var storageUsagePercentage: Double {
        totalDiskSpace > 0 ? Double(photosAndVideosSpace) / Double(totalDiskSpace) : 0
    }
    
    var storageUsagePercentageFormatted: String {
        String(format: "%.2f", storageUsagePercentage * 100)
    }

    func performIfGalleryAccessAllowed(action: @escaping () -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            action() 
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.promptGalleryAccessSettings()
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    DispatchQueue.main.async {
                        action()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.promptGalleryAccessSettings()
                    }
                }
            }
        @unknown default:
            break
        }
    }
    
    private func promptGalleryAccessSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        let alert = UIAlertController(
            title: "Access Denied",
            message: "Please enable gallery access in settings to use this feature.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            UIApplication.shared.open(settingsURL)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
}

extension PHAsset {
    var fileSize: Int64 {
        let resources = PHAssetResource.assetResources(for: self)
        return resources.first?.value(forKey: "fileSize") as? Int64 ?? 0
    }
    
    var fileSizeInGb: String {
        let resources = PHAssetResource.assetResources(for: self)
        let gigabytes = Double(resources.first?.value(forKey: "fileSize") as? Int64 ?? 0)
        let estimatedSize = Int64(gigabytes)
        return ByteCountFormatter.string(fromByteCount: estimatedSize, countStyle: .file)
    }
    
    var safeCreationDate: Date {
        self.creationDate ?? Date.distantPast
    }
    
}
