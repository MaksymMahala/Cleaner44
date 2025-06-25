import SwiftUI

struct StorageView: View {
    @ObservedObject var viewModel: StorageUsageViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                (
                    Text("\(viewModel.usedDiskSpaceReadable) Gb ")
                        .font(.custom("Inter-SemiBold", size: 16))
                        .foregroundColor(.cFFFFFF)
                    +
                    Text("used from \(viewModel.totalDiskSpaceReadable) Gb")
                        .font(.custom("Inter-Medium", size: 12))
                        .foregroundColor(.cFFFFFF.opacity(0.4))
                )
                Spacer()
                Text("\(viewModel.usedDiskSpacePercentageFormatted) used")
                    .font(.custom("Inter-Medium", size: 16))
                    .foregroundColor(.cFFFFFF)
            }
            
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.cFFFFFF.opacity(0.2))
                    .frame(height: 17)
                
                GeometryReader { geometry in
                    GradientColors.gradient3horizontal
                        .frame(width: geometry.size.width * CGFloat(viewModel.usedDiskSpacePercentage))
                        .cornerRadius(24)
                }
                .frame(height: 17)
            }
            .frame(height: 17)
            
        }
        .padding()
        .background(.c56118B.opacity(0.4))
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    StorageView(viewModel: StorageUsageViewModel())
        .preferredColorScheme(.dark)
}

