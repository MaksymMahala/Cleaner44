import SwiftUI

struct BannerView: View {
    @ObservedObject var viewModel: CleanerViewModel
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Image("banerImage")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 143)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("BECOME PRO")
                        .font(.custom("Inter-Black", size: 24))
                        .foregroundStyle(Color.cFFFFFF)
                        .shadow(color: .c000000.opacity(0.25), radius: 8, x: 0, y: 4)
                    Text("Unlock all premium\nfeatures and enjoy total\ncontrol over app")
                        .font(.custom("Inter-Medium", size: 18))
                        .foregroundColor(Color.cFFFFFF)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding(.horizontal, 8)
        }
        .background(GradientColors.gradient1vertical)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 16)
        .onTapGesture {
            viewModel.showSubscriptionScreenView = true
        }
    }
}

#Preview {
    BannerView(viewModel: CleanerViewModel())
        .preferredColorScheme(.dark)
}
