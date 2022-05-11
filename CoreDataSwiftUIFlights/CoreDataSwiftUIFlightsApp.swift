//
//  JSONCoreDataFlightsApp.swift
//  JSONCoreDataFlights
//
//  Created by Tatiana Kornilova on 07/02/2022.
//

import SwiftUI

@main
struct CoreDataSwiftUIFlightsApp: App {
    var body: some Scene {
        WindowGroup {
          HomeView()
                .environment(\.managedObjectContext,
                            PersistenceController.shared.viewContext)
            
        }
    }
}

