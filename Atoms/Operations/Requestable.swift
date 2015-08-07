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
