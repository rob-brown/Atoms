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
open class MessageRouter<T> {
    public typealias MessageHandler = (T)->()
    public typealias NoParameterHandler = ()->()
    
    /// The current list of recipients.
    fileprivate var entries = [MessageRouterEntry<T>]()
    
    /// Basic init.
    public init() {}
    
    /**
     Convenience function for add(_:_:). Simply takes a function that will
     receive all messages for the life time of this instance, or until the
     returned entry is removed.
     
     - parameter function: The function to receive any messages.
     - returns: An opaque object that can be used to stop any further messages.
     */
    @discardableResult
    open func add(_ function: @escaping MessageHandler) -> MessageRouterEntry<T> {
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
    @discardableResult
    open func add<R: Recipient>(_ object: R, _ function: @escaping (R)->MessageHandler) -> MessageRouterEntry<T> {
        let entry = MessageRouterEntry(object: object, function: { function($0 as! R) })
        sync {
            self.entries += [entry]
        }
        return entry
    }
    
    /**
     Convenience function for perform(_:_:).
     */
    @discardableResult
    open func perform(_ function: @escaping NoParameterHandler) -> MessageRouterEntry<T> {
        return perform(self) { _ in function }
    }
    
    /**
     Performs the given function, ignoring the value sent.
     
     - parameter object: The object that owns the given function.
     - parameter function: The function that will be called with any messages. Typically a function on `object`.
     - returns: An opaque object that can be used to stop any further messages.
     */
    @discardableResult
    open func perform<R: Recipient>(_ object: R, _ function: @escaping (R)->NoParameterHandler) -> MessageRouterEntry<T> {
        return add(object) { object in { _ in function(object)() }}
    }
    
    /**
     Convenience function for map(_:_:).
     */
    @discardableResult open func map<U>(_ mapper: @escaping (T)->U) -> MessageRouter<U> {
        return map(self, mapper: mapper)
    }
    
    /**
     Creates a router that returns the new type created by `mapper`.
     
     - parameter object: The object that owns the given mapper.
     - parameter mapper: The function that will be called with any messages and transform them to the new type.
     - returns: A router that returns the new type created by `mapper`.
     */
    @discardableResult open func map<U, R: Recipient>(_ object: R, mapper: @escaping (T)->U) -> MessageRouter<U> {
        let mappedRouter = MessageRouter<U>()
        
        add(object) { _ in
            { value in
                mappedRouter.send(mapper(value))
            }
        }
        
        return mappedRouter
    }
    
    /**
     Removes the given entry from the list of recipients.
     
     - parameter entry: The entry to remove.
     */
    open func remove(_ entry: MessageRouterEntry<T>) {
        sync {
            self.entries = self.entries.filter { $0 !== entry }
        }
    }
    
    /**
     Sends the given message to all the registered recipients.
     
     - parameter message: The message to send to the recipients.
     */
    open func send(_ message: T) {
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
    fileprivate let queue = DispatchQueue(label: "com.robertbrown.Atoms.Messaging", attributes: [])
    
    /**
     Ensures that critical code is run synchronously.
     This function must be called before accessing `entries`.
     
     - parameter function: The function containing the critical code.
     */
    fileprivate func sync(_ function: ()->()) {
        queue.sync(execute: function)
    }
}

/// Opaque object for tracking message recipient info.
open class MessageRouterEntry<T> {
    fileprivate typealias MessageHandlerProducer = (Recipient)->MessageHandler
    fileprivate typealias MessageHandler = (T)->()
    
    fileprivate weak var object: Recipient?
    fileprivate let function: MessageHandlerProducer
    
    fileprivate init(object: Recipient? = nil, function: @escaping MessageHandlerProducer) {
        self.object = object
        self.function = function
    }
}
