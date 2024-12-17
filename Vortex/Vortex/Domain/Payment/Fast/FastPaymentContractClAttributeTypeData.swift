//
//  FastPaymentContractClAttributeTypeData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct FastPaymentContractClAttributeTypeData: Codable, Equatable {
    
    let clientInfo: ClientDocBaseInfoType?
}

extension FastPaymentContractClAttributeTypeData {
    
    struct ClientDocBaseInfoType: Codable, Equatable {
        
        let address: String?
        let clientId: Int?
        let clientName: String?
        let clientPatronymicName: String?
        let clientSurName: String?
        let docType: String?
        let inn: String?
        let name: String?
        let nm: String?
        let regNumber: String?
        let regSeries: String?
        
        private enum CodingKeys: String, CodingKey {
            
            case clientId = "clientID"
            case address, clientName, clientPatronymicName, clientSurName, docType, inn, name, nm, regNumber, regSeries
        }
    }
}
