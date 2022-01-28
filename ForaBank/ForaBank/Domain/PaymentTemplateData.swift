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
    
    /*
    BETWEEN_THEIR - Между своими; INSIDE_BANK, OTHER_BANK - На другую карту; BY_PHONE, SFP - Перевод по номеру телефона; EXTERNAL_ENTITY, EXTERNAL_INDIVIDUAL - По реквизитам; CONTACT_ADDRESSLESS - Зарубеж и по РФ (Перевод через систему Contact); DIRECT - Зарубеж и по РФ (Перевод МИГ); HOUSING_AND_COMMUNAL_SERVICE - Услуги ЖКХ; MOBILE - Мобильная связь; INTERNET - Интернет, ТВ; TRANSPORT - Транспорт
     */
    
    enum Kind: String, Codable, Equatable {
        
        case betweenTheit = "BETWEEN_THEIR"
        case insideBank = "INSIDE_BANK"
        case otherBank = "OTHER_BANK"
        case byPhone = "BY_PHONE"
        case sfp = "SFP"
        case externalEntity = "EXTERNAL_ENTITY"
        case externalIndividual = "EXTERNAL_INDIVIDUAL"
        case contactAdressless = "CONTACT_ADDRESSLESS"
        case direct = "DIRECT"
        case housingAndCommunalService = "HOUSING_AND_COMMUNAL_SERVICE"
        case mobile = "MOBILE"
        case internet = "INTERNET"
        case transport = "TRANSPORT" 
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
