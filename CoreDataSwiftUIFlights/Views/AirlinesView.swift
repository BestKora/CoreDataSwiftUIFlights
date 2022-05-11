//
//  AirlinesView.swift
//  JSONCoreDataFlights
//
//  Created by Tatiana Kornilova on 25.02.2022.
//

import SwiftUI

struct AirlinesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: Airline.fetchRequest(.all))
    var airlines: FetchedResults<Airline>
    
    @State private var query = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(airlines) { airline in
                        Text(airline.code + "  " + (airline.name))
                    }
                }
                .listStyle(PlainListStyle())
                .navigationBarItems(trailing: load)
            }
            .navigationTitle("Airlines")
        }
        .searchable(text: $query, placement:.navigationBarDrawer(displayMode: .always) ,prompt: "Search airline by name_" )
        .onChange(of: query) { newValue in
            airlines.sortDescriptors = [SortDescriptor(\.name_)]
            airlines.nsPredicate =  !newValue.isEmpty ? Airline.searchPredicate(query: newValue, field: "name_"): .all
        }
    }
    
    let loadCoreData = LoadFlights ()
    var load: some View {
        Button("Load") {
            LoadFlights ().load()
        }
    }
}


struct AirlinesView_Previews: PreviewProvider {
    static var previews: some View {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.viewContext
        
        let  airline = Airline(context: viewContext)
        airline.code = "UAL"
        airline.name = "United Air Lines Inc."
        airline.shortname = "United"
        
        let  airline1 = Airline(context: viewContext)
        airline1.code = "SKW"
        airline1.name = "SkyWest Airlines"
        airline1.shortname = "SkyWest"
        
        //     try? viewContext.save()
        
        return ZStack {
            AirlinesView().environment(\.managedObjectContext, viewContext)
        }
    }
}
