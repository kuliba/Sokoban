//
//  QRCode.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.10.2022.
//

import Foundation

struct QRCode: Equatable {
    
    let original: String
    let rawData: [String: String]
    
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
}

//MARK: - Value

extension QRCode {
    
    func stringValue(type: QRParameter.Kind, mapping: QRMapping) -> String? {
        
        guard let parameter = mapping.allParameters.first(where: { $0.parameter.name == type.name }) else {
            return nil
        }
        
        for key in parameter.keys {
            
            guard let value = rawData[key.lowercased()] else {
                continue
            }
            
            return value
        }
        
        return nil
    }
    
    func value<Value>(type: QRParameter.Kind, mapping: QRMapping) throws -> Value {
        
        guard let parameter = mapping.allParameters.first(where: { $0.parameter.name == type.name }) else {
            throw QRCode.Error.missingParameter
        }
        
        for key in parameter.keys {
            
            guard var value = rawData[key.lowercased()] else {
                continue
            }
            
            guard parameter.swiftType == Value.self || Value.self == String.self else {
                throw QRCode.Error.typeMissmatch
            }
            
            switch parameter.type {
            case .string:
                guard let stringValue = value as? Value else {
                    throw QRCode.Error.typeMissmatch
                }
                return stringValue
                
            case .integer:
                guard let intValue = Int(value) as? Value else {
                    throw QRCode.Error.typeMissmatch
                }
                return intValue
                
            case .double:
                guard value.count >= 2 else {
                    throw QRCode.Error.incorrectDoubleValue(value)
                }
                
                let formatter = NumberFormatter()
                formatter.locale = Locale(identifier: "en_US")
                
                value.insert(".", at: value.index(value.endIndex, offsetBy: -2))

                guard let doubleValue = formatter.number(from: value)?.doubleValue as? Value else {
                    throw QRCode.Error.typeMissmatch
                }
                
                return doubleValue
                
            case .date:
                let formatter = DateFormatter()
                for dateFormat in mapping.dateFormats {
                    
                    formatter.dateFormat = dateFormat
                    guard let dateValue = formatter.date(from: value) as? Value else {
                        continue
                    }
                    
                    return dateValue
                }
                
                throw QRCode.Error.incorrectDateValue(value)
            }
        }
        
        throw QRCode.Error.missingValue
    }
}

//MARK: - Fail Data

extension QRCode {
    
    func check(mapping: QRMapping) -> QRMapping.FailData? {
        
        var parsed = [QRMapping.FailData.ParsedData]()
        var unknownKeys = [String]()
        
        for (key, value) in rawData {

            if let parameter = mapping.allParameters.first(where: { $0.keys.contains(key) }) {
                
                parsed.append(.init(parameter: parameter.parameter, key: key, value: value, type: parameter.type))
                
            } else {
                
                unknownKeys.append(key)
            }
        }
        
        guard unknownKeys.isEmpty == false else {
            return nil
        }
        
        return .init(rawData: original, parsed: parsed, unknownKeys: unknownKeys)
    }
}

//MARK: - Helpers

extension QRCode {
    
    static func separatedString(string: String) -> [String] {
        
        return string.components(separatedBy: "|")
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

extension QRCode {
    
    enum Error: LocalizedError {
        
        case missingParameter
        case missingValue
        case typeMissmatch
        case incorrectDoubleValue(String)
        case incorrectDateValue(String)
    }
}


