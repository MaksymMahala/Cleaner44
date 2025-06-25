import SwiftUI
import Photos

struct AlbumDisplayInfo: Identifiable {
    let id = UUID()
    let title: String
    let count: Int
    let size: Int64
    let thumbnailAsset: PHAsset?
    let collection: PHAssetCollection
}
