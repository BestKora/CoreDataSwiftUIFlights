//
//  FlightsInfo.swift
//  ReadJSONFlights
//
//  Created by Tatiana Kornilova on 26/01/2022.
//

import Foundation

// MARK: - FlightsInfo
struct FlightsInfo: Codable {
    let arrivals:  [Arrival]
    let departures:  [Arrival]
    let scheduledArrivals:[Arrival]
    let scheduledDepartures: [Arrival]
}
// MARK: - Arrival
struct Arrival: Codable {
    var number: Int { Int(String(ident.drop(while: { !$0.isNumber }))) ?? 0 }
    var airlineCode: String { String(ident.prefix(while: { !$0.isNumber })) }
     
    let ident: String
    let blocked, diverted, cancelled, positionOnly: Bool
    let origin, destination: Destination
    let scheduledOff, estimatedOff,actualOff: Date?
    let scheduledOn, estimatedOn: Date
    let actualOn, scheduledIn, estimatedIn, actualIn: Date?
    let progressPercent: Int
    let status: String
    let aircraftType: String
    let routeDistance: Int
    let filedAirspeed, filedAltitude: Int?
}

// MARK: - Destination
struct Destination: Codable {
    let code: String
}

