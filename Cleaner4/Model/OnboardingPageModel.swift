import Foundation
import SwiftUI

// MARK: - Onboarding DATA MODEL

struct OnboardingPage: Identifiable, Hashable {
    var id = UUID().uuidString
    var title: String
    var headline: String
    var image: String
}
