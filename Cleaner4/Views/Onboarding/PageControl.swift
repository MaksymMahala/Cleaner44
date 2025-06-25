import SwiftUI

struct PageControl: UIViewRepresentable {
    
    var maxPages: Int
    var currentPage: Int
    
    func makeUIView(context: Context) -> UIPageControl {
        
        let control = UIPageControl()
        control.backgroundStyle = .minimal
        control.numberOfPages = maxPages
        control.currentPage = currentPage
        control.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        control.currentPageIndicatorTintColor = UIColor.white 
        return control
    }

    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }
}
