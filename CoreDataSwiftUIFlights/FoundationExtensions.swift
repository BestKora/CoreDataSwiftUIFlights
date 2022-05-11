//
//  FoundationExtensions.swift
//  Enroute
//
//  Created by CS193p Instructor.
//  Copyright © 2020 Stanford University. All rights reserved.
//

import Foundation

extension Data {
    var utf8: String? { String(data: self, encoding: .utf8 ) }
}

extension String {
    var trim: String {
        var trimmed = self.drop(while: { $0.isWhitespace })
        while trimmed.last?.isWhitespace ?? false {
            trimmed = trimmed.dropLast()
        }
        return String(trimmed)
    }

    var base64: String? { self.data(using: .utf8)?.base64EncodedString() }
    
    func contains(elementIn array: [String]) -> Bool {
        array.contains(where: { self.contains($0) })
    }
}
//-----------------------------------------

func / (lhs: Measurement<UnitLength>, rhs: Measurement<UnitDuration>) -> Measurement<UnitSpeed> {
    let quantity = lhs.converted(to: .meters).value / rhs.converted(to: .seconds).value
    let resultUnit = UnitSpeed.metersPerSecond
    return Measurement(value: quantity, unit: resultUnit)
}

extension Double {
    func convert(from:UnitLength, to: UnitLength) -> Measurement<UnitLength> {
        let measurement = Measurement(value: self, unit: from)
        return measurement.converted(to: to)
    }
    func convert(from:UnitSpeed, to: UnitSpeed) -> Measurement<UnitSpeed> {
        let measurement = Measurement(value: self, unit: from)
        return measurement.converted(to: to)
    }
}
extension Measurement {
    func format() -> String {
      let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        formatter.locale = Locale(identifier: Locale.preferredLanguages.first!)
        formatter.numberFormatter.minimumFractionDigits = 0
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.numberFormatter.groupingSeparator = " "
        return formatter.string(from: self)
    }
}

extension TimeInterval {
    var hourMinuteSecond: String {
        String(format:"%d:%02d:%02d", hour, minute, second)
    }
    
    var hourMinuteUnit: String {
        Measurement(value: Double(Int((self/3600).truncatingRemainder(dividingBy: 3600))),
                    unit: UnitDuration.hours).format() + " " +
        Measurement(value: Double(Int((self/60).truncatingRemainder(dividingBy: 60))),
                    unit: UnitDuration.minutes).format()
    }
    
    var hourMinute: String {
        String(format:"%d hours %02d min", hour, minute)
    }
    var minuteSecond: String {
        String(format:"%d:%02d", minute, second)
    }
    var hour: Int {
        Int((self/3600).truncatingRemainder(dividingBy: 3600))
    }
    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
}

