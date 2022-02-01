//
//  PaymentTemplateData.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation
import CoreText

struct PaymentTemplateData: Equatable, Cachable, Identifiable {
    
    var id: Int { paymentTemplateId }
    let groupName: String
    let name: String
    let parameterList: [TransferAbstractData]
    let paymentTemplateId: Int
    let productTemplate: ProductTemplateData?
    let sort: Int
    let svgImage: SVGImageData
    let type: Kind
}

//MARK: - Types

extension PaymentTemplateData {
    
    enum Kind: String, Codable, Equatable, CaseIterable {
        
        case betweenTheir = "BETWEEN_THEIR"
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
        
        var description: String {
            
            switch self {
            case .betweenTheir: return "Между своими счетами"
            case .insideBank: return "Внутри банка"
            case .otherBank: return "В другой банк"
            case .byPhone: return "По номеру телефона"
            case .sfp: return "Перевод СБП"
            case .externalEntity: return "По реквизитам: компания"
            case .externalIndividual: return "По реквизитам: частный"
            case .contactAdressless: return "Перевод Контакт"
            case .direct: return "Перевод МИГ"
            case .housingAndCommunalService: return "Услуги ЖКХ"
            case .mobile: return "Мобильная связь"
            case .internet: return "Интернет, ТВ"
            case .transport: return "Транспорт"
            }
        }
    }
    
    struct SortData: Codable, Equatable {
        
        let paymentTemplateId: Int
        let sort: Int
    }
}

//MARK: - Codable

extension PaymentTemplateData: Codable {
    
    private enum CodingKeys : String, CodingKey {
        case groupName, name, parameterList, paymentTemplateId, productTemplate, sort, svgImage, type
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        groupName = try container.decode(String.self, forKey: .groupName)
        name = try container.decode(String.self, forKey: .name)
        
        var parameterListContainer = try container.nestedUnkeyedContainer(forKey: .parameterList)
        var parameterListDecoded = [TransferAbstractData]()
        
        while parameterListContainer.isAtEnd == false {
            
            if let transferAnyway = try? parameterListContainer.decode(TransferAnywayData.self) {
                
                parameterListDecoded.append(transferAnyway)
                
            } else if let transferMe2Me = try? parameterListContainer.decode(TransferMe2MeData.self) {
                
                parameterListDecoded.append(transferMe2Me)
                
            } else {
                
                let transfer = try parameterListContainer.decode(TransferData.self)
                parameterListDecoded.append(transfer)
            }
        }
        
        parameterList = parameterListDecoded
        paymentTemplateId = try container.decode(Int.self, forKey: .paymentTemplateId)
        productTemplate = try container.decodeIfPresent(ProductTemplateData.self, forKey: .productTemplate)
        sort = try container.decode(Int.self, forKey: .sort)
        svgImage = try container.decode(SVGImageData.self, forKey: .svgImage)
        type = try container.decode(Kind.self, forKey: .type)
    }
}

//MARK: - Convenience SPF Properties

extension PaymentTemplateData {
    
    var spfAmount: Double? {
        
        guard let transfer = parameterList.first else {
            return nil
        }
        
        return transfer.amount
    }
    
    var spfPhoneNumber: String? {
        
        guard let transfer = parameterList.first as? TransferAnywayData,
              let phoneData = transfer.additional.first(where: { $0.fieldname == "RecipientID" })  else {
            return nil
        }
        
        return phoneData.fieldvalue
    }
    
    var spfBankId: String? {
        
        guard let transfer = parameterList.first as? TransferAnywayData,
              let bankData = transfer.additional.first(where: { $0.fieldname == "BankRecipientID" })  else {
            return nil
        }
        
        return bankData.fieldvalue
    }
    
    var psfCardId: Int? {
        guard let transfer = parameterList.first as? TransferAnywayData,
              let bankData = transfer.payer.cardId else {
            return nil
        }
        
        return bankData
    }
    
}
