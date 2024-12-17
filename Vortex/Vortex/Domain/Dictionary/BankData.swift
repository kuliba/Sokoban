//
//  BankData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation
import Tagged

struct BankData: Codable, Equatable, Hashable, Identifiable {
    
    var id: String { memberId }
    let memberId: String
    let memberName: String?
    let memberNameRus: String
    let paymentSystemCodeList: [String]
    let md5hash: String
    let svgImage: SVGImageData
    let bankCountry: String
}

//BankData Helper
extension BankData {
    
    var bankType: BankType {
        
        if let paymentSystem = self.paymentSystemCodeList.first, paymentSystem == "SFP" {
            
            return .sfp
            
        } else if let paymentSystem = self.paymentSystemCodeList.first, paymentSystem == "DIRECT" {
            
            return .direct
            
        } else {
            
            return .unknown
        }
    }
}

enum BankType: String, CaseIterable {
    
    case sfp
    case direct
    case unknown
    
    static var valid: [BankType] { [.sfp, .direct] }
    
    var name: String {
        
        switch self {
        case .sfp: return "Российские"
        case .direct: return "Иностранные"
        case .unknown: return "Неизвестно"
        }
    }
}



extension BankID {
    
  static let foraBankID: Self = .init("100000000217")
}

typealias BankID = Tagged<_BankID, String>
enum _BankID {}
