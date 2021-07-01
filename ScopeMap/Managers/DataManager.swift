//
//  DataManager.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 01/07/2021.
//

import Foundation

class DataManager: ObservableObject {
    @Published var errorMessage: String?
    @Published var dataModel: DataModel?
    private var dataNetworkManager = DataNetworkManager()
    private var dataTimer = DataTimer()
    
    init() {
        loadDataFromNetwork()
        startDataTimer()
    }
    
    func loadDataFromNetwork() {
        self.dataNetworkManager.loadData { receivedData in
            DispatchQueue.main.async {
                switch receivedData {
                    case .success(let model):
                        self.dataModel = model
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func startDataTimer() {
        dataTimer.startSpecsHeartbeatTimer {
            self.loadDataFromNetwork()
        }
    }
}
