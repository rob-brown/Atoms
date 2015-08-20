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
