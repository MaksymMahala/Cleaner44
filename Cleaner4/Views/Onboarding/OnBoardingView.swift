import SwiftUI
import AdServices
import ApphudSDK

struct OnBoardingView: View {
    
    var pages: [OnboardingPage] = onboardingData
    @State private var currentIndex = 0
    @State private var selectedTab: OnboardingPage = onboardingData[0]
    @ObservedObject var subscriptinoManager = AppHUDViewModel()
    @AppStorage("isOnboardingCleaner") var isOnboarding: Bool?
    @Environment(\.requestReview) var requestReview
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                Image("mainBg")
                    .resizable()
                    .ignoresSafeArea()
                
                TabView(selection: $currentIndex) {
                    ForEach(pages.indices, id: \.self) { index in
                        VStack {
                            Image(pages[index].image)
                                .resizable()
                                .scaledToFill()
                            Spacer()
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .ignoresSafeArea(edges: [.all])
                
                VStack(){
                    
                    Spacer()
                    
                    VStack(spacing: 24) {
                        IndicatorSView()
                        
                        VStack(spacing: 12) {
                            Text(pages[currentIndex].title)
                                .font(.custom("Inter-Black", size: 30))
                                .foregroundColor(.cFFFFFF)
                                .multilineTextAlignment(.center)
                            
                            headlineView(for: pages[currentIndex].headline)
                        }
                        
                        NextButtonView(currentIndex: $currentIndex, itemCount: pages.count) {
                            if subscriptinoManager.purchaseService.userPurchaseIsActive {
                                isOnboarding = false
                            } else {
                                if let products = subscriptinoManager.products.first {
                                    subscriptinoManager.purchaseService.purchase(products.productId) { Error, isActive in
                                        if isActive {
                                            isOnboarding = false
                                        }
                                    }
                                }
                            }
                        }
                        
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
                                subscriptinoManager.purchaseService.restorePurchases{success in
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
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(.ultraThinMaterial)
                            .padding(.vertical, -24)
                            .padding(.bottom, -60)
                    )
                }
            }
            .onAppear {
                trackAppleSearchAds()
                
                subscriptinoManager.fetchProducts(paywallId: AppConstants.onboardingPaywallId)
            }
            .onChange(of: currentIndex) { _, currentIndex in
                if currentIndex == 2 {
                    requestReview()
                }
            }
        }
    }
    
    @ViewBuilder
    func IndicatorSView() -> some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(currentIndex == index ? .cF760FF : .cADAEFF)
                    .frame(width: currentIndex == index ? 12 : 12, height: 12)
                    .animation(.smooth(duration: 0.5, extraBounce: 0), value: currentIndex)
            }
        }
    }
    
    @ViewBuilder
    func headlineView(for headline: String) -> some View {
        let fullText = "Start using the full app functionality with a risk-free 3-days free trial, then for $7,99 per week or proceed with a limited version"
        let activeText = "proceed with a limited version"
        
        if headline == fullText {
            let textBefore = fullText.components(separatedBy: activeText).first ?? ""
            let textAfter = fullText.components(separatedBy: activeText).last ?? ""
            
            VStack(spacing: 0) {
                Text(textBefore)
                    .foregroundColor(.cFFFFFF)
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(.cFFFFFF)
                Text(activeText)
                    .foregroundColor(Color.c48CEEA)
                    .font(.custom("Inter-Medium", size: 16))
                    .onTapGesture {
                        isOnboarding = false
                    }
                
                Text(textAfter)
                    .foregroundColor(.cFFFFFF)
                    .font(.custom("Inter-Medium", size: 16))
            }
            .multilineTextAlignment(.center)
        } else {
            Text(headline)
                .foregroundColor(Color.cFFFFFF)
                .font(.custom("Inter-Medium", size: 16))
                .multilineTextAlignment(.center)
        }
    }
    
    func trackAppleSearchAds() {
        Task {
            if let asaToken = try? AAAttribution.attributionToken() {
                Apphud.setAttribution(data: nil, from: .appleAdsAttribution, identifer: asaToken, callback: nil)
            }
        }
    }
}

#Preview {
    OnBoardingView()
        .preferredColorScheme(.dark)
}

