//
//  QRCode.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.10.2022.
//

import Foundation

/*
 ST00012|Name=ПАО "Калужская сбытовая компания"|PersonalAcc=40702810600180000156|BankName=Тульский филиал АБ "РОССИЯ"|BIC=047003764|CorrespAcc=30101810600000000764|PersAcc=110110581|Sum=66671|Purpose= лс 110110581 ЭЭ|PayeeINN=4029030252|KPP=402801001|TechCode=02|Category=1|KSK_PeriodPok=202208|KSK_Type=1|Amount=6835
 */

struct QRCode {
    
    let type: String //ST00012
    let rawData: [String: String] // name : ПАО "Калужская сбытовая компания"
    
    init(type: String, rawData: [String : String]) {
        self.type = type
        self.rawData = rawData
    }
    
    init?(string: String) {
        
        let stringData = Self.separatedString(string: string)

        self.rawData = Self.rawDataMapping(qrStringData: stringData)
        
        guard let type = Self.qrCodeType(stringArray: stringData) else { return nil }
        self.type = type
        
    }
    
    func value<Value>(type: QRParameter.Kind, mapping: QRMapping) throws -> Value? {
        
        var rawDataKey: Value?
        
        for map in mapping.allParameters {
            
            if map.parameter == type {
                
                let keys = map.keys
                
                keys.forEach { value in

                    if Value.self == map.swiftType {
                        
                        switch map.type {
                        case .string:
                            rawDataKey = self.rawData.filter { $0.key == value }.first?.value as? Value
                            
                        case .integer:
                            rawDataKey = self.rawData.filter { $0.key == value }.first?.value as? Value
                            
                        case .double:
                            guard let value = self.rawData.filter({ $0.key == value }).first?.value else { return }
                            let doubleValue = (value as NSString).doubleValue
                            rawDataKey = round( doubleValue / 100) as? Value
                            print()
                        }
                    }
                }
            }
        }
        
        return rawDataKey
    }
    
    static func separatedString(string: String) -> [String] {
        
        return string.components(separatedBy: "|")
    }
    
    static func qrCodeType(stringArray: [String]) -> String? {
        
        guard let type = stringArray.first else { return nil }
        
        return type
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



// let qrCode = QRCode(string: qrString)
//1 инн?
// if let innParameter: String = qrCode.value(type: .inn, mapinng: qrMapping) {


// let amount: Double = qrCode.value(type: .amount, mapinng: qrMapping)
//let innParameter: Double = qrCode.value(type: .inn, mapinng: qrMapping): ERROR

