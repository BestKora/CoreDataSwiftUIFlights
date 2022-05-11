//
//  FlightsFromAPI.swift
//  ReadJSONFlights
//
//  Created by Tatiana Kornilova on 27/01/2022.
//

import Foundation
import Combine

class FromAJSONAPI {
    public static let shared = FromAJSONAPI()
    
    // Выборка данных Модели <T> из файла в Bundle
       func fetch<T: Decodable>(_ nameJSON: String) -> AnyPublisher<T, Error> {
                 Just (nameJSON)
                 .flatMap { (nameJSON) -> AnyPublisher<Data, Never> in
                     let path = Bundle.main.path(forResource:nameJSON, ofType: "json")!
                     let data = FileManager.default.contents(atPath: path)!
                     return Just(data)
                     .eraseToAnyPublisher()
                   }
                   .decode(type: T.self, decoder: jsonDecoder)
                   .receive(on: RunLoop.main)
                   .eraseToAnyPublisher()                                    
       }
    
    private let jsonDecoder: JSONDecoder = {
           let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
           let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        jsonDecoder.dateDecodingStrategy = .iso8601
            return jsonDecoder
          }()
    
    private var subscriptions = Set<AnyCancellable>()
    
    deinit {
           for cancell in subscriptions {
               cancell.cancel()
           }
       }
}
