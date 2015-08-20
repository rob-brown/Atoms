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

import Dispatch

/// Recipients can be of any arbitrary type since different types of objects can
/// register as recipients.
public typealias Recipient = AnyObject

/**
A class for sending messages of type T to the registered recipients. Built to be 
a thread-safe, type-safe NSNotificationCenter replacement. Can also be a 
replacement to many types of delegate callbacks.
*/
public class MessageRouter<T> {
    public typealias MessageHandler = T->()
    
    /// The current list of recipients.
    private var entries = [MessageRouterEntry<T>]()
    
    /**
    Convenience function for add(_:_:). Simply takes a function that will 
    receive all messages for the life time of this instance, or until the
    returned entry is removed.
    
    - parameter function: The function to receive any messages.
    - returns: An opaque object that can be used to stop any further messages.
    */
    public func add(function: MessageHandler) -> MessageRouterEntry<T> {
        return add(self) { _ in function }
    }
    
    /**
    The given function will receive any messages for the life time of `object`.
    Typically called like this:
    
        recipients.add(self, self.dynamicType.handleMessage)
    
    - parameter object: The object that owns the given function.
    - parameter function: The function that will be called with any messages. Typically a function on `object`.
    - returns: An opaque object that can be used to stop any further messages.
    */
    public func add<R: Recipient>(object: R, _ function: R->MessageHandler) -> MessageRouterEntry<T> {
        let entry = MessageRouterEntry(object: object, function: { function($0 as! R) })
        sync {
            self.entries += [entry]
        }
        return entry
    }
    
    /**
    Removes the given entry from the list of recipients. 
    
    - parameter entry: The entry to remove.
    */
    public func remove(entry: MessageRouterEntry<T>) {
        sync {
            self.entries = self.entries.filter { $0 !== entry }
        }
    }
    
    /**
    Sends the given message to all the registered recipients.
    
    - parameter message: The message to send to the recipients.
    */
    public func send(message: T) {
        var handlers = [MessageHandler]()
        
        sync {
            for entry in self.entries {
                guard let object = entry.object else { continue }
                handlers += [entry.function(object)]
            }
        }
        
        for handler in handlers {
            handler(message)
        }
    }
    
    // MARK: - Helpers
    
    /**
    Convenience method for getting a copy of the entries. This is intended only 
    for testing. Since `entries` is private, it isn't visible to tests, even with 
    the `@testable` keyword.
    
    - returns: A copy of the registered recipient entries.
    */
    internal func copyEntries() -> [MessageRouterEntry<T>] {
        var entries = [MessageRouterEntry<T>]()
        
        sync {
            for entry in self.entries {
                entries += [entry]
            }
        }
        
        return entries
    }
    
    /// Queue for handling synchronization for `entries`.
    private let queue = dispatch_queue_create("com.robertbrown.Atoms.Messaging", DISPATCH_QUEUE_SERIAL)
    
    /**
    Ensures that critical code is run synchronously.
    This function must be called before accessing `entries`.
    
    - parameter function: The function containing the critical code.
    */
    private func sync(function: ()->()) {
        dispatch_sync(queue, function)
    }
}

/// Opaque object for tracking message recipient info.
public class MessageRouterEntry<T> {
    private typealias MessageHandlerProducer = Recipient->MessageHandler
    private typealias MessageHandler = T->()
    
    private weak var object: Recipient?
    private let function: MessageHandlerProducer
    
    private init(object: Recipient? = nil, function: MessageHandlerProducer) {
        self.object = object
        self.function = function
    }
}
