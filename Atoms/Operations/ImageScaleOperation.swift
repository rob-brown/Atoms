import Foundation
import UIKit

public class ImageScaleOperation: PipeOperation<UIImage,UIImage> {
    
    private let size: CGSize?
    private let scale: CGFloat?
    
    public init(image: UIImage? = nil, size: CGSize) {
        self.size = size
        self.scale = nil
        super.init(input: image)
    }
    
    public init(image: UIImage? = nil, scale: CGFloat) {
        self.size = nil
        self.scale = scale
        super.init(input: image)
    }
    
    public override func executeSync(input: UIImage) -> UIImage? {
        guard let newSize = size ?? scaledSize(input, scale: scale) else { return nil }
        return input.resize(newSize)
    }
    
    private func scaledSize(image: UIImage, scale: CGFloat?) -> CGSize? {
        guard let scale = scale else { return nil }
        return CGSizeMake(image.size.width * scale, image.size.height * scale)
    }
}
