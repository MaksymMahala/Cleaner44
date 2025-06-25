import Foundation
import ApphudSDK
import SwiftUI
import AdSupport

final class PurchaseManager {
    
    // MARK: - Properties
    @AppStorage("userPurchaseIsActiveCleaner") var userPurchaseIsActive: Bool = false
    @AppStorage("shouldShowPromotionCleaner") var shouldShowPromotion = true
    static let instance = PurchaseManager()
    var products: [ApphudProduct] = []
    
    private init() {}
    
    // MARK: - Methods
    @MainActor func activate() {
        Apphud.start(apiKey: AppConstants.appHudId)
        Apphud.setDeviceIdentifiers(idfa: nil, idfv: UIDevice.current.identifierForVendor?.uuidString)
    }
    
    func setDevice() {
            //requestTrackingPermission()
    }
    
    @MainActor func purchase(_ productID: String, completion: @escaping (String?, Bool) -> ()) {
        Apphud.purchase(productID) { result in
            if result.success {
                self.userPurchaseIsActive = true
                self.shouldShowPromotion = false
                completion(nil, true)
            } else if let subscription = result.subscription, subscription.isActive() {
                self.userPurchaseIsActive = Apphud.hasActiveSubscription()
                self.shouldShowPromotion = false
                completion(nil, true)
            } else {
                completion(nil, false)
            }
        }
    }
    
    @MainActor func restorePurchases(completion: @escaping (Bool) -> ()) {
        Apphud.restorePurchases { _, _, _ in
            if Apphud.hasActiveSubscription() {
                self.userPurchaseIsActive = Apphud.hasActiveSubscription()
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    @MainActor func getSubscriptions(paywallId: String, completion: @escaping (Bool) -> ()) {
        checkSubscription()
        Apphud.paywallsDidLoadCallback { paywalls, error in
            
            if let error = error {
                print("Error loading paywalls: \(error.localizedDescription)")
                completion(false)
                return
            }
            if paywalls.count == 0 {
                completion(false)
            } else {
                if let paywall = paywalls.first(where: {$0.identifier == paywallId}) {
                    self.products = paywall.products
                    self.products.forEach { product in
                        print("Product: \(product.skProduct?.localizedTitle ?? "")")
                    }
                }
                completion(true)
            }
        }
    }
    
    func checkSubscription() {
        userPurchaseIsActive = Apphud.hasActiveSubscription()
    }
    
 /*   func requestTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // The user authorized access to IDFA
                    print("Tracking authorized. IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                    self.fetchIDFA()
                case .denied, .restricted, .notDetermined:
                    // The user denied or restricted access, or the authorization is not determined yet
                    print("Tracking denied or restricted")
                @unknown default:
                    break
                }
            }
        }
    }
    
    func fetchIDFA() {
            if #available(iOS 14.5, *) {
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                    ATTrackingManager.requestTrackingAuthorization { status in
                        guard status == .authorized else {return}
                        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                        Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
                    }
                }
            }
        } */
}
