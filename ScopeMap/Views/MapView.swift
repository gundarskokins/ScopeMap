//
//  MapView.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 29/06/2021.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationViewModel = LocationManagerModel()
    @StateObject private var vehicleManager: VehicleManager
    @State private var showingSheet = false
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 56.946285, longitude: 24.105078), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    init(userId: Int, vehicleInfo: [Vehicle]) {
        _vehicleManager = StateObject(wrappedValue: VehicleManager(id: userId,
                                                                   vehicleInfo: vehicleInfo,
                                                                   cache: Environment(\.vehicleLocationCache).wrappedValue))
    }

    var body: some View {
        if vehicleManager.coordinatesLoaded {
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: vehicleManager.vehicles) { item in
                MapAnnotation(coordinate: item.coordinates!) {
                    Button {
                        showingSheet = true
                    } label: {
                        Circle()
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30)
                    }
                    .sheet(isPresented: $showingSheet) {
                        ItemView(vehicleDescription: item)
                    }
                }
            }
            
            .edgesIgnoringSafeArea(.all)
        } else {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    locationViewModel.requestPermission()
                    vehicleManager.load()
                }
                .alert(item: $vehicleManager.errorMessage) { message in
                    Alert(title: Text("Ooops..."),
                          message: Text(message),
                          primaryButton: .default(Text("Try again!")) {
                            vehicleManager.load()
                          },
                          secondaryButton: .destructive(Text("Cancel")) {
                            vehicleManager.errorMessage = nil
                          }
                    )}
        }
    }
}
