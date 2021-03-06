//
//  ContentView.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 25/06/2021.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(dataManager.dataModel?.data ?? [], id: \.userid) { item in
                    NavigationLink(
                        destination: MapView(userId: item.userid, vehicleInfo: item.vehicles),
                        label: {
                            CellImageView(urlString: item.owner.foto)
                            
                            Text("\(item.owner.name ) \(item.owner.surname )")
                        })
                }
            }
            .navigationBarTitle("Users")
        }
        .alert(item: $dataManager.errorMessage) { message in
            Alert(title: Text("Ooops..."), message: Text(message), dismissButton: .default(Text("Try again!")) {
                dataManager.loadDataFromNetwork()
            })}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CellImageView: View {
    let urlString: String
    
    var body: some View {
        AsyncImage(url: urlString,
                   placeholder: { Image(systemName: "xmark.circle") },
                   image: { Image(uiImage: $0)
                    .resizable()
                   })
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
            .background(Color(.gray)
                            .opacity(0.3))
            .cornerRadius(3.0)
    }
}
