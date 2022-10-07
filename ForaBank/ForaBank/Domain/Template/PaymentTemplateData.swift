//
//  PaymentTemplateData.swift
//  ForaBank
//
//  Created by Max Gribov on 20.12.2021.
//

import Foundation
import CoreText

struct PaymentTemplateData: Identifiable, Equatable {
    
    var id: Int { paymentTemplateId }
    let groupName: String
    let name: String
    let parameterList: [TransferData]
    let paymentTemplateId: Int
    let productTemplate: ProductTemplateData?
    let sort: Int
    let svgImage: SVGImageData
    let type: Kind
}

//MARK: - Types

extension PaymentTemplateData {
    
    enum Kind: String, Codable, Equatable, Unknownable {
        
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
        case taxAndStateService = "TAX_AND_STATE_SERVICE"
        case interestDeposit = "INTEREST_DEPOSIT"
        case unknown
        
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
            case .taxAndStateService: return "Налоги и госуслуги"
            case.interestDeposit: return "Проценты по депозитам"
            case .unknown: return "Неизвестно"
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
        var parameterListDecoded = [TransferData]()
        
        while parameterListContainer.isAtEnd == false {
            
            if let transferAnyway = try? parameterListContainer.decode(TransferAnywayData.self) {
                
                parameterListDecoded.append(transferAnyway)
                
            } else if let transferMe2Me = try? parameterListContainer.decode(TransferMe2MeData.self) {
                
                parameterListDecoded.append(transferMe2Me)
                
            } else {
                
                let transfer = try parameterListContainer.decode(TransferGeneralData.self)
                parameterListDecoded.append(transfer)
            }
        }
        
        parameterList = parameterListDecoded
        paymentTemplateId = try container.decode(Int.self, forKey: .paymentTemplateId)
        productTemplate = try container.decodeIfPresent(ProductTemplateData.self, forKey: .productTemplate)
        sort = try container.decode(Int.self, forKey: .sort)
        svgImage = try container.decode(SVGImageData.self, forKey: .svgImage)
        let typeString = try container.decode(String.self, forKey: .type)
        type = Kind(rawValue: typeString) ?? .unknown
    }
}

extension PaymentTemplateData {
    
    var amount: Double? {
        guard let transfer = parameterList.first else {
            return nil
        }
        
        return transfer.amount
    }
    
}

//MARK: - Convenience SPF Properties

//TODO: tests
extension PaymentTemplateData {
    
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

//MARK: - Convenience Inside Bank by Phone Properties

//TODO: tests
extension PaymentTemplateData {
    
    var insideByPhonePhoneNumber: String? {
        
        guard let transfer = parameterList.first as? TransferGeneralData,
              let phoneData = transfer.payeeInternal?.phoneNumber  else {
            return nil
        }
        
        return phoneData
    }
    
    var insideByPhoneBankId: String? {
        guard let transfer = parameterList.first as? TransferGeneralData,
              transfer.payeeInternal?.phoneNumber != nil  else {
            return nil
        }
        
        return "100000000217"
    }
    
    var insideByPhoneCardId: Int? {
        guard let transfer = parameterList.first as? TransferGeneralData,
              let bankData = transfer.payer.cardId else {
            return nil
        }
        
        return bankData
    }
    
    var insideByPhoneAccountId: Int? {
        guard let transfer = parameterList.first as? TransferGeneralData,
              let bankData = transfer.payer.accountId else {
            return nil
        }
        
        return bankData
    }
}

//MARK: - Convenience Inside Bank by Card Properties

//TODO: tests
extension PaymentTemplateData {
    
    var insideByCardPhoneNumber: String? {
        
        guard let transfer = parameterList.first as? TransferAnywayData,
              let phoneData = transfer.additional.first(where: { $0.fieldname == "RecipientID" })  else {
            return nil
        }
        
        return phoneData.fieldvalue
    }
    
    var insideByCardBankId: String? {
        
        guard let transfer = parameterList.first as? TransferAnywayData,
              let bankData = transfer.additional.first(where: { $0.fieldname == "BankRecipientID" })  else {
            return nil
        }
        
        return bankData.fieldvalue
    }
    
    var insideByCardCardId: Int? {
        guard let transfer = parameterList.first as? TransferAnywayData,
              let bankData = transfer.payer.cardId else {
            return nil
        }
        
        return bankData
    }
}
