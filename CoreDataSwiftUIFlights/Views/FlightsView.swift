//
//  ContentView.swift
//  JSONCoreDataFlights
//
//  Created by Tatiana Kornilova on 07/02/2022.
//

import SwiftUI
import CoreData

//------ search Flights by this creteria ----
struct FlightSearch: Equatable {
    var destination: Airport?
    var origin: Airport?
    var airline: Airline?
    var inTheAir: Bool = false
}

extension FlightSearch {
    
    var predicate: NSPredicate {
        guard destination != nil || origin != nil || airline != nil || inTheAir else {return NSPredicate.all}
            var format = destination != nil ? "destination_ = %@" : ""
            var args: [NSManagedObject] = destination != nil ? [destination!]: [] // args could be [Any] if needed
            if origin != nil {
                format += format == "" ? "origin_ = %@" : " and origin_ = %@"
                args.append(origin!)
            }
            if airline != nil {
                format += format == "" ? "airline_ = %@" : " and airline_ = %@"
                args.append(airline!)
            }
            if inTheAir {
                format += format == "" ? "actualOn = nil" : " and actualOn = nil"
            }
        if format == "" {
            return NSPredicate.all
        }
            return NSPredicate(format: format, argumentArray: args)
    }
}

struct FlightsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(fetchRequest: Flight.fetchRequest(.all)) var flights: FetchedResults<Flight>
    
    @State private var query = ""
    
    @State var flightSearch:  FlightSearch
    @State private var showFilter = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach (flights) { flight in
                    FlightView(flight: flight)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarItems(leading: load,trailing: filter)
            .navigationTitle("Flights  (\(flights.count))")
        }
        .task { if flights.count == 0 {loadCoreData.load()}}
        //------search Flight by name of city for destination -----
        .searchable(text: $query, placement:.navigationBarDrawer(displayMode: .always), prompt: "Search flights by destination_.city_" )
        
       .onChange(of: query) { newValue in
             flights.nsPredicate =  !newValue.isEmpty ? Flight.searchPredicate(query: newValue, field: "destination_.city_") : .all
        }
        //------Filter flights-----
       .onChange(of: flightSearch ){ newValue in
            flights.sortDescriptors = [SortDescriptor(\.progressPercent)]
            flights.nsPredicate =  newValue.predicate
        }
    }
    
    var filter: some View {
        Button("Filter") {
            self.showFilter = true
        }
        .sheet(isPresented: $showFilter) {
            FilterFlights(flightSearch: self.$flightSearch, isPresented: self.$showFilter)
                .environment(\.managedObjectContext, self.viewContext)
        }
    }
    
    let loadCoreData = LoadFlights ()
    var load: some View {
        Button("Load") {
            loadCoreData.load()
        }
    }
}

struct FlightView: View {
    var flight: Flight
    
    var body: some View {
        VStack(alignment: .leading){
            Text(flight.ident + "  " + flight.origin.city + " -> " + flight.destination.city).font(.system(size: 16, weight: .semibold, design: .rounded))
            Text(flight.airline.name + "        " + flight.aircraftType).foregroundColor(.blue)
          
            Text(flight.distanceAndSpeed)
           
            HStack {
                Text(flight.depature.formatted(date: .abbreviated, time: .shortened))
                Text("\(Image(systemName: "arrow.up.right"))").foregroundColor(.blue)
            }
            HStack {
                Text(flight.arrival.formatted(date: .abbreviated, time: .shortened))
                Text("\(Image(systemName: "arrow.down.right"))")
                    .foregroundColor(flight.actualOn != nil ? .blue: .red)
                Spacer()
                Text(flight.actualOn != nil ? "": "estimate").foregroundColor(.red)
            }
            
            Text(flight.hoursAndSpeed)
            Text(flight.status)
            Text("\(flight.progressPercent)%").font(.title2)
            ProgressView(value: Float(flight.progressPercent), total: 100.0)
        }
    }
}

struct FlightViewShort: View {
    var flight: Flight
    var airport: Airport
    
    var body: some View {
        VStack( alignment: .leading) {
            HStack(spacing: 10){
                if flight.destination == airport {
                    Text(flight.scheduledOn!.formatted(date: .omitted, time: .shortened))
                        .font(.callout).foregroundColor(.secondary)
                    Text(flight.origin.city).font(.system(size: 16, weight: .semibold, design: .rounded))
                    Spacer()
                    Text(flight.ident).font(.callout).foregroundColor(.secondary)
                } else {
                    Text(flight.scheduledOff.formatted(date: .omitted, time: .shortened))
                        .font(.callout).foregroundColor(.secondary)
                    Text(flight.destination.city ).font(.system(size: 16, weight: .semibold, design: .rounded))
                    Spacer()
                    Text(flight.ident).font(.callout).foregroundColor(.secondary)
                }
            }
            HStack{
                if flight.destination == airport {
                    Text(flight.arrival.formatted(date: .omitted, time: .shortened))
                        .font(.callout).foregroundColor(flight.actualOn != nil ? .purple:.red)
                    Spacer()
                    Text(flight.actualOn != nil ? "Прилетел": flight.statusShort).foregroundColor(flight.actualOn != nil ? .purple:.red).font(.footnote)
                } else {
                    Text(flight.depature.formatted(date: .omitted, time: .shortened))
                        .font(.callout).foregroundColor(flight.actualOff != nil ? .purple:.red)
                    Spacer()
                    Text(flight.actualOff != nil ? "Вылетел": flight.statusShort).foregroundColor(flight.actualOff != nil ? .purple: .red).font(.footnote)
                }
               
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
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
        viewContext.saveContext()
    
        let  airport1 = Airport(context: viewContext)
        airport1.icao = "KPDX"
        airport1.latitude = 45.5887089
        airport1.longitude = -122.5968694
        airport1.name = "Portland Intl"
        airport1.city = "Portland"
        airport1.state = "OR"
        airport1.countryCode = "US"
        airport1.location = "Portland" + " " + "OR" + " " + "US"
        airport1.timezone = "America/Los_Angeles"
        
        let  airline = Airline(context: viewContext)
        airline.code = "UAL"
        airline.name = "United Air Lines Inc."
        airline.shortname = "United"
        
        viewContext.saveContext()
        
        let flight = Flight(context: viewContext)
        flight.ident_ = "UAL1780"
        //-----
        flight.origin = Airport.withICAO("KPDX", context: viewContext)
        flight.destination = Airport.withICAO("KSFO", context: viewContext)
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
        
        viewContext.saveContext()
        
      return FlightsView( flightSearch: FlightSearch())
            .environment(\.managedObjectContext, viewContext)
            .padding()
        
    }
}

