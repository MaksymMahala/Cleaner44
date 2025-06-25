import SwiftUI

struct NavigationScreen: View {
    @State private var activeTab: TabModel = .home
    var offsetObserver = PageOffsetObserver()
    @ObservedObject var viewModel: CleanerViewModel
    @ObservedObject var storageviewModel: StorageUsageViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("mainBg")
                    .resizable()
                    .ignoresSafeArea()
                
                //Tab View
                TabView(selection: $activeTab ){
                    ForEach(TabModel.allCases, id: \.self) { tab in
                        tab.controller(activeTab: $activeTab, viewModel: viewModel, storageViewModel: storageviewModel)
                            .tag(tab)
                            .background {
                                if !offsetObserver.isObserving && tab == .home {
                                    FindCollectionView {
                                        offsetObserver.collionView = $0
                                        offsetObserver.observe()
                                    }
                                }
                            }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                
                ZStack {
                    VStack(spacing: 0) {
                        HStack {
                            Text(activeTab.title)
                                .font(.custom("Inter-SemiBold", size: 24))
                                .foregroundStyle(Color.cFFFFFF)
                                .frame(height: 38)
                            Spacer()
                            if !PurchaseManager.instance.userPurchaseIsActive {
                                Button(action: {
                                    viewModel.showSubscriptionScreenView = true
                                }, label: {
                                    Image("crown")
                                })
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        Spacer()
                        
                        //Tab Bar
                        Tabbar()
                            .padding(.bottom, 16)
                            .background(.ultraThinMaterial)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    
                }
            }
            .onAppear {

            }
            
        }
        .fullScreenCover(isPresented: $viewModel.showSubscriptionScreenView) {
            SubscriptionScreenView(isPresented: $viewModel.showSubscriptionScreenView)
        }
    }
    
    @ViewBuilder
    func Tabbar() -> some View {
        HStack(spacing: 0) {
            ForEach(TabModel.allCases, id: \.rawValue) { tab in
                ZStack {
                    if activeTab == tab {
                        Color.cFFFFFF.opacity(0.2)
                            .frame(maxWidth: .infinity, maxHeight: 63)
                            .cornerRadius(20)
                    }
                    
                    VStack(spacing: 8) {
                        Image(tab.rawValue)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(activeTab == tab ? GradientColors.gradientPink : GradientColors.gradient2vertical)
                            .opacity(activeTab == tab ? 1 : 0.4)
                        
                        Text(tab.rawValue)
                            .font(.custom("Inter-Medium", size: 12))
                            .foregroundStyle(.cFFFFFF)
                            .opacity(activeTab == tab ? 1 : 0.4)
                        
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                
                .onTapGesture {
                    withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                        activeTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        
    }
}

#Preview {
    NavigationScreen(viewModel: CleanerViewModel(), storageviewModel: StorageUsageViewModel())
        .preferredColorScheme(.dark)
    
}
