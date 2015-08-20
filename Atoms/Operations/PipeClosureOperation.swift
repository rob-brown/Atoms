import Foundation

public class PipeClosureOperation<I,O>: PipeOperation<I,O> {
    private let closure: (I, CancelToken)->(O?)
    private let cancelToken = CancelToken()
    
    public convenience init(_ input: I? = nil, _ closure: (I)->(O?)) {
        self.init(input) { input, _ in
            closure(input)
        }
    }
    
    public init(_ input: I? = nil, _ closure: (I, CancelToken)->(O?)) {
        self.closure = closure
        super.init(input: input)
    }
    
    public override func executeSync(input: I) -> O? {
        return closure(input, cancelToken)
    }
    
    public override func cancelWithError(error: NSError?) {
        cancelToken.cancel()
    }
}
