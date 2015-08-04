import UIKit

extension UIImage {
    
    func resize(size: CGSize, opaque: Bool = false) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
        let rect = CGRectMake(0, 0, size.width, size.height)
        drawInRect(rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
