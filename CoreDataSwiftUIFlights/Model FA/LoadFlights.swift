//
//  FlightFromViewModel.swift
//  ReadJSONFlights
//
//  Created by Tatiana Kornilova on 27/01/2022.
//

import Foundation
import Combine
import CoreData

struct ConstantsLoad {
    static var nameAirportFile = "AIRPORTS"
    static var nameAirlineFile = "AIRLINES"
    static var nameFlightsFile =  "FLIGHTS" // "SFO" //  "ORD"
}

final class LoadFlights {
    var context : NSManagedObjectContext {
           PersistenceController.shared.container.viewContext
    }
    var flightsFromFA = FlightsInfo(arrivals: [], departures: [],
                                    scheduledArrivals: [], scheduledDepartures: [])
    var airportsFromFA = [AirportInfo]()
    var airlinesFromFA = [AirlineInfo]()
    
    func load () {
        getAirports() //-----Airports
        getAirLines() //-----Airlines
        getFlights()  //-----Flights
    }
    
    private func getFlights(){
        FromAJSONAPI.shared.fetch (ConstantsLoad.nameFlightsFile)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("Success Flights")
                    if let context = self?.context {
                        let flightsFA = (self?.flightsFromFA.arrivals ?? [])
                        + (self?.flightsFromFA.departures ?? [])
                        + (self?.flightsFromFA.scheduledArrivals ?? [])
                        + (self?.flightsFromFA.scheduledDepartures ?? [])
                        for flightFA in flightsFA {
                            Flight.update(from: flightFA, in: context )
                        }
                    }
                }
            }, receiveValue: { (flightFrom: FlightsInfo) in
                self.flightsFromFA = flightFrom
                print ("received \(flightFrom.arrivals.count)")
            })
            .store(in: &self.cancellableSet)
    }
    
    private func getAirLines(){
        FromAJSONAPI.shared.fetch (ConstantsLoad.nameAirlineFile)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("Success airline")
                    if let context = self?.context, let airlines = self?.airlinesFromFA {
                        for airline in airlines{
                           Airline.update(info: airline, context: context )
                        }
                    }
                }
            }, receiveValue: { (airlinesFrom: [ AirlineInfo]) in
                self.airlinesFromFA = airlinesFrom
                print ("received \(airlinesFrom.count)")
            })
            .store(in: &self.cancellableSet)
    }
    
    private func getAirports(){
        FromAJSONAPI.shared.fetch (ConstantsLoad.nameAirportFile)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print(error)
                case .finished:
                    print("Success airport")
                    if let context = self?.context, let airports = self?.airportsFromFA {
                        for airport in airports {
                           Airport.update(from: airport, context: context )
                        }
                    }
                }
            }, receiveValue: { (airportsFrom: [AirportInfo]) in
                self.airportsFromFA = airportsFrom
                print ("received \(airportsFrom.count)")
            })
            .store(in: &self.cancellableSet)
    }
    private var cancellableSet: Set<AnyCancellable> = []
}
