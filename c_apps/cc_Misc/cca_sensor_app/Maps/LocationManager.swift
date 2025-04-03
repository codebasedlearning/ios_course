// (C) 2024 A.Voß, a.voss@fh-aachen.de, ios@codebasedlearning.dev

import Foundation
import CoreLocation // CLLocationManager

// https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html

/*
 - see "Info"-tab in project settings of "A_Sensors"
 - there we need an entry (plist), called
 'Privacy - Location when in use usage description' -> 'We need your location to show it on the map.'
 (for new entries, select '+'-button in first row "Bundle name".)
 */

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {  // before: ObservableObject and @StateObject
    private let manager = CLLocationManager()
    var userLocation: CLLocationCoordinate2D? //before: @Published
    
    override init() {
        super.init()
        manager.delegate = self // quite common, a someone manages the action (implements CLLocationManagerDelegate)
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization() // see comment above
    }
    
    // multiple callbacks, depending on the action
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if status == .authorizedWhenInUse || status == .authorizedAlways {
//            manager.startUpdatingLocation()
//        }
//    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
    }
    
    // first init
    
    func initLocation() {
        if let location = manager.location {
            userLocation = location.coordinate
        }
    }
}
