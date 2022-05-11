//
//  AirlineInfo.swift
//  JSONCoreDataFlights
//
//  Created by Tatiana Kornilova on 09/02/2022.
//

import Foundation

struct AirlineInfo: Codable {
     let icao: String?
     let callsign: String
     let country: String
     let location: String?
     let name: String
     let phone: String?
     let shortname: String?
}

