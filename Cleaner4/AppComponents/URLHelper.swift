import UIKit

func open(url: String) {
   guard let url = URL(string: url) else {
     return
   }

   if #available(iOS 10.0, *) {
       UIApplication.shared.open(url, options: [:], completionHandler: nil)
   } else {
       UIApplication.shared.openURL(url)
   }
}
