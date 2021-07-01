//
//  CacheKeys.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 01/07/2021.
//

import Foundation
import SwiftUI
import UIKit

struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: Cache = Cache<NSURL, UIImage>()
}

struct VehicleCacheKey: EnvironmentKey {
    static let defaultValue: Cache = Cache<NSURL, [VehicleDescription]>(entryLifetime: 30)
}

extension EnvironmentValues {
    var imageCache: Cache<NSURL, UIImage> {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
    
    var vehicleLocationCache: Cache<NSURL, [VehicleDescription]> {
        get { self[VehicleCacheKey.self] }
        set { self[VehicleCacheKey.self] = newValue }
    }
}
