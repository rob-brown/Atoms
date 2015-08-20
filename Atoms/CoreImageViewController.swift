//               ~MMMMMMMM,.           .,MMMMMMM ..
//              DNMMDMMMMMMMM,.     ..MMMMNMMMNMMM,
//              MMM..   ...NMMM    MMNMM       ,MMM
//             NMM,        , MMND MMMM          .MM
//             MMN             MMMMM             MMM
//            .MM           , MMMMMM ,           MMM
//            .MM            MMM. MMMM           MMM
//            .MM~         .MMM.   NMMN.         MMM
//             MMM        MMMM: .M ..MMM        .MM,
//             MMM.NNMMMMMMMMMMMMMMMMMMMMMMMMMM:MMM,
//         ,,MMMMMMMMMMMMMMM           NMMDNMMMMMMMMN~,
//        MMMMMMMMM,,  OMMM             NMM  . ,MMNMMMMN.
//     ,MMMND  .,MM=  NMM~    MMMMMM+.   MMM.  NMM. .:MMMMM.
//    MMMM       NMM,MMMD   MMM$ZZZMMM:  .NMN.MMM        NMMM
//  MMNM          MMMMMM   MMZO~:ZZZZMM~   MMNMMN         .MMM
//  MMM           MMMMM   MMNZ~~:ZZZZZNM,   MMMM            MMN.
//  MM.           .MMM.   MMZZOZZZZZZZMM.   MMMM            MMM.
//  MMN           MMMMN   MMMZZZZZZZZZNM.   MMMM            MMM.
//  NMMM         .MMMNMN  .MM$ZZZZZZZMMN ..NMMMMM          MMM
//   MMMMM       MMM.MMM~  .MNMZZZZMMMD   MMM MMM .    . NMMN,
//     NMMMM:  ..MM8  MMM,  . MNMMMM:   .MMM:  NMM  ..MMMMM
//     ...MMMMMMNMM    MMM      ..      MMM.    MNDMMMMM.
//        .: MMMMMMMMMMDMMND           MMMMMMMMNMMMMM
//             NMM8MNNMMMMMMMMMMMMMMMMMMMMMMMMMMNMM
//            ,MMM        NMMMDMMMMM NMM.,.     ,MM
//             MMO        ..MMM    NMMM          MMD
//            .MM.         ,,MMM+.MMMM=         ,MMM
//            .MM.            MMMMMM~.           MMM
//             MM=             MMMMM..          .MMN
//             MMM           MMM8 MMMN.          MM,
//             +MMO        MMMN,   MMMMM,       MMM
//             ,MMMMMMM8MMMMM,      . MMNMMMMMMMMM.
//               .NMMMMNMM              DMDMMMMMM

import UIKit
import CoreImage

class CoreImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    private let context = CIContext()
    private let queue = OperationQueue()
    private var image: UIImage? {
        didSet {
            filterNames.removeAll()
        }
    }
    private var filterNames = Set<String>() {
        didSet {
            filterImage(image, filters: filterNames)
        }
    }
    
    @IBAction func tappedChooseImageButton(sender: UIButton) {
        queue.cancelAllOperations()
        activityIndicator?.stopAnimating()
        
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        showDetailViewController(picker, sender: self)
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        if let filtersViewController = segue.sourceViewController as? FiltersViewController {
            filterNames = filtersViewController.filters
        }
    }
    
    private func filterImage(unfilteredImage: UIImage?, filters: Set<String>) {
        guard let image = unfilteredImage where filters.count > 0 else {
            imageView?.image = unfilteredImage
            return
        }
        
        var operations = [PipeOperation<Image,Image>]()
        
        for filterName in filters {
            if let filter = CIFilter(name: filterName) {
                let operation = CoreImageOperation(image: image, filter: filter)
                operations.append(operation)
            }
        }
        
        operations.append(updateImageOperation())
        activityIndicator?.startAnimating()
        queue.runUniformPipeline(operations)
    }
    
    private func updateImageOperation() -> PipeOperation<Image,Image> {
        return PipeClosureOperation<Image,Image> { image, token in
            // Renders the image in the background.
            backgroundQueue {
                guard let ciImage = image.CoreImageImage() where token.isCanceled() == false else { return }
                let cgImage = self.context.createCGImage(ciImage, fromRect: ciImage.extent)
                let decodedImage = UIImage.predecodedImage(cgImage: cgImage)
                
                // Sets the image on the main queue.
                mainQueue {
                    guard token.isCanceled() == false else { return }
                    self.imageView?.image = decodedImage
                    self.activityIndicator?.stopAnimating()
                }
            }
            return image
        }
    }
}

private func mainQueue(closure: ()->()) {
    if NSThread.isMainThread() {
        closure()
    }
    else {
        dispatch_async(dispatch_get_main_queue(), closure)
    }
}

private func backgroundQueue(queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), closure: ()->()) {
    if NSThread.isMainThread() {
        dispatch_async(queue, closure)
    }
    else {
        closure()
    }
}

extension CoreImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.image = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension UIImage {
    
    public class func predecodedImage(uiImage uiImage: UIImage) -> UIImage? {
        guard let cgImage = uiImage.CGImage else { return nil }
        return predecodedImage(cgImage: cgImage)
    }
    
    public class func predecodedImage(data data: NSData) -> UIImage? {
        guard let provider = CGDataProviderCreateWithCFData(data) else { return nil }
        return predecodedImage(dataProvider: provider)
    }
    
    public class func predecodedImage(dataProvider dataProvider: CGDataProviderRef) -> UIImage? {
        guard let image = CGImageCreateWithPNGDataProvider(dataProvider, nil, false, .RenderingIntentDefault) ??
            CGImageCreateWithJPEGDataProvider(dataProvider, nil, false, .RenderingIntentDefault) else { return nil }
        return predecodedImage(cgImage: image)
    }
    
    public class func predecodedImage(cgImage cgImage: CGImageRef) -> UIImage? {
        let width = CGImageGetWidth(cgImage)
        let height = CGImageGetHeight(cgImage)
        let rect = CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let info = CGImageAlphaInfo.PremultipliedFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue
        let imageContext = CGBitmapContextCreate(nil, width, height, 8, width * 4, colorSpace, info)
        
        CGContextDrawImage(imageContext, rect, cgImage)
        
        guard let bitmap = CGBitmapContextCreateImage(imageContext) else { return nil }
        let image = UIImage(CGImage: bitmap)
        return image
    }
}
