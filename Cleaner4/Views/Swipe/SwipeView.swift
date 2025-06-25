import SwiftUI
import Photos

struct SwipeView: View {
    let month: String
    let assets: [PHAsset]
    @ObservedObject var storageViewModel: StorageUsageViewModel
    @ObservedObject var cleanerViewModel: CleanerViewModel
    @State private var currentIndex: Int = 0
    @Namespace private var animation
    @Environment(\.presentationMode) var presentationMode
    @State private var animationDirection: SwipeDirection = .forward
    @State private var openTrash = false
    
    enum SwipeDirection {
        case forward, backward
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("mainBg")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("backButton")
                    }
                    Text(month)
                        .font(.custom("Inter-SemiBold", size: 24))
                        .foregroundColor(.cFFFFFF)
                    Spacer()
                    if !PurchaseManager.instance.userPurchaseIsActive {
                        Button(action: {
                            cleanerViewModel.showSubscriptionScreenView = true
                        }, label: {
                            Image("crown")
                        })
                    }
                }
                .padding(.horizontal)
                
                let swipeGesture = DragGesture()
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        if horizontalAmount < -50 {
                            // Swipe left
                            markForDeletion()
                        } else if horizontalAmount > 50 {
                            // Swipe right
                            skipOrRestore()
                        }
                    }
                
                let content = ZStack(alignment: .bottom) {
                    if currentIndex < assets.count {
                        ForEach(assets.indices, id: \.self) { index in
                            if index == currentIndex {
                                let asset = assets[index]
                                AssetImageView(asset: asset)
                                    .matchedGeometryEffect(id: asset.localIdentifier, in: animation)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: animationDirection == .forward ? .trailing : .leading),
                                        removal: .move(edge: animationDirection == .forward ? .leading : .trailing))
                                    )
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(.clear)
                                    .padding(.horizontal)
                            }
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.clear)
                            .frame(height: UIScreen.main.bounds.height * 0.7)
                            .padding(.horizontal)
                    }
                    
                    HStack(spacing: 24) {
                        Button(action: {
                            markForDeletion()
                        }) {
                            Image("markForDeletion")
                        }
                        
                        Button(action: {
                            skipOrRestore()
                        }) {
                            Image("skipOrRestore")
                        }
                    }
                    .padding(24)
                }
                
                    .animation(.easeInOut, value: currentIndex)
                    .gesture(swipeGesture)
                
                content
                
                HStack(spacing: 8) {
                    Text("\(storageViewModel.trash.count)")
                        .font(.custom("Inter-SemiBold", size: 40))
                        .foregroundColor(.cFFFFFF)
                    Text("Images in\nthe trash")
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(.cFFFFFF)
                    Spacer()
                    Button(action: {
                        
                        openTrash = true
                    }) {
                        Image("openTrash")
                    }
                }
                .padding()
                .background(Color.c310057.opacity(0.4))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $openTrash) {
            TrashView(storageViewModel: storageViewModel, cleanerViewModel: cleanerViewModel)
        }
    }
    
    private func markForDeletion() {
        if currentIndex < assets.count {
            let id = assets[currentIndex].localIdentifier
            storageViewModel.trash.insert(id)
            animationDirection = .forward
            withAnimation {
                currentIndex += 1
            }
        }
    }
    
    private func skipOrRestore() {
        if currentIndex < assets.count {
            let id = assets[currentIndex].localIdentifier
            storageViewModel.trash.remove(id)
            animationDirection = .backward
            withAnimation {
                currentIndex += 1
            }
        }
    }
}
