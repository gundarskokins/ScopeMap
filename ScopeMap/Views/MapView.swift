//
//  MapView.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 29/06/2021.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
            .edgesIgnoringSafeArea(.all)
//            .frame(width: 400, height: 300)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

struct LocationView: View {
    @StateObject var locationViewModel = LocationViewModel()
    
    var body: some View {
        switch locationViewModel.authorizationStatus {
            case .notDetermined:
                AnyView(RequestLocationView())
                    .environmentObject(locationViewModel)
            case .restricted:
                ErrorView(errorText: "Location use is restricted.")
            case .denied:
                ErrorView(errorText: "The app does not have location permissions. Please enable them in settings.")
            case .authorizedAlways, .authorizedWhenInUse:
                TrackingView()
                    .environmentObject(locationViewModel)
            default:
                Text("Unexpected status")
        }
    }
}

struct RequestLocationView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "location.circle")
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            Button(action: {
                print("allowing perms")
            }, label: {
                Label("Allow tracking", systemImage: "location")
            })
            .padding(10)
            .foregroundColor(.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            Text("We need your permission to track you.")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
}

struct ErrorView: View {
    var errorText: String
    
    var body: some View {
        VStack {
            Image(systemName: "xmark.octagon")
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
            Text(errorText)
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.red)
    }
}

struct TrackingView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    
    var body: some View {
        Text("Thanks!")
    }
}


//struct Pin {
//    let vehicleid: Int
//    var lat: Double
//    var lon: String
//    var coordinate: CLLocationCoordinate2D
//}
