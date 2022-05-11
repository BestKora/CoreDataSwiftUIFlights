//
//  Flight.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import CoreData

extension Flight: Comparable {
 
    var airlineCode: String { String(ident.prefix(while: { !$0.isNumber })) }
    
    var duration: Double {Double(Int(estimatedOn.timeIntervalSince(estimatedOff!))) / 3600.0}
    var durationTime: Measurement<UnitDuration> {Measurement(value: duration,
                                                             unit: UnitDuration.hours)}
    
    // ----------Дальность полета и скорость полета по приборам (ППП)
    var distance: Measurement<UnitLength> {Double(routeDistance).convert(from: .miles,
                                                                         to: .kilometers)}
    var distanceInKm: String {distance.format()}
    var speedInKmHours: String {Double(filedAirspeed).convert(from: .knots,
                                                              to: .kilometersPerHour).format()}
    var distanceAndSpeed: String {"distance = " + distanceInKm + "   speed = " + speedInKmHours}
    
    // ----------Длительность полета и средняя скорость полета ------------
    var durationHoursMin: String {estimatedOn.timeIntervalSince(estimatedOff!).hourMinuteUnit}
    var averageSpeed:String { (distance / durationTime).converted(to: .kilometersPerHour).format()}
    var hoursAndSpeed: String {durationHoursMin +  "    aveSpeed = " + averageSpeed}
    
    var depature: Date {actualOff ?? estimatedOff!}
    var arrival: Date {actualOn ?? estimatedOn}
    
    //-------------------- Статус рейса ----------------------------------
    var statusShort: String {
        if status.components(separatedBy: "/") .count > 1 {
           let status1 = status.components (separatedBy: "/")[0] == " В пути"
            ?
            status.components(separatedBy: "/")[1]
            :
            status.components(separatedBy: "/")[1]
            if status1.contains(elementIn: ["Прил."]){
                return status1.components (separatedBy: "Прил.")[1]
            } else {
                return status1
            }
        } else {
            return status
        }
    }
    
    //-------------- Запросы -----------------------
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Flight> {
        let request = NSFetchRequest<Flight>(entityName: "Flight")
        request.sortDescriptors = [NSSortDescriptor(key: "progressPercent", ascending: true)]
        request.predicate = predicate
        return request
    }
    
    //--------------- Обновление ------------------
    static func update (from faflight: Arrival, in context: NSManagedObjectContext) {
            let request = fetchRequest(NSPredicate(format: "ident_ = %@", faflight.ident))
            let results = (try? context.fetch(request)) ?? []
            let flight = results.first ?? Flight(context: context)
            flight.ident_ = faflight.ident
            //-----
            flight.origin_ =  Airport.withICAO(faflight.origin.code, context: context)
            flight.destination_ = Airport.withICAO(faflight.destination.code, context: context)
            //-----
            flight.actualOff = faflight.actualOff
            flight.scheduledOff_ = faflight.scheduledOff
            flight.estimatedOff = faflight.estimatedOff
            flight.aircraftType_ = faflight.aircraftType
            flight.scheduledOn = faflight.scheduledOn
            flight.estimatedOn_ = faflight.estimatedOn
            flight.actualOn = faflight.actualOn
            flight.scheduledIn = faflight.scheduledIn
            flight.estimatedIn = faflight.estimatedIn
            flight.actualIn = faflight.actualIn
            flight.progressPercent = Int32(faflight.progressPercent)
            flight.status_ = faflight.status
            flight.routeDistance = Int32(faflight.routeDistance)
            flight.filedAirspeed_ = Int32(faflight.filedAirspeed ?? 0)
            flight.filedAltitude = Int32(faflight.filedAltitude ?? 0)
            flight.airline_ = Airline.withCode(faflight.airlineCode, in: context)
    
        do {
            try context.save()
        } catch(let error) {
            print("couldn't save flight update to CoreData: \(error.localizedDescription)")
        }
    }
    
    //---------------------- Predicates ----------------
    static func searchPredicate(query: String,field: String)-> NSPredicate? {
        if query.isEmpty {return nil}
        else {
          return  NSPredicate(format: "%K BEGINSWITH[cd] %@",field,query)
        }
    }
    
    static var searchPredicateInit: NSPredicate {
        let destination = Airport.withICAO("KSFO", context: PersistenceController.shared.container.viewContext)
        let format = "((destination1_ = %@ OR origin1_ = %@) AND actualOn = nil)"
        //destination1
       // and actualOn = nil
        let args: [NSManagedObject] = [destination,destination] // args could be [Any] if needed
        return  NSPredicate(format: format,args)
      }
    
    //----------- Syntax Sugar --------------
    var ident: String {
        get { ident_ ?? "Unknown" }
        set { ident_ = newValue }
    }
    
    public var id: String { ident }
    
    var destination: Airport {
        get { destination_! } // TODO: protect against nil before shipping?
        set { destination_ = newValue }
    }
    
    var origin: Airport{
        get { origin_! } // TODO: maybe protect against when app ships?
        set { origin_ = newValue }
    }
    
    var aircraftType: String {
        get { aircraftType_ ?? "Unknown" } // TODO: maybe protect against when app ships?
        set { aircraftType_ = newValue }
    }
    
    var scheduledOff: Date {
        get { scheduledOff_ ?? Date(timeIntervalSinceReferenceDate: 0) }
        set { scheduledOff_ = newValue }
    }
    
    var estimatedOn: Date {
        get { estimatedOn_ ?? Date(timeIntervalSinceReferenceDate: 0) }
        set { estimatedOn_ = newValue }
    }
    
    var filedAirspeed: Int32 {
        get { filedAirspeed_ }
        set { filedAirspeed_ = Int32(newValue )}
    }
    
    var status: String {
        get { status_ ?? "---" } // TODO: maybe protect against when app ships?
        set { status_ = newValue }
    }
    
    var airline: Airline {
        get { airline_! } // TODO: maybe protect against when app ships?
        set { airline_ = newValue }
    }
    
    //-------------- Comparable ---------------------
    public static func < (lhs: Flight, rhs: Flight) -> Bool {
        lhs.ident  < rhs.ident
    }
}
