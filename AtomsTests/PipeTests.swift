import XCTest
import Atoms
import CoreLocation

class PipeTests: XCTestCase {
    let queue = OperationQueue()
    
    // MARK: Generic Pipeline
    
    func testDirectToQueue() {
        asyncTest("Test Pipeline") { finish in
            PipeClosureOperation<Int,Void>(1){ n, _ in XCTAssertEqual(n, 1, "Direct to queue failed."); finish(); return () }
                |> self.queue
        }
    }
    
    func testPipeline() {
        asyncTest("Test Pipeline") { finish in
            PipeClosureOperation<Int,Int>(1){ $0 + 1 }
                |> PipeClosureOperation<Int,Int>{ $0 * 3 }
                |> PipeClosureOperation<Int,Int>{ $0 * 2 }
                |> PipeClosureOperation<Int,Int>{ $0 / 2 }
                |> PipeClosureOperation<Int,Void>{ n, _ in XCTAssertEqual(n, 6, "Pipeline failed."); finish(); return () }
                |> self.queue
        }
    }
    
    func testPipelineWithPipedArg() {
        asyncTest("Test Pipeline with Piped Arg") { finish in
            1
                |> PipeClosureOperation<Int,Int>{ $0 + 1 }
                |> PipeClosureOperation<Int,Int>{ $0 * 3 }
                |> PipeClosureOperation<Int,Int>{ $0 * 2 }
                |> PipeClosureOperation<Int,Int>{ $0 / 2 }
                |> PipeClosureOperation<Int,Void>{ n, _ in XCTAssertEqual(n, 6, "Pipeline failed."); finish(); return () }
                |> self.queue
        }
    }
    
    // MARK: Location
    
    func testLocationPipeOperation() {
        asyncTest("Test Location Pipe Operation") { finish in
            LocationPipeOperation(input: kCLLocationAccuracyThreeKilometers)
                |> PipeClosureOperation<CLLocation,Void> { (location: CLLocation) in
                    // Asserts the location is in London, England.
                    // If the simulated location changes in the settings, this test needs to change.
                    XCTAssertEqualWithAccuracy(location.coordinate.latitude, 51.5, accuracy: 0.1)
                    XCTAssertEqualWithAccuracy(location.coordinate.longitude, -0.1, accuracy: 0.1)
                    
                    finish()
                    return ()
                }
                |> self.queue
        }
    }
    
    // MARK: Image
    
    func testImageResize() {
        let imageName = "testImage1.jpg"
        let url = NSBundle(forClass: self.dynamicType).URLForResource(imageName, withExtension: nil)!
        let size = CGSizeMake(100, 100)
        
        asyncTest("Test Scale Operation") { finish in
            ImageReadOperation(input: url)
                |> ImageScaleOperation(size: size)
                |> PipeClosureOperation<UIImage,Void>{ (resizedImage: UIImage) in
                    XCTAssertEqual(resizedImage.size.width, size.width)
                    XCTAssertEqual(resizedImage.size.height, size.height)
                    finish()
                    return ()
                }
                |> self.queue
        }
    }
    
    func testImageScale() {
        let imageName = "testImage1.jpg"
        let url = NSBundle(forClass: self.dynamicType).URLForResource(imageName, withExtension: nil)!
        let image = UIImage(contentsOfFile: url.path!)!
        let scale = CGFloat(0.5)
        
        asyncTest("Test Resize Operation") { finish in
            ImageReadOperation(input: url)
                |> ImageScaleOperation(scale: scale)
                |> PipeClosureOperation<UIImage,Void>{ (scaledImage: UIImage) in
                    XCTAssertEqual(scaledImage.size.width, image.size.width * scale)
                    XCTAssertEqual(scaledImage.size.height, image.size.height * scale)
                    finish()
                    return ()
                }
                |> self.queue
        }
    }
    
//    func testCoreImage() {
//        let imageName = "testImage1.jpg"
//        let url = NSBundle(forClass: self.dynamicType).URLForResource(imageName, withExtension: nil)!
//        let image = UIImage(contentsOfFile: url.path!)!
//        let filter = CIFilter(name: "CISepiaTone")!
//        
//        asyncTest("Test Resize Operation") { finish in
//            ImageReadOperation(input: url)
//                |> CoreImageOperation(filter: filter)
//                |> PipeClosureOperation<Image,Void>{ input in
//                    let filteredImage = input.UIKitImage()!
//                    XCTAssertEqual(filteredImage.size.width, image.size.width)
//                    XCTAssertEqual(filteredImage.size.height, image.size.height)
//                    XCTAssertNotEqual(filteredImage, image)
//                    finish()
//                    return ()
//                }
////                |> self.queue
//        }
//    }
}
