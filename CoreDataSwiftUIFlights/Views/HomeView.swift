//
//  HomeView.swift
//  JSONCoreDataFlights
//
//  Created by Tatiana Kornilova on 27.02.2022.
//

import SwiftUI

struct HomeView: View {
   @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        TabView {
            let airport = Airport.withICAO("KSFO", context: viewContext)
            FlightsView( flightSearch: FlightSearch(/*destination: airport*/))
                .tabItem{
                    Label("Flights", systemImage: "airplane")
                    Text("Flights")
                }
            AirportsView()
                .tabItem{
                    Label("Airports", systemImage: "globe")
                    Text("Airports")
                }
                
            AirlinesView()
                .tabItem{
                    Label("Airlines", systemImage: "suitcase.cart.fill")
                    Text("Airlines")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
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
        airport1.icao = "KPDX"
        airport1.latitude = 33.4342778
        airport1.longitude = -122.5968694
        airport1.name = "Phoenix Sky Harbor Intl"
        airport1.city = "Phoenix"
        airport1.state = "AZ"
        airport1.countryCode = "US"
        airport1.location = "Phoenix" + " " + "AZ" + " " + "US"
        airport1.timezone = "America/Phoenix"
        viewContext.saveContext()
        
        let  airline = Airline(context: viewContext)
        airline.code = "UAL"
        airline.name = "United Air Lines Inc."
        airline.shortname = "United"
        
        let  airline1 = Airline(context: viewContext)
        airline1.code = "SKW"
        airline1.name = "SkyWest Airlines"
        airline1.shortname = "SkyWest"
    
        let flight = Flight(context: viewContext)
        flight.ident_ = "UAL1780"
        flight.origin_ = Airport.withICAO("KPDX", context: viewContext)
        flight.destination_ = Airport.withICAO("KSFO", context: viewContext)
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
        flight.progressPercent = 23
        flight.status_ = "Приземл. / Вырулив."
        flight.routeDistance = 551
        flight.filedAirspeed_ = 432
        flight.filedAltitude =  350
        flight.airline_ = Airline.withCode("UAL", in: viewContext)
        
        
        try? viewContext.save()
        
        return HomeView()
            .environment(\.managedObjectContext, viewContext)
            .padding()
    }
}
