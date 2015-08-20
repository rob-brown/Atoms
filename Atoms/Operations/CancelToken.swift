import Dispatch

public class CancelToken {
    /// Synchronization queue. Not to be accessed directly.
    /// See `syncRead` and `syncWrite`.
    private let queue = dispatch_queue_create("com.robertbrown.CancelToken", DISPATCH_QUEUE_CONCURRENT)
    
    /// Flag indicating if the token is canceled.
    private var canceled = false
    
    /// Returns true if the token is canceled.Not to be accessed directly.
    /// See `syncRead` and `syncWrite`.
    public func isCanceled() -> Bool {
        var cancelled = false
        syncRead {
            cancelled = self.canceled
        }
        
        return cancelled
    }
    
    /// Cancels the token.
    public func cancel() {
        if !canceled {
            syncWrite {
                self.canceled = true
            }
        }
    }
    
    /// Helper function for synchronously reading from the canceled state.
    private func syncRead(closure: ()->()) {
        dispatch_sync(queue, closure)
    }
    
    /// Helper function for synchronously writing to the canceled state.
    private func syncWrite(closure: ()->()) {
        dispatch_barrier_sync(queue, closure)
    }
}
