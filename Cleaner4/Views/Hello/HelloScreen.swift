import SwiftUI

struct HelloScreen: View {
    @Binding var isPresented: Bool
    @StateObject var viewModel: AppHUDViewModel = AppHUDViewModel()
    
    var body: some View {
        ZStack {
            Image("mainBg")
                .resizable()
                .ignoresSafeArea()
            
            DotJumpingView()
        }
        .onAppear {
            self.startTimer()
            viewModel.purchaseService.activate()
            viewModel.purchaseService.setDevice()
        }
    }
    private func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isPresented = false
        }
    }
}

#Preview {
    HelloScreen(isPresented: .constant(true))
}


