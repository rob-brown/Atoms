import XCTest

extension XCTestCase {
    
    public func asyncTest(_ name: String = "Test", duration: TimeInterval = 10, closure: (()->())->()) {
        let expectation = self.expectation(description: name)
        
        closure {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: duration) { error in
            XCTAssertNil(error, "Failed \(name)")
        }
    }
}

