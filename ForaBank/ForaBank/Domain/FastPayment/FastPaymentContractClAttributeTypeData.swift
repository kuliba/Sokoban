//
//  FastPaymentContractClAttributeTypeData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct FastPaymentContractClAttributeTypeData: Codable, Equatable {
    
    let clientInfo: ClientDocBaseInfoType?
    
    struct ClientDocBaseInfoType: Codable, Equatable {
        
        let address: String?
        let clientID: Int?
        let clientName: String?
        let clientPatronymicName: String?
        let clientSurName: String?
        let docType: String?
        let inn: String?
        let name: String?
        let nm: String?
        let regNumber: String?
        let regSeries: String?
    }
}
