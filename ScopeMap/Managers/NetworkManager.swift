//
//  NetworkManager.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 25/06/2021.
//

import Foundation

protocol NetworkProtocol {
    var urlSession: URLSession { get }
    var urlRequest: URLRequest? { get }
    var urlSessionConfiguration: URLSessionConfiguration? { get }
    var url: URL? { get }
    
    func getData(urlRequest: URLRequest?, completion: @escaping (Result<String, Error>) -> ())
}

extension NetworkProtocol {
    func getData(urlRequest: URLRequest?, completion: @escaping (Result<String, Error>) -> ()) {
        guard let urlRequest = urlRequest else { return completion(.failure(NetworkError.invalidURLRequest)) }
        urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                return completion(.failure(NetworkError.dataTaskError(description: error.localizedDescription)))
            }
            
            guard let response = response as? HTTPURLResponse, 200 ..< 300 ~= response.statusCode else {
                return completion(.failure(NetworkError.failedToDownload))
            }
            
            guard let data = data, let completionString = String(data: data, encoding: .utf8) else {
                return completion(.failure(NetworkError.dataFailure))
            }
            
            completion(.success(completionString))
        }.resume()
    }
}

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

class DataTimer {
    var timer = Timer()
    var timeInterval = TimeInterval(86400)
//    private var configurationTimerTriggered: TimeInterval?
    
    func startSpecsHeartbeatTimer(block: @escaping ()->()) {
        timer.invalidate()
        triggerConfigurationTimer(block: block)
    }

    private func triggerConfigurationTimer(block: @escaping ()->()) {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval,
                                              repeats: true,
                                              block: { _ in
                                                block()
                                              })
        }
    }
}

class DataNetworkManager: NetworkProtocol, ObservableObject {
    var urlSessionConfiguration: URLSessionConfiguration? {
        let configuration = URLSessionConfiguration.default
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            configuration.urlCache?.removeCachedResponses(since: yesterday)
        }
        return configuration
    }

    var urlSession: URLSession {
        if let configuration = urlSessionConfiguration {
            return URLSession(configuration: configuration)
        }
        
        return URLSession(configuration: .default)
    }
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "mobi.connectedcar360.net"
        components.path = "/api/"
        components.queryItems = [
            URLQueryItem(name: "op", value: "list"),
        ]
        
        return components.url
    }
    
    var urlRequest: URLRequest? {
        guard let url = url else { return nil }
        var request = URLRequest(url: url, timeoutInterval: 15)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        request.cachePolicy = .reloadRevalidatingCacheData
        
        return request
    }
    
    func loadData(completion: @escaping (Result<DataModel, NetworkError>) -> ()) {
        getData(urlRequest: urlRequest) { result in
            do {
                completion(.success(try JSONDecoder()
                                        .decode(DataModel.self,
                                                from: Data(result
                                                            .get()
                                                            .replacingOccurrences(of: ",{}", with: "")
                                                            .utf8))))
            } catch {
                completion(.failure(NetworkError.invalidDataFromServer))
            }
        }
    }
}

extension String: Identifiable {
    public var id: String {
        self
    }
}
