import SwiftUI

@Observable
class PageOffsetObserver: NSObject {
    var collionView: UICollectionView?
    var offset: CGFloat = 0
    private(set) var isObserving: Bool = false
    
    deinit {
        remove()
        collionView = nil

    }
    
    func observe() {
        guard let collectionView = collionView, !isObserving else { return }
        collectionView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
        isObserving = true
    }
    
    func remove() {
        if isObserving, let collectionView = collionView {
            collectionView.removeObserver(self, forKeyPath: "contentOffset")
            isObserving = false
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else { return }
        if let contenOffset = (object as? UICollectionView)?.contentOffset {
            offset = contenOffset.x
        }
    }
}
