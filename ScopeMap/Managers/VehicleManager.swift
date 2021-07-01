//
//  VehicleManager.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 30/06/2021.
//

import Foundation
import Combine
import CoreLocation

class Loader<CachedObject>: ObservableObject {

    var isLoading = false
    var url: URL?
    var cancellable: AnyCancellable?
    var cache: Cache<NSURL, CachedObject>?

    init(urlString: String, cache: Cache<NSURL, CachedObject>? = nil) {
        self.url = URL(string: urlString)
        self.cache = cache
    }

    deinit {
        cancel()
    }

    func cancel() {
        cancellable?.cancel()
    }

    func onStart() {
        isLoading = true
    }

    func onFinish() {
        isLoading = false
    }

    func cache(_ object: CachedObject?) {
        guard let url = url else { return }
        object.map { cache?[url as NSURL] = $0 }
    }
}

class VehicleManager: Loader<[VehicleDescription]> {
    @Published var vehicles = [VehicleDescription]() {
        didSet {
            if vehicles.allSatisfy({ $0.coordinates != nil }) {
                coordinatesLoaded = true
            } else {
                coordinatesLoaded = false
            }
        }
    }
    @Published var errorMessage: String?
    @Published var coordinatesLoaded = false

    private static let vehicleLoadingQueue = DispatchQueue(label: "vehicle-processing")
    private var dataTimer = DataTimer()

    init(id: Int, vehicleInfo: [Vehicle], cache: Cache<NSURL, [VehicleDescription]>) {

        let urlString = "http://mobi.connectedcar360.net/api/?op=getlocations&userid=\(id)"
        super.init(urlString: urlString, cache: cache)

        dataTimer.timeInterval = TimeInterval(60)
        
        vehicleInfo.forEach {
            let new = VehicleDescription(vehicleId: $0.vehicleid,
                                         vehicleImage: $0.foto,
                                         vehicleName: "\($0.make) \($0.model)",
                                         color: $0.color,
                                         currentAddress: nil,
                                         coordinates: nil)
            vehicles.append(new)
        }        
    }
    
    deinit {
        cancel()
        dataTimer.timer.invalidate()
    }
    
    func load() {
        guard let url = url else { return }
        startDataTimer()
        
        if let vehicles = cache?[url as NSURL] {
            self.vehicles = vehicles
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .retry(3)
            .tryMap { [weak self] in
                if let response = $0.response as? HTTPURLResponse, !(200 ..< 300 ~= response.statusCode) {
                    throw NetworkError.badResponse(statusCode: response.statusCode)
                }
                
                let receivedData = try JSONDecoder().decode(VehicleData.self, from: $0.data)
                return self?.vehicles.map { vehicle -> VehicleDescription in
                    var vehicle = vehicle
                    
                    receivedData.data.forEach { vehicleInfo in
                        if vehicle.vehicleId == vehicleInfo.vehicleid {
                            let lat = CLLocationDegrees(vehicleInfo.lat)
                            let lon = CLLocationDegrees(vehicleInfo.lon)
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                            vehicle.coordinates = coordinate
                        }
                    }
                    
                    return vehicle
                } ?? []
            }
            .mapError { error -> NetworkError in
                return NetworkError.invalidDataFromServer
            }
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.cache($0) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .subscribe(on: Self.vehicleLoadingQueue)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                    case .finished:
                        print("received items successfully")
                    case .failure(.badResponse(statusCode: let code)):
                        self?.errorMessage = NetworkError.badResponse(statusCode: code).localizedDescription
                    case .failure(.invalidDataFromServer):
                        self?.errorMessage = NetworkError.invalidDataFromServer.localizedDescription
                        
                    case .failure(.invalidURLRequest),
                         .failure(.dataTaskError(description:)),
                         .failure(.dataFailure),
                         .failure(.failedToDownload):
                        self?.errorMessage = "Something went wrong"
                }
            }, receiveValue: { [weak self] in

                guard let self = self else { return }

                self.vehicles = $0 ?? []

                let myGroup = DispatchGroup()

                var transports = [VehicleDescription]()

                self.vehicles.forEach { veh in
                        myGroup.enter()
                        LocationManagerModel.getAddressFrom(coordinate: veh.coordinates) {
                            var vehicle = veh
                            vehicle.currentAddress = $0
                            transports.append(vehicle)
                            myGroup.leave()
                        }
                    }

                myGroup.notify(queue: .main) {
                    self.vehicles = transports
                }
            })
    }
    
    func startDataTimer() {
        dataTimer.startSpecsHeartbeatTimer {
            self.load()
        }
    }
    
    func ignoreError() {
        errorMessage = nil
        dataTimer.timer.invalidate()
    }
}
