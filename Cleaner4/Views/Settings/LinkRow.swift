import SwiftUI

struct LinkRow: View {
    let title: String
    let url: String
    let systemImage: String
    
    var body: some View {
        NavigationLink(destination: WebView(urlString: url)) {
            HStack {
                Image(systemImage)
                Text(title)
                    .font(.custom("Inter-Regular", size: 24))
                    .foregroundColor(Color.cFFFFFF)
                Spacer()
                Image("chevron")
            }
        }
    }
}
