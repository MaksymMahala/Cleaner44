import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: CleanerViewModel
    @State private var showResetAlert = false
    @ObservedObject var subscriptinoManager = AppHUDViewModel()
    @AppStorage("isOnboardingCleaner") var isOnboarding: Bool?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 40)
                
                if !PurchaseManager.instance.userPurchaseIsActive {
                    BannerView(viewModel: viewModel)
                        .padding(.top, 24)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - General Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("General")
                                .font(.custom("Inter-Medium", size: 18))
                                .foregroundColor(Color.cFFFFFF)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                Button {
                                    subscriptinoManager.purchaseService.restorePurchases{success in
                                        if success {
                                            isOnboarding = false
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image("Restore")
                                        Text("Restore")
                                            .font(.custom("Inter-Regular", size: 24))
                                            .foregroundColor(Color.cFFFFFF)
                                        Spacer()
                                        Image("chevron")
                                    }
                                }
                                .padding()
                                
                                Divider()
                                    .background(GradientColors.gradient1vertical)
                                
                                LinkRow(title: "Subscription", url: AppConstants.urlSubscription, systemImage: "Subscription")
                                    .padding()
                                Divider()
                                    .background(GradientColors.gradient1vertical)
                                
                                LinkRow(title: "Privacy policy", url: AppConstants.urlPrivacy, systemImage: "Privacy")
                                    .padding()
                                Divider()
                                    .background(GradientColors.gradient1vertical)
                                
                                LinkRow(title: "Terms of use", url: AppConstants.urlTerms, systemImage: "Terms")
                                    .padding()
                            }
                            .background(.c17042F.opacity(0.4))
                            .cornerRadius(20)
                            .shadow(color: .c000000.opacity(0.15), radius: 8, x: 4, y: 4)
                            
                        }
                        
                        // MARK: - About Us Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Review")
                                .font(.custom("Inter-Medium", size: 18))
                                .foregroundColor(Color.cFFFFFF)
                                .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                LinkRow(title: "Support", url: AppConstants.urlContact, systemImage: "Support")
                                    .padding()
                                
                                Divider()
                                    .background(GradientColors.gradient1vertical)
                                
                                LinkRow(title: "Rate Us", url: AppConstants.urlRate, systemImage: "Rate")
                                    .padding()
                                
                                Divider()
                                    .background(GradientColors.gradient1vertical)
                                
                                LinkRow(title: "Share", url: AppConstants.urlShare, systemImage: "Share")
                                    .padding()
                            }
                            .background(.c17042F.opacity(0.4))
                            .cornerRadius(20)
                            .shadow(color: .c000000.opacity(0.15), radius: 8, x: 4, y: 4)
                        }
                    }
                    .padding()
                    
                    Spacer()
                        .frame(height: 80)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: CleanerViewModel())
        .preferredColorScheme(.dark)
}
