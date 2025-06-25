import SwiftUI

struct PlansView: View {
    
    // MARK: - Properties
    @ObservedObject var viewModel: AppHUDViewModel
    
    // MARK: - Body
    var body: some View {
        let minPrice = viewModel.products
            .compactMap { $0.skProduct?.price.doubleValue }
            .min()
        
        let maxPrice = viewModel.products
            .compactMap { $0.skProduct?.price.doubleValue }
            .max()
        
        HStack(spacing: 8) {
            ForEach(0..<viewModel.products.count, id: \.self) { index in
                let product = viewModel.products[index]
                Button {
                    viewModel.selectedProductIndex = index
                    viewModel.selectedProduct = viewModel.products[index]
                } label: {
                    if let skProduct = product.skProduct {
                        PlanView(
                            planType: skProduct.getProductDuration(),
                            planPrice: skProduct.getProductPrice() + "/" + skProduct.getProductDurationTypeAndUnit(),
                            planWeeklyPrice: "\(skProduct.getProductWeeklyPrice())/Week",
                            planIsSelected: viewModel.selectedProductIndex == index,
                            planIsOffer: false,
                            popular: skProduct.price.doubleValue == minPrice,
                            best: skProduct.price.doubleValue == maxPrice
                        )
                    }
                }
            }
        }
        .background(Color.clear)
    }
}
