//
//  Airport.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import CoreData
import MapKit
import SwiftUI

extension Airport: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    public var title: String? { name ?? icao }
    public var subtitle: String? { location }
}

extension Airport: Comparable {
    
    static func withICAO(_ icao: String, context: NSManagedObjectContext) -> Airport {
        // look up icao in Core Data
        let request = fetchRequest(NSPredicate(format: "icao_ = %@", icao))
        let airports = (try? context.fetch(request)) ?? []
        if let airport = airports.first {
            // if found, return it
            return airport
        } else {
            // if not, create one and fetch from FlightAware
            let airport = Airport(context: context)
            airport.icao = icao
            return airport
        }
    }
    
   static func update(from info: AirportInfo, context: NSManagedObjectContext) {
        if let icao = info.airportCode {
            let airport = self.withICAO(icao, context: context)
            airport.latitude = info.latitude
            airport.longitude = info.longitude
            airport.name = info.name
            airport.location = info.city + " " + info.state + " " + info.countryCode
            airport.timezone = info.timezone
            airport.city = info.city
            airport.state = info.state
            airport.countryCode = info.countryCode
            
            context.saveContext()
        }
    }

    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Airport> {
        let request = NSFetchRequest<Airport>(entityName: "Airport")
        //request.sortDescriptors = [NSSortDescriptor(key: "icao_", ascending: true)]
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        request.predicate = predicate
        return request
    }
   
    static func searchPredicate(query: String,field: String)-> NSPredicate? {
        if query.isEmpty {return nil}
        else {
          return  NSPredicate(format: "%K BEGINSWITH[cd] %@",field,query)
        }
    }
    
    var icao: String {
        get { icao_! } // TODO: maybe protect against when app ships?
        set { icao_ = newValue }
    }
    
    public var id: String { icao }
    
    var city: String {
        get { city_ ?? " "}
        set { city_ = newValue }
    }
    
    var nameAirport: String {
        get { name ?? " "}
    }
  
    var flightsFrom: Set<Flight> {
        get { (flightsFrom_ as? Set<Flight>) ?? [] }
        set { flightsFrom_ = newValue as NSSet }
    }
    
    var flightsTo: Set<Flight> {
        get { (flightsTo_ as? Set<Flight>) ?? [] }
        set { flightsTo_ = newValue as NSSet }
    }
    
    var friendlyName: String {
        Self.friendlyName(name: name ?? " ", location: city + " " + (state ?? " "))
    }

    static func friendlyName(name: String, location: String) -> String {
        var shortName = name
            .replacingOccurrences(of: " Intl", with: " ")
            .replacingOccurrences(of: " Int'l", with: " ")
            .replacingOccurrences(of: "Intl ", with: " ")
            .replacingOccurrences(of: "Int'l ", with: " ")
        for nameComponent in location.components(separatedBy: ",").map({ $0.trim }) {
            shortName = shortName
                .replacingOccurrences(of: nameComponent+" ", with: " ")
                .replacingOccurrences(of: " "+nameComponent, with: " ")
        }
        shortName = shortName.trim
        shortName = shortName.components(separatedBy: CharacterSet.whitespaces).joined(separator: " ")
        if !shortName.isEmpty {
            return "\(shortName), \(location)"
        } else {
            return location
        }
    }

    public static func < (lhs: Airport, rhs: Airport) -> Bool {
        lhs.location ?? lhs.friendlyName < rhs.location ?? rhs.friendlyName
    }
}
