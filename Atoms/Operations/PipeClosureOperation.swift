import Foundation

public class PipeClosureOperation<I,O>: PipeOperation<I,O> {
    
    private let closure: (I)->(O?)
    
    public init(_ input: I? = nil, _ closure: (I)->(O?)) {
        self.closure = closure
        super.init(input: input)
    }
    
    public override func executeSync(input: I) -> O? {
        return closure(input)
    }
}
