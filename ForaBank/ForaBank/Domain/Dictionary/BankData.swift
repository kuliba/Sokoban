//
//  BankData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct BankData: Codable, Equatable {
    
    let md5hash: String
    let memberId: String?
    let memberName: String?
    let memberNameRus: String
    let paymentSystemCodeList: [String]
    let svgImage: SVGImageData
}

//BankData Helper
extension BankData {
    
    var banksType: BanksTypes? {
        
        if let paymentSystem = self.paymentSystemCodeList.first, paymentSystem == "SFP" {
            
            return .sfp
        } else if let paymentSystem = self.paymentSystemCodeList.first, paymentSystem == "DIRECT" {
            
            return .direct
        } else {
            
            return nil
        }
    }
}

enum BanksTypes: String, CaseIterable {
    
    case sfp = "Российские"
    case direct = "Иностранные"
    case all = "Все"
}
