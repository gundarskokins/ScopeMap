//
//  LocationManagerModel.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 29/06/2021.
//

import Foundation
import MapKit

class LocationManagerModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    
    private let locationManager: CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    static func getAddressFrom(coordinate: CLLocationCoordinate2D, completion: @escaping (String) -> ()) {
        let geoLocation: CLGeocoder = CLGeocoder()
        
        let location: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geoLocation.reverseGeocodeLocation(location, completionHandler: { (placeMarks, _) in
            
            guard let placeMarks = placeMarks,
                  let placeMark = placeMarks.first,
                  let thoroughfare = placeMark.thoroughfare,
                  let subThoroughfare = placeMark.subThoroughfare else { return }
            
            let addressString = "\(thoroughfare) \(subThoroughfare)"
            completion(addressString)
        })
    }
}
