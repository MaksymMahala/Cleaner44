import SwiftUI
import ApphudSDK

class AppHUDViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var products: [ApphudProduct] = [] {
        didSet {
            selectedProduct = products.first
        }
    }
    @Published var selectedProductIndex = 0
    @Published var isLoading = false
    @Published var isRestoreAlertPresented = false
    @Published var restoreTitle = ""
    @Published var restoreMessage: String?
    
    @Published var selectedProduct: ApphudProduct?
    @Published var isShowIap = false
    
    let purchaseService = PurchaseManager.instance
    
    // MARK: - Methods
    
    @MainActor
    func fetchProducts(paywallId: String) {
        purchaseService.getSubscriptions(paywallId: paywallId) { succeeded in
            if succeeded {
                self.purchaseService.products.forEach { product in
                    print("Product: \(product.skProduct?.localizedTitle ?? "")")
                }
                self.products = self.purchaseService.products
            }
        }
    }
    
    @MainActor func purchase(completion: @escaping (Bool) -> ()) {
        if !products.isEmpty {
            isLoading = true
            purchaseService.purchase(products[selectedProductIndex].productId) { [weak self] _, succeeded in
                self?.isLoading = false
                if succeeded {
                    print("Subscription succeeded!")
                } else {
                    print("Subscription failed.")
                }
                completion(succeeded)
            }
        } else {
            print("Subscription have not loaded.")
        }
    }
}
