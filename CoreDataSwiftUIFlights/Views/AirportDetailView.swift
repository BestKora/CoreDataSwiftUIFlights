//
//  AirportDetailView.swift
//  JSONCoreDataFlights
//
//  Created by Tatiana Kornilova on 26.02.2022.
//

import SwiftUI
import MapKit

struct AirportDetailView: View {
    @ObservedObject var airport: Airport
    @State private var to: Int = 0
    
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    init(airport: Airport){
        self.airport = airport
        _mapRegion = State(initialValue: MKCoordinateRegion(center: self.airport.coordinate, span:mapSpan))
    }
    
    var body: some View {
        VStack{
            Map (coordinateRegion: $mapRegion , annotationItems:[airport]){ item in
                MapPin(coordinate: item.coordinate)}
            .frame(minHeight: 120)
            Picker("", selection: $to){
                Image(systemName: "airplane.arrival").tag(0)
                Image(systemName: "airplane.departure").tag(1)
            }
            .pickerStyle(.segmented)
            if to == 0 {
                List {
                    ForEach(Array(airport.flightsTo).sorted{$0.arrival < $1.arrival}) { flight in
                        FlightViewShort(flight: flight, airport: airport)
                    }
                }
            } else {
                List {
                    ForEach(Array(airport.flightsFrom).sorted{$0.depature < $1.depature}) { flight in
                        FlightViewShort(flight: flight, airport:airport)
                    }
                }
            }
        }
        .navigationTitle(airport.nameAirport)
    }
}

struct AirportDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.viewContext
 
        let  airport = Airport(context: viewContext)
        airport.icao = "KSFO"
        airport.latitude = 37.6188056
        airport.longitude = -122.3754167
        airport.name = "San Francisco Int'l"
        airport.city = "San Francisco"
        airport.state = "CA"
        airport.countryCode = "US"
        airport.location = "San Francisco" + " " + "CA" + " " + "US"
        airport.timezone = "America/Los_Angeles"
        
        let  airport1 = Airport(context: viewContext)
        airport1.icao = "KJFK"
        airport1.latitude = 40.6399278
        airport1.longitude = -73.7786925
        airport1.name = "John F Kennedy Intl"
        airport1.city = "New York"
        airport1.state = "NY"
        airport1.countryCode = "US"
        airport1.location = "New York" + " " + "NY" + " " + "US"
        airport1.timezone = "America/New_York"
        
        let  airport2 = Airport(context: viewContext)
        airport2.icao = "KSEA"
        airport2.latitude = 47.4498889
        airport2.longitude = -122.3117778
        airport2.name = "Seattle-Tacoma Intl"
        airport2.city = "Seattle"
        airport2.state = "WA"
        airport2.countryCode = "US"
        airport2.location = "Seattle" + " " + "WA" + " " + "US"
        airport2.timezone = "America/Los_Angeles"
        
        let flight = Flight(context: viewContext)
        flight.ident_ = "UAL1780"
        //-----
        flight.origin_ = Airport.withICAO("KJFK", context: viewContext)
        flight.destination_ = Airport.withICAO("KSFO", context: viewContext)
        //-----
        flight.actualOff = ISO8601DateFormatter().date(from: "2022-01-26T16:22:56Z")
        flight.scheduledOff_ = ISO8601DateFormatter().date(from:"2022-01-26T16:10:00Z")
        flight.estimatedOff = ISO8601DateFormatter().date(from:"2022-01-26T16:22:56Z")
        flight.aircraftType_ = "A319"
        flight.scheduledOn = ISO8601DateFormatter().date(from:"2022-01-26T17:13:00Z")
        flight.estimatedOn_ = ISO8601DateFormatter().date(from:"2022-01-26T17:41:00Z")
        flight.actualOn = ISO8601DateFormatter().date(from:"2022-01-26T17:41:00Z")
        flight.scheduledIn = ISO8601DateFormatter().date(from:"2022-01-26T17:50:00Z")
        flight.estimatedIn = ISO8601DateFormatter().date(from:"2022-01-26T17:49:00Z")
        flight.actualIn = nil
        flight.progressPercent = 100
        flight.status_ = "Приземл. / Вырулив."
        flight.routeDistance = 551
        flight.filedAirspeed_ = 432
        flight.filedAltitude =  350
        flight.airline_ = Airline.withCode("UAL", in: viewContext)
        
        let flight1 = Flight(context: viewContext)
        flight1.ident_ = "UAL1541"
        //-----
        flight1.origin_ = Airport.withICAO("KSFO", context: viewContext)
        flight1.destination_ = Airport.withICAO("KSEA", context: viewContext)
        //-----
        flight1.actualOff = nil
        flight1.scheduledOff_ = ISO8601DateFormatter().date(from:"2022-01-26T17:22:00Z")
        flight1.estimatedOff = ISO8601DateFormatter().date(from:"2022-01-26T17:41:00Z")
        flight1.aircraftType_ = "AA319"
        flight1.scheduledOn = ISO8601DateFormatter().date(from:"2022-01-26T18:59:00Z")
        flight1.estimatedOn_ = ISO8601DateFormatter().date(from:"2022-01-26T19:18:00Z")
        flight1.actualOn = nil
        flight1.scheduledIn = ISO8601DateFormatter().date(from:"2022-01-26T19:40:00Z")
        flight1.estimatedIn = ISO8601DateFormatter().date(from:"2022-01-26T19:22:00Z")
        flight1.actualIn = nil
        flight1.progressPercent = 0
        flight1.status_ = "Вырулив. / Посадка закончена"
        flight1.routeDistance = 680
        flight1.filedAirspeed_ = 446
        flight1.filedAltitude =  380
        flight1.airline_ = Airline.withCode("UAL", in: viewContext)
            try? viewContext.save()
       
        return AirportDetailView(airport: airport)
            .environment(\.managedObjectContext, viewContext)
    }
}
