import UIKit
import CoreImage

public class CoreImageOperation: PipeOperation<Image,Image> {
    private let filter: CIFilter
    
    public init(image: Image? = nil, filter: CIFilter) {
        self.filter = filter
        super.init(input: image)
    }
    
    public override func executeSync(input: Image) -> Image? {
        guard let inputImage = input.CoreImageImage() else { return nil }
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        return filter.outputImage
    }
}
