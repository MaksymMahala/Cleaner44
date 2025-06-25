import SwiftUI

enum TabModel: String, CaseIterable {
    case setting = "Setting"
    case contacts = "Contacts"
    case swipe = "Swipe"
    case home = "Home"
    
    func controller(activeTab: Binding<TabModel>, viewModel: CleanerViewModel, storageViewModel: StorageUsageViewModel) -> AnyView {
            switch self {
            case .setting:
                return AnyView(SettingsView(viewModel: viewModel))
            case .contacts:
                return AnyView(ContactsView(viewModel: viewModel))
            case .swipe:
                return AnyView(SwipeMonthView(cleanerViewModel: viewModel, storageViewModel: storageViewModel))
            case .home:
                return AnyView(HomeView(storageViewModel: storageViewModel, cleanerViewModel: viewModel))
            }
        }
    
    var title: String {
        switch self {
        case .home: return "Storage"
        case .swipe: return "Swipe Photos"
        case .contacts: return "Contacts Cleaner"
        case .setting: return "Setting"
        }
    }
}

