import Foundation
import CoreLocation

public class LocationPipeOperation: PipeOperation<CLLocationAccuracy,CLLocation> {
    
    private var manager: CLLocationManager?
    
    public override init(input: CLLocationAccuracy?) {
        super.init(input: input)
        addCondition(LocationCondition(usage: .WhenInUse))
        addCondition(MutuallyExclusive<CLLocationManager>())
    }
    
    override func concurrencyType() -> PipeOperationConcurrencyType {
        return .Asynchronous
    }
    
    public override func executeAsync(input: CLLocationAccuracy) {
        dispatch_async(dispatch_get_main_queue()) {
            // `CLLocationManager` needs to be created on a thread with an
            // active run loop, so for simplicity we do this on the main queue.
            let manager = CLLocationManager()
            manager.desiredAccuracy = input
            manager.delegate = self
            manager.startUpdatingLocation()
            
            self.manager = manager
        }
    }
    
    public override func cancel() {
        dispatch_async(dispatch_get_main_queue()) {
            self.stopLocationUpdates()
            super.cancel()
        }
    }
    
    private func stopLocationUpdates() {
        manager?.stopUpdatingLocation()
        manager = nil
    }
}

extension LocationPipeOperation: CLLocationManagerDelegate {
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let accuracy = self.inputValue(), location = locations.last where location.horizontalAccuracy <= accuracy {
            stopLocationUpdates()
            finishWithOutput(location)
        }
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        stopLocationUpdates()
        finishWithError(error)
    }
}
