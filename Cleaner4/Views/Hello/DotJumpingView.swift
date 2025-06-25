import SwiftUI

struct DotJumpingView: View {
    @State private var currentIndex = 0
    private let colors: [Color] = [.cF647FF, .cADAEFF, .c48CEEA, .c56118B, .cFFFFFF]
    private let animationDuration: Double = 0.3

    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<colors.count, id: \.self) { index in
                Circle()
                    .fill(colors[index])
                    .frame(width: 42, height: 42)
                    .offset(y: currentIndex == index ? -42 : 0)
                    .animation(.easeInOut(duration: animationDuration), value: currentIndex)
            }
        }
        .onAppear {
            startLoop()
        }
    }

    private func startLoop() {
        Timer.scheduledTimer(withTimeInterval: animationDuration + 0.01, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % colors.count
            }
        }
    }
}


#Preview {
    DotJumpingView()
}
