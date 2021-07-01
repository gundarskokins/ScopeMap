//
//  VehicleDescription.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 01/07/2021.
//

import Foundation
import CoreLocation

struct VehicleDescription: Identifiable {
    var id = UUID()
    var vehicleId: Int
    var vehicleImage: String
    var vehicleName: String
    var color: String
    var currentAddress: String?
    var coordinates: CLLocationCoordinate2D? {
        didSet {
            if let coordinates = coordinates {
                getAddress(from: coordinates)
            }
        }
    }
    
    mutating func getAddress(from coordinates: CLLocationCoordinate2D) {
        LocationManagerModel.getAddressFrom(coordinate: coordinates) { _ in
            //            currentAddress = $0
        }
    }
}
