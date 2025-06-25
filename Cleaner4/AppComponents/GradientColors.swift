import SwiftUI

struct GradientColors {
    static let gradient1horizontal = LinearGradient(
        colors: [.cF647FF, .cADAEFF],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let gradient1vertical = LinearGradient(
        colors: [.cF647FF, .cADAEFF],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradientStroke = LinearGradient(
        colors: [.cE1DFFF, .cE1DFFF],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradient2vertical = LinearGradient(
        colors: [.cFFFFFF, .c56118B],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradient3horizontal = LinearGradient(
        colors: [.cF647FF, .c89C0FF],
        startPoint: .trailing,
        endPoint: .leading
    )
    
    static let gradientPink = LinearGradient(
        colors: [.cFF78DC, .cFF78DC],
        startPoint: .top,
        endPoint: .bottom
    )
    
}
