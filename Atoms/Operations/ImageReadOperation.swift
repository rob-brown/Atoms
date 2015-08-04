import Foundation
import UIKit

public class ImageReadOperation: PipeOperation<NSURL,UIImage> {
    
    public override init(input: NSURL?) {
        super.init(input: input)
    }
    
    public override func executeSync(input: NSURL) -> UIImage? {
        guard let path = input.path else { return nil }
        return UIImage(contentsOfFile: path)
    }
}
