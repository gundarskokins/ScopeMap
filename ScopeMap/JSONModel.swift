//
//  JSONModel.swift
//  ScopeMap
//
//  Created by Gundars Kokins on 25/06/2021.
//

import Foundation

struct DataModel: Codable {
    let data: [ClientModel]
}

// MARK: - ClientModel
struct ClientModel: Codable {
    let userid: Int
    let owner: Owner
    let vehicles: [Vehicle]
}

// MARK: - Owner
struct Owner: Codable {
    let name, surname: String
    let foto: String
}

// MARK: - Vehicle
struct Vehicle: Codable {
    let vehicleid: Int
    let make, model, year, color: String
    let vin: String
    let foto: String
}
