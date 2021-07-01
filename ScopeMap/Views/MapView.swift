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

struct DirectionMapView: UIViewRepresentable {
    var title: String
    var deltaSpan: Double
    var venueCoordinate: CLLocationCoordinate2D
    var showingRoute: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = false
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {

        let span = MKCoordinateSpan(latitudeDelta: deltaSpan, longitudeDelta: deltaSpan)
        let region = MKCoordinateRegion(center: venueCoordinate, span: span)

        let venueLocation = MKPointAnnotation()
        venueLocation.coordinate = venueCoordinate
        venueLocation.title = title

        view.addAnnotation(venueLocation)
        view.setRegion(region, animated: true)

        if showingRoute {
            let locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()

            view.showsUserLocation = true

            let request = MKDirections.Request()
            request.source = .forCurrentLocation()
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: venueCoordinate))
            request.requestsAlternateRoutes = true
            request.transportType = .walking

            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                guard let unwrappedResponse = response else { return }

                for route in unwrappedResponse.routes {
                    view.addOverlay(route.polyline)
                    view.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: DirectionMapView

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.systemPurple
            renderer.lineCap = .round
            renderer.lineWidth = 3
            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "placemark"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }

        init(_ parent: DirectionMapView) {
            self.parent = parent
        }
    }
}

