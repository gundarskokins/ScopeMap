//
//  ScopeMapApp.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 25/06/2021.
//

import SwiftUI

@main
struct ScopeMapApp: App {
    @StateObject private var dataManager = DataManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
