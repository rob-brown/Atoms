import UIKit

public protocol Image {
    func UIKitImage() -> UIImage?
    func CoreImageImage() -> CoreImage.CIImage?
}

extension CoreImage.CIImage: Image {
    public func UIKitImage() -> UIImage? {
        return UIImage(CIImage: self)
    }
    
    public func CoreImageImage() -> CoreImage.CIImage? {
        return self
    }
}

extension UIImage: Image {
    public func UIKitImage() -> UIImage? {
        return self
    }
    
    public func CoreImageImage() -> CoreImage.CIImage? {
        return CoreImage.CIImage(image: self)
    }
}
