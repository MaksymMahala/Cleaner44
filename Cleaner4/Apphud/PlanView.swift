import Foundation
import SwiftUI

struct PlanView: View {
    
    // MARK: - Properties
    let planType: String
    let planPrice: String
    let planWeeklyPrice: String
    let planIsSelected: Bool
    let planIsOffer: Bool
    let popular: Bool
    let best: Bool
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .top) {
                VStack(alignment: .center, spacing: 4) {
                    
                    Text(planType)
                        .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(planIsSelected ? .cFFFFFF : .cE1DFFF)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Text(planPrice)
                        .font(.custom("Inter-SemiBold", size: 12))
                        .foregroundColor(planIsSelected ? .cFFFFFF : .cE1DFFF)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(planWeeklyPrice)
                        .font(.custom("Inter-Regular", size: 11))
                        .foregroundColor(planIsSelected ? .cFFFFFF : .cADAEFF)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(.clear)
                .cornerRadius(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            planIsSelected ? GradientColors.gradient1vertical : GradientColors.gradientStroke,
                            lineWidth: 1
                        )
                    
                }
                
            }
        }
    }
}

struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            PlanView(planType: "Weekly", planPrice: "$55/Week", planWeeklyPrice: "$55/Week", planIsSelected: false, planIsOffer: true, popular: false, best: true)
            
            PlanView(planType: "Monthly", planPrice: "$55/Week", planWeeklyPrice: "$55/Week", planIsSelected: true, planIsOffer: true, popular: true, best: false)
            
            PlanView(planType: "Yeraly", planPrice: "$55/Week", planWeeklyPrice: "$55/Week", planIsSelected: false, planIsOffer: true, popular: false, best: false)
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .background(.black)
    }
}
