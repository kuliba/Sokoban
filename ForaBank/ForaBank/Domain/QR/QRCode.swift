//
//  QRCode.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.10.2022.
//

import Foundation

struct QRCode {
    
    let original: String
    let rawData: [String: String] // name : ПАО "Калужская сбытовая компания"
    
    init(original: String, rawData: [String : String]) {
        
        self.original = original
        self.rawData = rawData
    }
    
    init?(string: String) {
        
        let stringData = Self.separatedString(string: string)
        let rawData = Self.rawDataMapping(qrStringData: stringData)
        
        guard rawData.keys.isEmpty == false else {
            return nil
        }
        
        self.init(original: string, rawData: rawData)
    }
    
    
    func value<Value>(type: QRParameter.Kind, mapping: QRMapping) throws -> Value? {
        
        guard let parameter = mapping.allParameters.first(where: { $0.parameter.name == type.name }) else {
            return nil
        }
        
        for key in parameter.keys {
            
            guard var value = rawData[key] else {
                continue
            }
            
            guard parameter.swiftType == Value.self || Value.self == String.self else {
                throw QRCodeError.typeMissmatch
            }
            
            switch parameter.type {
                
            case .string:
                return value as? Value
                
            case .integer:
                return Int(value) as? Value
                
            case .double:
                value.insert(".", at: value.index(value.endIndex, offsetBy: -2))
                let doubleValue = NumberFormatter().number(from: value)?.doubleValue
                return doubleValue as? Value
                
            case .date:
                return value as? Value
            }
        }
        return nil
    }
    
    static func separatedString(string: String) -> [String] {
        
        return string.components(separatedBy: "|")
    }
    
    func check(mapping: QRMapping) -> QRMapping.FailData? {
        
        let rawDataKays = self.rawData.map{ $0.key }
        
        let parametersKays = mapping.allParameters.flatMap{ $0.keys }
        
        let unknownKeys = rawDataKays.difference(from: parametersKays)
        
        if unknownKeys.count > 0 {
            
            return QRMapping.FailData(rawData: original, parsed: rawData, unknownKeys: unknownKeys)
        } else {
            
            return nil
        }
    }
    
    func stringValue(type: QRParameter.Kind, mapping: QRMapping) -> String? {
        
        guard let parameter = mapping.allParameters.first(where: { $0.parameter.name == type.name }) else {
            return nil
        }
        
        for key in parameter.keys {
            
            guard let value = rawData[key] else { return nil }
            
            return value
        }
        
        return nil
    }
    
    static func rawDataMapping(qrStringData: [String]) -> [String: String] {
        
        var tempRawData: [String: String] = [:]
        
        qrStringData.forEach { component in
            
            if component.contains("=") {
                let tempArray = component.components(separatedBy: "=")
                let componentKey = tempArray[0].lowercased()
                let componentValue = tempArray[1]
                tempRawData[componentKey] = componentValue
            }
        }
        return tempRawData
    }
}

enum QRCodeError: Error {
    case typeMissmatch
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.subtracting(otherSet))
    }
}
