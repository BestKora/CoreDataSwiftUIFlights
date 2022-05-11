//
//  FilterFlights.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import SwiftUI
import MapKit

struct FilterFlights: View {
    
    @FetchRequest(fetchRequest: Airport.fetchRequest(.all)) var airports: FetchedResults<Airport>
    @FetchRequest(fetchRequest: Airline.fetchRequest(.all)) var airlines: FetchedResults<Airline>

    @Binding var flightSearch: FlightSearch
    @Binding var isPresented: Bool
    
    @State private var draft: FlightSearch
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
    init(flightSearch: Binding<FlightSearch>, isPresented: Binding<Bool>) {
        _flightSearch = flightSearch
        _isPresented = isPresented
        _draft = State(wrappedValue: flightSearch.wrappedValue)
        _mapRegion = State(initialValue: MKCoordinateRegion(center: self.draft.destination?.coordinate ?? CLLocationCoordinate2D(latitude: 37.6188056, longitude: -122.3754167),
                                                            span:mapSpan))
    }
    
    var destination: Binding<MKAnnotation?> {
        return Binding<MKAnnotation?>(
            get: { return self.draft.destination },
            set: { annotation in
                if let airport = annotation as? Airport {
                    self.draft.destination = airport
                }
            }
        )
    }
    
   @State private var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
   
    private func updateMapRegion (){
        withAnimation(.easeIn){
            mapRegion = MKCoordinateRegion(center:self.draft.destination?.coordinate ?? CLLocationCoordinate2D(latitude: 37.6188056, longitude: -122.3754167),
                           span:mapSpan)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Destination", selection: $draft.destination) {
                        Text("Any").tag(Airport?.none)
                        ForEach(airports.sorted(), id: \.self) { (airport: Airport?) in
                           Text("\(airport?.friendlyName ?? "Any")").tag(airport)
                        }
                    }
                    .onChange(of: draft.destination) { _ in updateMapRegion() }
                    
                   Map (coordinateRegion: $mapRegion , annotationItems:airports.sorted()){ item in
                     //   MapPin(coordinate: item.coordinate)
                          MapAnnotation(coordinate: item.coordinate) {
                            let title = item.name ?? item.id
                            PinAnnotationView(title: title, subTitle: item.location ?? "", action: {
                                self.draft.destination = item
                                updateMapRegion()
                            })
                        }
                    }
                //  MapView(annotations: airports.sorted(), selection: destination)
                        .frame(minHeight: 400)
                }
                Section {
                    Picker("Origin", selection: $draft.origin) {
                        Text("Any").tag(Airport?.none)
                        ForEach(airports.sorted(), id: \.self) { (airport: Airport?) in
                            Text("\(airport?.friendlyName ?? "Any")").tag(airport)
                        }
                    }
                    Picker("Airline", selection: $draft.airline) {
                        Text("Any").tag(Airline?.none)
                        ForEach(airlines.sorted(), id: \.self) { (airline: Airline?) in
                            Text("\(airline?.friendlyName ?? "Any")").tag(airline)
                        }
                    }
                    Toggle(isOn: $draft.inTheAir) { Text("Enroute Only") }
                }
            }
            .navigationBarTitle("Filter Flights")
            .navigationBarItems(leading: cancel, trailing: done)
        }
    }
    
    var cancel: some View {
        Button("Cancel") {
            self.isPresented = false
        }
    }
    
    var done: some View {
        Button("Done") {
        //    if self.draft.destination != self.flightSearch.destination {
        //        self.draft.destination.fetchIncomingFlights()
       //     }
            self.flightSearch = self.draft
            self.isPresented = false
        }
    }
}

