import Foundation

public class DownloadPipeOperation: PipeOperation<Requestable,NSURL> {
    
    public var configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    private var session: NSURLSession?
    private var task: NSURLSessionDownloadTask?
    private let internalQueue = NSOperationQueue()
    
    public override init(input: Requestable? = nil) {
        super.init(input: input)
    }
    
    override func concurrencyType() -> PipeOperationConcurrencyType {
        return .Asynchronous
    }
    
    public override func executeAsync(input: Requestable) {
        guard let request = input.request() else {
            let message = "No request for input: \(input)"
            let userInfo = [NSLocalizedDescriptionKey : message]
            let error = NSError(domain: __FILE__, code: __LINE__, userInfo: userInfo)
            finishWithError(error)
            return
        }
        
        session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: internalQueue)
        task = session?.downloadTaskWithRequest(request)
        task?.resume()
    }
    
    public override func cancel() {
        task?.cancel()
        super.cancel()
    }
}

extension DownloadPipeOperation: NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let dir = NSTemporaryDirectory()
        let fileName = NSUUID().UUIDString + (downloadTask.response?.suggestedFilename ?? "")
        let path = dir.stringByAppendingPathComponent(fileName)
        let destination = NSURL.fileURLWithPath(path)

        do {
            try NSFileManager.defaultManager().moveItemAtURL(location, toURL: destination)
            finishWithOutput(destination)
        }
        catch let error as NSError {
            finishWithError(error)
        }
        catch {
            let message = "Unable to move download from \(location) to \(destination)"
            let userInfo = [NSLocalizedDescriptionKey : message]
            let error = NSError(domain: NSStringFromClass(self.dynamicType), code: __LINE__, userInfo: userInfo)
            finishWithError(error)
        }
    }
}
