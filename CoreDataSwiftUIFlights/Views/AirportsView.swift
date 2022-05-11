//
//  AirportsView.swift
//  JSONCoreDataFlights
//
//  Created by Tatiana Kornilova on 23.02.2022.
//

import SwiftUI

struct AirportsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: Airport.fetchRequest(.all))
    var airports: FetchedResults<Airport>
    
    @State private var query = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(airports) { airport in
                        NavigationLink {
                            AirportDetailView(airport: airport)
                        } label: {
                            HStack{
                                Text( "**\(airport.icao)**")
                                    .foregroundColor(.purple)
                                Text(airport.friendlyName )
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationBarItems(trailing: load)
            }
            .navigationTitle("Airports")
        }
        .searchable(text: $query, placement:.navigationBarDrawer(displayMode: .always) ,prompt: "Search airport by city_" )
        .onChange(of: query) { newValue in
            airports.sortDescriptors = [SortDescriptor(\.name)]
            airports.nsPredicate =  !newValue.isEmpty ? Airport.searchPredicate(query: newValue, field: "city_"): .all
        }
    }
    
    let loadCoreData = LoadFlights ()
    var load: some View {
        Button("Load") {
            loadCoreData.load()
        }
    }
}

struct AirportsView_Previews: PreviewProvider {
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
        
            try? viewContext.save()
        
        return ZStack {
        AirportsView().environment(\.managedObjectContext, viewContext)
        }
    }
}
