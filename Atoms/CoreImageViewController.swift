//
//  CoreImageViewController.swift
//  Atoms
//
//  Created by Robert Brown on 8/4/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit
import CoreImage

class CoreImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    private let context = CIContext()
    private let queue = OperationQueue()
    private var image: UIImage? {
        didSet {
            filterImage(image, filters: filterNames)
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
    
    private func filterImage(image: UIImage?, filters: Set<String>) {
        guard let image = image else { return }
        
        // If no filters, just show the unfiltered image.
        if filters.count == 0 {
            imageView?.image = image
            return
        }
        
        activityIndicator?.startAnimating()
        
        // ???: Should the operation pipelining be encapsulated into a function?
        // I could give the function a list of operations and a queue.
        
//        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            var firstOperation: CoreImageOperation?
            var previousSeries: PipeSeries<Image,Image,Image,Image>?
            
            for filterName in filters {
                if let filter = CIFilter(name: filterName) {
                    let operation = CoreImageOperation(image: image, filter: filter)
                    if let previous = previousSeries {
                        previousSeries = previous |> operation
                    }
                    else if let firstOperation = firstOperation {
                        previousSeries = firstOperation |> operation
                    }
                    else {
                        firstOperation = operation
                    }
                }
            }
            
            if let previousSeries = previousSeries {
                previousSeries
                    |> self.updateImageOperation()
                    |> self.queue
            }
            else if let firstOperation = firstOperation {
                firstOperation
                    |> self.updateImageOperation()
                    |> self.queue
//            }
        }
    }
    
    private func updateImageOperation() -> PipeOperation<Image,Void> {
        return PipeClosureOperation<Image,Void> { image in
            // Renders the image in the background.
            backgroundQueue {
                if let ciImage = image.CoreImageImage() {
                    let cgImage = self.context.createCGImage(ciImage, fromRect: ciImage.extent)
                    let uiImage = UIImage(CGImage: cgImage)
                    let decodedImage = uiImage.predecodedImage()
                    
                    // Sets the image on the main queue.
                    mainQueue {
                        self.imageView?.image = decodedImage
                        self.activityIndicator?.stopAnimating()
                    }
                }
            }
            return ()
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
    
    public func predecodedImage() -> UIImage? {
        return UIImagePNGRepresentation(self).flatMap(UIImage.predecodedImage)
    }
    
    public class func predecodedImage(data: NSData) -> UIImage? {
        return CGDataProviderCreateWithCFData(data).flatMap(imageWithDataProvider)
    }
    
    public class func imageWithDataProvider(dataProvider: CGDataProviderRef) -> UIImage? {
        
        let cgImage = CGImageCreateWithPNGDataProvider(dataProvider, nil, false, .RenderingIntentDefault) ??
            CGImageCreateWithJPEGDataProvider(dataProvider, nil, false, .RenderingIntentDefault)
        
        if let cgImage = cgImage {
            let width = CGImageGetWidth(cgImage)
            let height = CGImageGetHeight(cgImage)
            let rect = CGRectMake(0.0, 0.0, CGFloat(width), CGFloat(height))
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let info = CGImageAlphaInfo.PremultipliedFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue
            let imageContext = CGBitmapContextCreate(nil, width, height, 8, width * 4, colorSpace, info)
            
            CGContextDrawImage(imageContext, rect, cgImage)
            
            if let outputImage = CGBitmapContextCreateImage(imageContext) {
                let image = UIImage(CGImage: outputImage)
                return image
            }
        }
        
        return nil
    }
}
