//
//  ItemView.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 01/07/2021.
//

import Foundation
import SwiftUI

struct ItemView: View {
    @Environment(\.presentationMode) var presentationMode
    var vehicleDescription: VehicleDescription
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current address")) {
                    Text(vehicleDescription.currentAddress ?? "Couldn't find address")
                }
                
                HStack {
                    Spacer()
                    AsyncImage(url: vehicleDescription.vehicleImage,
                               placeholder: { Image(systemName: "xmark.circle")
                                .foregroundColor(.white)
                               },
                               image: { Image(uiImage: $0)
                                .resizable()
                               })
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    Spacer()
                }
                
                Section(header: Text("Vehicle color")) {
                    HStack {
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color(hex: vehicleDescription.color))
                    }
                }
            }
            .navigationBarTitle(vehicleDescription.vehicleName, displayMode: .inline)
            .navigationBarItems(leading:
                                    Button {
                                        presentationMode.wrappedValue.dismiss()
                                    } label: {
                                        Image(systemName: "xmark")
                                    }
            )
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 3: // RGB (12-bit)
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6: // RGB (24-bit)
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8: // ARGB (32-bit)
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
