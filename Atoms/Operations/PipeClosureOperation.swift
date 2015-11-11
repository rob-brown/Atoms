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


public class PipeClosureOperation<I,O>: PipeOperation<I,O> {
    
    public typealias PipeClosureOperationAsyncClosure = (I, CancelToken)->(O?)  // TODO: Add the finish function.
    public typealias PipeClosureOperationSyncClosure = (I)->(O?)
    
    private let closure: PipeClosureOperationAsyncClosure
    private let cancelToken = CancelToken()
    private let async: Bool
    
    private convenience init(_ input: I? = nil, _ closure: (I)->(O?)) {
        self.init(input, async: false) { input, _ in
            closure(input)
        }
    }
    
    private init(_ input: I? = nil, async: Bool = true, _ closure: PipeClosureOperationAsyncClosure) {
        self.closure = closure
        self.async = async
        super.init(input: input)
    }
    
    public class func async(input: I? = nil, _ closure: PipeClosureOperationAsyncClosure) -> PipeClosureOperation<I,O> {
        return PipeClosureOperation(input, closure)
    }
    
    public class func sync(input: I? = nil, _ closure: PipeClosureOperationSyncClosure) -> PipeClosureOperation<I,O> {
        return PipeClosureOperation(input, closure)
    }
    
    override func concurrencyType() -> PipeOperationConcurrencyType {
        return async ? .Asynchronous : .Synchronous
    }
    
    public override func executeSync(input: I) -> O? {
        return closure(input, cancelToken)
    }
    
    public override func executeAsync(input: I) {
        closure(input, cancelToken)  // TODO: Hand this a finish function.
    }
    
    public override func cancelWithError(error: NSError?) {
        cancelToken.cancel()
    }
}
