//
//  PaymentTemplateData.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation
import CoreText

struct PaymentTemplateData: Equatable {
    
    let groupName: String
    let name: String
    let parameterList: [TransferAbstract]
    let paymentTemplateId: Int
    let sort: Int
    let svgImage: SVGImageData
    let type: Kind
}

//MARK: - Types

extension PaymentTemplateData {
    
    enum Kind: String, Codable, Equatable {
        
        case card2Card = "Card2Card"
        case card2Account = "Card2Account"
        case account2Card = "Account2Card"
        case account2Account = "Account2Account"
        case elecsnet = "ELECSNET"
        case card2Phone = "Card2Phone"
        case account2Phone = "Account2Phone"
        case sfp = "SFP"
        case me2MeDebet = "ME2ME_DEBET"
        case external = "External"
        case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
        case mobile = "MOBILE"
        case contactAddressless = "CONTACT_ADDRESSLESS"
        case direct = "DIRECT"
        case internet = "INTERNET"
    }
    
    struct SortData: Codable, Equatable {
        
        let paymentTemplateId: Int
        let sort: Int
    }
}

//MARK: - Codable

extension PaymentTemplateData: Codable {
    
    private enum CodingKeys : String, CodingKey {
        case groupName, name, parameterList, paymentTemplateId, sort, svgImage, type
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        groupName = try container.decode(String.self, forKey: .groupName)
        name = try container.decode(String.self, forKey: .name)
        
        var parameterListContainer = try container.nestedUnkeyedContainer(forKey: .parameterList)
        var parameterListDecoded = [TransferAbstract]()
        
        while parameterListContainer.isAtEnd == false {
            
            if let transfer = try? parameterListContainer.decode(Transfer.self) {
                
                parameterListDecoded.append(transfer)
                
            } else if let transferAnyway = try? parameterListContainer.decode(TransferAnyway.self) {
                
                parameterListDecoded.append(transferAnyway)
                
            } else if let transferMe2Me = try? parameterListContainer.decode(TransferMe2Me.self) {
                
                parameterListDecoded.append(transferMe2Me)
                
            } else {
                
                let transferAbstract = try parameterListContainer.decode(TransferAbstract.self)
                parameterListDecoded.append(transferAbstract)
            }
        }
        
        parameterList = parameterListDecoded
        paymentTemplateId = try container.decode(Int.self, forKey: .paymentTemplateId)
        sort = try container.decode(Int.self, forKey: .sort)
        svgImage = try container.decode(SVGImageData.self, forKey: .svgImage)
        type = try container.decode(Kind.self, forKey: .type)
    }
}
