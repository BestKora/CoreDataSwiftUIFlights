//
//  AirportInfo.swift
//  JSONCoreDataFlights
//
//  Created by Tatiana Kornilova on 09/02/2022.
//

import Foundation

// MARK: - AirportInfo

struct AirportInfo: Codable {
    let airportCode, alternateIdent, name: String?
    let elevation: Int
    let city, state: String
    let longitude, latitude: Double
    let timezone, countryCode: String
}
