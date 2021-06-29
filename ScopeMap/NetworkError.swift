//
//  NetworkError.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 25/06/2021.
//

import Foundation

enum NetworkError: Error {
    case invalidURLRequest
    case dataTaskError(description: String)
    case badResponse(statusCode: Int)
    case dataFailure
    case failedToDownload
    case invalidDataFromServer
}

extension NetworkError: LocalizedError {
    public var localizedDescription: String {
        switch self {
            case .invalidURLRequest:
                return "It seems that there is some issue with url"
            case .dataTaskError(description: let description):
                return "No data for you, my friend. Here is the error: \(description)"
            case .badResponse(statusCode: let statusCode):
                return "Wow, we didn't expect this code: \(statusCode)"
            case .dataFailure:
                return "What? This data? No.. try again"
            case .failedToDownload:
                return "Something went wrong. Let's try that again!"
            case .invalidDataFromServer:
                return "Server has some issues, try again!"
        }
    }
}
