import SwiftUI

struct NextButtonView: View {
    
    @AppStorage("isOnboardingCleaner") var isOnboarding: Bool?
    @Binding var currentIndex: Int
    @State var goNext = false
    var itemCount: Int
    var purchasePlanAction:(()->Void)?
    
    var body: some View {
        Button(action: {
            withAnimation {
                if currentIndex < itemCount - 1 {
                    currentIndex += 1
                } else {
                    purchasePlanAction?()
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
        .accentColor(.white)
        .fullScreenCover(isPresented: $goNext, content: {
        })
    }
}

#Preview {
    NextButtonView(currentIndex: .constant(0), itemCount: 4)
        .preferredColorScheme(.light)
}
