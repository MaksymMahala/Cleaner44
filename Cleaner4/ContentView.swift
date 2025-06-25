import SwiftUI

struct ContentView: View {
    @State private var isHelloScreenPresented = true
    @AppStorage("isOnboardingCleaner") var isOnboarding: Bool = true
    @ObservedObject private var viewModel = CleanerViewModel()
    @ObservedObject private var storageviewModel = StorageUsageViewModel()

    var body: some View {
        if !isHelloScreenPresented {
            if isOnboarding {
                OnBoardingView()
            } else {
                NavigationScreen(viewModel: viewModel, storageviewModel: storageviewModel)
            }
        }   else {
            HelloScreen(isPresented: $isHelloScreenPresented)
        }
    }
}

#Preview {
    ContentView()
}
