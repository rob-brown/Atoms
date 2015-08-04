import XCTest
@testable import Atoms

class RecipientListTests: XCTestCase {
    private var recipients: RecipientList<Int>!
    
    override func setUp() {
        super.setUp()
        recipients = RecipientList<Int>()
    }
    
    func testAddFunction() {
        XCTAssertEqual(recipients.copyEntries().count, 0)
        recipients.add { _ in }
        XCTAssertEqual(recipients.copyEntries().count, 1)
    }
    
    func testAddRecipient() {
        XCTAssertEqual(recipients.copyEntries().count, 0)
        let recipient = RecipientListTestHelper()
        recipients.add(recipient, recipient.dynamicType.doNothing)
        XCTAssertEqual(recipients.copyEntries().count, 1)
    }
    
    func testRemoveFunction() {
        XCTAssertEqual(recipients.copyEntries().count, 0)
        let entry = recipients.add { _ in }
        XCTAssertEqual(recipients.copyEntries().count, 1)
        recipients.remove(entry)
        XCTAssertEqual(recipients.copyEntries().count, 0)
    }
    
    func testRemoveRecipient() {
        XCTAssertEqual(recipients.copyEntries().count, 0)
        let recipient = RecipientListTestHelper()
        let entry = recipients.add(recipient, recipient.dynamicType.doNothing)
        XCTAssertEqual(recipients.copyEntries().count, 1)
        recipients.remove(entry)
        XCTAssertEqual(recipients.copyEntries().count, 0)
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
        let entry = recipients.add { _ in XCTFail("Should not be called") }
        recipients.remove(entry)
        recipients.send(42)
    }
    
    func testSendTuple() {
        var count = 0
        let recipientList = RecipientList<(String, Int)>()
        recipientList.add { (_: String, _: Int) in count++ }
        recipientList.send(("Hello", 42))
        XCTAssertEqual(count, 1)
    }
    
    func testSendAfterDeinit() {
        let expectation = expectationWithDescription("testSendAfterDeinit")
        
        // Dispatches to another queue to create a new scope.
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            
            // Creates a recipient in this scope.
            let recipient = RecipientListTestHelper()
            self.recipients.add(recipient, recipient.dynamicType.fail)
            
            // Dispatches again to create a new scope without the recipient.
            dispatch_async(queue) {
                // Sends a message that won't be received because the recipient deinited.
                self.recipients.send(42)
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
                recipients.add { n in count++; XCTAssertEqual(n, message) }
            }
        }
        
        // Sends m messages to n recipients.
        if messageCount > 0 {
            for _ in 1...messageCount {
                recipients.send(message)
            }
        }
        
        XCTAssertEqual(count, recipientCount * messageCount, "Failed to send \(messageCount) message(s) each to \(recipientCount) recipient(s).")
    }
}

private class RecipientListTestHelper {
    
    private func fail(_: Int) {
        XCTFail("Should not be called.")
    }
    
    private func doNothing(_: Int) {}
}
