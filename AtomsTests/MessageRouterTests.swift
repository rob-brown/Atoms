import XCTest
@testable import Atoms

class MessageRouterTests: XCTestCase {
    private var router: MessageRouter<Int>!
    
    override func setUp() {
        super.setUp()
        router = MessageRouter<Int>()
    }
    
    func testAddFunction() {
        XCTAssertEqual(router.copyEntries().count, 0)
        router.add { _ in }
        XCTAssertEqual(router.copyEntries().count, 1)
    }
    
    func testAddRecipient() {
        XCTAssertEqual(router.copyEntries().count, 0)
        let recipient = MessageRouterTestHelper()
        router.add(recipient, recipient.dynamicType.doNothing)
        XCTAssertEqual(router.copyEntries().count, 1)
    }
    
    func testRemoveFunction() {
        XCTAssertEqual(router.copyEntries().count, 0)
        let entry = router.add { _ in }
        XCTAssertEqual(router.copyEntries().count, 1)
        router.remove(entry)
        XCTAssertEqual(router.copyEntries().count, 0)
    }
    
    func testRemoveRecipient() {
        XCTAssertEqual(router.copyEntries().count, 0)
        let recipient = MessageRouterTestHelper()
        let entry = router.add(recipient, recipient.dynamicType.doNothing)
        XCTAssertEqual(router.copyEntries().count, 1)
        router.remove(entry)
        XCTAssertEqual(router.copyEntries().count, 0)
    }
    
    func testSend() {
        // Sends a varying number of messages to a varying number of recipients.
        for recipientCount in 0...3 {
            for messageCount in 0...3 {
                send(recipientCount: recipientCount, messageCount: messageCount)
            }
        }
    }
    
    func testSendAfterRemove() {
        let entry = router.add { _ in XCTFail("Should not be called") }
        router.remove(entry)
        router.send(42)
    }
    
    func testSendTuple() {
        var count = 0
        let tupleRouter = MessageRouter<(String, Int)>()
        tupleRouter.add { (_: String, _: Int) in count++ }
        tupleRouter.send(("Hello", 42))
        XCTAssertEqual(count, 1)
    }
    
    func testSendAfterDeinit() {
        let expectation = expectationWithDescription("testSendAfterDeinit")
        
        // Dispatches to another queue to create a new scope.
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            
            // Creates a recipient in this scope.
            let recipient = MessageRouterTestHelper()
            self.router.add(recipient, recipient.dynamicType.fail)
            
            // Dispatches again to create a new scope without the recipient.
            dispatch_async(queue) {
                // Sends a message that won't be received because the recipient deinited.
                self.router.send(42)
                expectation.fulfill()
            }
            
            // The recipient will get deinited here.
        }
        
        waitForExpectationsWithTimeout(3) { error in XCTAssertNil(error, "testSendAfterDeinit timed out") }
    }
    
    // MARK: - Helpers
    
    private func send(recipientCount recipientCount: Int, messageCount: Int) {
        var count = 0
        let message = 42
        
        // Adds n recipients.
        if recipientCount > 0 {
            for _ in 1...recipientCount {
                router.add { n in count++; XCTAssertEqual(n, message) }
            }
        }
        
        // Sends m messages to n recipients.
        if messageCount > 0 {
            for _ in 1...messageCount {
                router.send(message)
            }
        }
        
        XCTAssertEqual(count, recipientCount * messageCount, "Failed to send \(messageCount) message(s) each to \(recipientCount) recipient(s).")
    }
}

private class MessageRouterTestHelper {
    
    private func fail(_: Int) {
        XCTFail("Should not be called.")
    }
    
    private func doNothing(_: Int) {}
}
