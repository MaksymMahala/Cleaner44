import SwiftUI

struct Contact: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    let identifier: String
    let imageData: Data?
}
