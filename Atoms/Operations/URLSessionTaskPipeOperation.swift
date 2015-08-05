import Foundation

private var URLSessionTaksOperationKVOContext = 0

public class URLSessionTaskPipeOperation: PipeOperation<NSURLSessionTask,Void> {
    
    private var task: NSURLSessionTask? = nil
    
    public override init(input: NSURLSessionTask? = nil) {
        assert(input == nil || input?.state == .Suspended, "Tasks must be suspended.")
        super.init(input: input)
    }
    
    override func concurrencyType() -> PipeOperationConcurrencyType {
        return .Asynchronous
    }
    
    public override func executeAsync(input: NSURLSessionTask) {
        assert(input.state == .Suspended, "Task was resumed by something other than \(self).")
        task = input
        input.addObserver(self, forKeyPath: "state", options: [], context: &URLSessionTaksOperationKVOContext)
        input.resume()
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let task = task where context == &URLSessionTaksOperationKVOContext else { return }
        
        if object === task && keyPath == "state" && task.state == .Completed {
            task.removeObserver(self, forKeyPath: "state")
            finish()
        }
    }
    
    public override func cancel() {
        task?.cancel()
        super.cancel()
    }
}
