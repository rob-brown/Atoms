import XCTest

extension XCTestCase {
    
    public func asyncTest(name: String = "Test", duration: NSTimeInterval = 10, closure: (()->())->()) {
        let expectation = expectationWithDescription(name)
        
        closure {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(duration) { error in
            XCTAssertNil(error, "Failed \(name)")
        }
    }
}

