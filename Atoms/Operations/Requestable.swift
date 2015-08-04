import Foundation

public protocol Requestable {
    func request() -> NSURLRequest?
}

extension NSURLRequest: Requestable {
    public func request() -> NSURLRequest? {
        return self
    }
}

extension NSURL: Requestable {
    public func request() -> NSURLRequest? {
        return NSURLRequest(URL: self)
    }
}

extension String: Requestable {
    public func request() -> NSURLRequest? {
        if let url = NSURL(string: self) {
            return url.request()
        }
        
        return nil
    }
}

//public struct FileURL {
////    public let url: NSURL
////    
////    private init?(path: String) {
////        if let url = NSURL.fileURLWithPath(path) {
////            self.url = url
////        }
////        else {
////            return nil
////        }
////    }
//}
//
//public struct RemoteURL {
//    
//}
//
//public enum URL {
//    case File(FileURL)
//    case Remote(RemoteURL)
//    
//    
//}
