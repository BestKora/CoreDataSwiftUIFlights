//
//  Airline.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import CoreData

extension Airline: Comparable {
    
    static func withCode(_ code: String,  in context: NSManagedObjectContext) -> Airline {
        // look up code_ in Core Data
        let request = fetchRequest(NSPredicate(format: "code_ = %@", code))
        let results = (try? context.fetch(request)) ?? []
        // if found, return it
        if let airline = results.first {
            return airline
        } else {
        // if not, create one and fetch from FlightAware
            let airline = Airline(context: context)
            airline.code = code
            return airline
        }
    }
    
    
    static func update (info: AirlineInfo, context: NSManagedObjectContext) {
        if let code = info.icao {
            let airline = self.withCode(code, in: context)
            airline.name = info.name
            airline.shortname = info.shortname ?? info.callsign
            try? context.save()
        }
    }

    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Airline> {
        let request = NSFetchRequest<Airline>(entityName: "Airline")
        request.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
        request.predicate = predicate
        return request
    }
    
    static func searchPredicate(query: String,field: String)-> NSPredicate? {
        if query.isEmpty {return nil}
        else {
          return  NSPredicate(format: "%K BEGINSWITH[cd] %@",field,query)
        }
    }
    
    var code: String {
        get { code_! } // TODO: maybe protect against when app ships?
        set { code_ = newValue }
    }
    
    var name: String {
        get { name_ ?? code }
        set { name_ = newValue }
    }
    
    var shortname: String {
        get { (shortname_ ?? "").isEmpty ? name : shortname_! }
        set { shortname_ = newValue }
    }
    
    var flights: Set<Flight> {
        get { (flights_ as? Set<Flight>) ?? [] }
        set { flights_ = newValue as NSSet }
    }
    
    var friendlyName: String { shortname.isEmpty ? name : shortname }

    public var id: String { code }

    public static func < (lhs: Airline, rhs: Airline) -> Bool {
        lhs.name < rhs.name
    }
}
