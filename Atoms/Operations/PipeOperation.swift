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

internal enum PipeOperationConcurrencyType {
    case Synchronous
    case Asynchronous
}


// MARK: - Base Operation

public class PipeOperation<I,O>: Operation {
    private var input: PipeIOWrapper<I>?
    private var output: PipeIOWrapper<O>?
    public let completionRouter = MessageRouter<O>()
    
    public init(input: I? = nil) {
        if let input = input {
            self.input = PipeIOWrapper(input)
        }
    }
    
    override func execute() {
        guard let input = input?.value else {
            let message = "Input not provided."
            let userInfo = [NSLocalizedDescriptionKey : message]
            let error = NSError(domain: __FILE__, code: __LINE__, userInfo: userInfo)
            finishWithError(error)
            return
        }
        
        switch concurrencyType() {
        case .Synchronous:
            let output = executeSync(input)
            finishWithOutput(output)
        case .Asynchronous:
            executeAsync(input)
        }
    }
    
    /// Overriden by subclasses to determine how the work should be executed.
    internal func concurrencyType() -> PipeOperationConcurrencyType {
        return .Synchronous
    }
    
    /// Overriden by subclasses to perform the work synchronously.
    public func executeSync(input: I) -> O? {
        return nil
    }
    
    /// Overriden by subclasses to perform the work asynchronously.
    public func executeAsync(input: I) {
        return
    }
    
    /**
    Makes this operation dependent on the given operation. The given operation's 
    output must match the input of this operation.
    
    - parameter op: The operation on which this operation depends.
    */
    public func addPipeDependency<X>(op: PipeOperation<X,I>) {
        op.completionRouter.add(self, self.dynamicType.setInputValue)
        self.addDependency(op)
    }
    
    /// Intended to be used to pass values between operations through `completionRecipients`.
    public func setInputValue(input: I) {
        self.input = PipeIOWrapper(input)
    }
    
    /// Unwraps the input.
    public func inputValue() -> I? {
        return input?.value
    }
    
    /// Unwraps the output.
    public func outputValue() -> O? {
        return output?.value
    }
    
    /**
    Must be called when this operation has finished it's purpose. This function
    is called automatically for synchronous operations. Asynchronous operations 
    must call this function.
    
    - parameter output: The value to output to dependent operations. `nil` usually indicates failure.
    */
    public func finishWithOutput(output: O?) {
        if let output = output {
            self.output = PipeIOWrapper(output)
            completionRouter.send(output)
        }
        finish()
    }
    
    public class func runPipeline(operations: [PipeOperation]) {
        
    }
}


// MARK: - Intermediate Pipeline Processing

public class PipeSeries<I,O,X,Y> {
    public let firstOperation: PipeOperation<I,X>
    public let lastOperation: PipeOperation<Y,O>
    public let operations: [NSOperation]
    
    public init(operations: [NSOperation], firstOperation: PipeOperation<I,X>, lastOperation: PipeOperation<Y,O>) {
        self.firstOperation = firstOperation
        self.lastOperation = lastOperation
        self.operations = operations
    }
    
    public class func initial<A,B,C>(firstOperation: PipeOperation<A,B>, _ secondOperation: PipeOperation<B,C>) -> PipeSeries<A,C,B,B> {
        secondOperation.addPipeDependency(firstOperation)
        let operations = [firstOperation, secondOperation]
        let segment1 = firstOperation
        let segment2 = secondOperation
        return PipeSeries<A,C,B,B>(operations: operations, firstOperation: segment1, lastOperation: segment2)
    }
    
    public func addPipeOperation<T>(operation: PipeOperation<O,T>) -> PipeSeries<I,T,X,O> {
        let operations = self.operations + [operation]
        operation.addPipeDependency(lastOperation)
        return PipeSeries<I,T,X,O>(operations: operations, firstOperation: firstOperation, lastOperation: operation)
    }
}


// MARK: - I/O Wrapper

/**
    Basically a `Box` type. Simply wraps an arbitrary value. Must be a `class` 
    and not a `struct`. This allows `PipeOperation` to have a known size as per 
    Objective-C requirements.
*/
private class PipeIOWrapper<T> {
    let value: T
    
    private init(_ value: T) {
        self.value = value
    }
}


// MARK: - Operators

infix operator |> { precedence 100 associativity left }

public func |> <A,B>(lhs: A, rhs: PipeOperation<A,B>) -> PipeOperation<A,B> {
    rhs.input = PipeIOWrapper(lhs)
    return rhs
}

public func |> <A,B,C>(lhs: PipeOperation<A,B>, rhs: PipeOperation<B,C>) -> PipeSeries<A,C,B,B> {
    return PipeSeries<A,C,B,B>.initial(lhs, rhs)
}

public func |> <I,O,X,Y,T>(lhs: PipeSeries<I,O,X,Y>, rhs: PipeOperation<O,T>) -> PipeSeries<I,T,X,O> {
    return lhs.addPipeOperation(rhs)
}

public func |> <I,O,X,Y>(lhs: PipeSeries<I,O,X,Y>, rhs: OperationQueue) {
    rhs.addOperations(lhs.operations, waitUntilFinished: false)
}

public func |> <A,B>(lhs: PipeOperation<A,B>, rhs: OperationQueue) {
    rhs.addOperation(lhs)
}
