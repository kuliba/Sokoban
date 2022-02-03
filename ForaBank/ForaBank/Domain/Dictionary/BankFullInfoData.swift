//
//  BankFullInfoData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

struct BankFullInfoData: Codable, Equatable {
    
    let accountList: [AccountData]
    let address: String
    let bankServiceType: String
    let bankServiceTypeCode: String
    let bankType: String
    let bankTypeCode: String
    let bic: String
    let engName: String
    let fiasId: String?
    let fullName: String
    let inn: String?
    let kpp: String?
    let latitude: Int?
    let longitude: Int?
    let md5hash: String
    let memberId: String?
    let name: String?
    let receiverList: [String]
    let registrationDate: String
    let registrationNumber: String?
    let rusName: String?
    let senderList: [String]
    let svgImage: SVGImageData
    let swiftList: [SwiftList]
}

extension BankFullInfoData {
    
    struct SwiftList: Codable, Equatable {
        let `default`: Bool?
        let swift: String
    }
    
    struct AccountData: Codable, Equatable {
        
        let cbrbic: String
        let account: String
        let ck: String
        let dateIn: String
        let dateOut: String?
        let regulationAccountType: String
        let status: String
        
        enum CodingKeys : String, CodingKey, Decodable {
            case account, ck, dateIn, dateOut, regulationAccountType, status
            case cbrbic = "CBRBIC"
        }
    }
}
