import SwiftUI

struct SubscriptionScreenView: View {
    @Binding var isPresented: Bool
    @StateObject var viewModel: AppHUDViewModel = AppHUDViewModel()
    @AppStorage("isOnboardingCleaner") var isOnboarding: Bool?
    @State private var currentIndex = 0
    @State private var timer: Timer?
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            Image("mainBg")
                .resizable()
                .ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(0..<3, id: \.self) { index in
                    VStack {
                        Image("sub\(index + 1)")
                            .resizable()
                            .scaledToFit()
                        Spacer()
                    }
                    .offset(y: -20)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            VStack(spacing: 12) {
                HStack {
                    Button(action: {
                        isPresented = false
                    }, label: {
                        Image("close")
                            .font(.system(size: 20, weight: .bold))
                            .frame(width: 32, height: 32)
                    })
                    Spacer()
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                VStack(spacing: 12) {
                    PointsView()
                    
                    Text("Unlock unlimited access")
                        .font(.custom("Inter-Black", size: 30))
                        .foregroundColor(Color.cFFFFFF)
                        .padding(.bottom, 4)
                        .padding(.horizontal, 16)
                    
                    PlansView(viewModel: viewModel)
                        .frame(height: 75)
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 4) {
                        Text("3-day free trial ・ Recurring Bill ・ Cancel anytime")
                            .font(.custom("Inter-Regular", size: 14))
                            .foregroundColor(Color.cFFFFFF)
                            .multilineTextAlignment(.center)
                        Text("Secured by the App Store")
                            .font(.custom("Inter-Regular", size: 12))
                            .foregroundColor(Color.cFFFFFF)
                            .multilineTextAlignment(.center)
                    }

                    Button(action: {
                        viewModel.purchaseService.purchase(viewModel.selectedProduct?.productId ?? "") { error, isActive in
                            if isActive {
                                isPresented = false
                            }
                        }
                    }) {
                        Text("Start Now")
                            .font(.custom("Inter-Medium", size: 24))
                            .foregroundStyle(.cFFFFFF)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                GradientColors.gradient1horizontal
                            )
                            .clipShape(.rect(cornerRadius: 20))
                    }
                    .padding(.horizontal, 16)
                    
                    HStack {
                        Button {
                            open(url: AppConstants.urlPrivacy)
                        } label: {
                            Text("Privacy Policy")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.cFFFFFF)
                        }
                        Spacer()
                        Text("|")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.cFFFFFF)
                        Spacer()
                        Button {
                            viewModel.purchaseService.restorePurchases{success in
                                if success {
                                    isOnboarding = false
                                }
                            }
                        } label: {
                            Text("Restore")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.cFFFFFF)
                        }
                        Spacer()
                        Text("|")
                            .font(.custom("Inter-Regular", size: 16))
                            .foregroundColor(.cFFFFFF)
                        Spacer()
                        Button {
                            open(url: AppConstants.urlTerms)
                        } label: {
                            Text("Terms of use")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.cFFFFFF)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)
                }
                
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(.ultraThinMaterial)
                        .padding(.vertical, -24)
                        .padding(.bottom, -60)
                )
            }
            .padding(.bottom, -10)
            
        }
        .onAppear {
            viewModel.fetchProducts(paywallId: AppConstants.insidePaywallId)
        }
    }
    
    @ViewBuilder
    func PointsView() -> some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(currentIndex == index ? .cF760FF : .cADAEFF)
                    .frame(width: currentIndex == index ? 12 : 12, height: 12)
                    .animation(.smooth(duration: 0.5, extraBounce: 0), value: currentIndex)
            }
        }
        
    }
}

#Preview {
    SubscriptionScreenView(isPresented: .constant(true))
        .preferredColorScheme(.dark)
}

