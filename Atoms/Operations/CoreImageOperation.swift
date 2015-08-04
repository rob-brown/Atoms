import UIKit
import CoreImage

public class CoreImageOperation: PipeOperation<UIImage,UIImage> {
    private let filter: CIFilter
    
    public init(image: UIImage? = nil, filter: CIFilter) {
        self.filter = filter
        super.init(input: image)
    }
    
    public override func executeSync(input: UIImage) -> UIImage? {
        guard let inputImage = CIImage(image: input) else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        let filteredImage = filter.outputImage
        return UIImage(CIImage: filteredImage)
    }
}
