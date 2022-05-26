//
//  ClientInfoResponseData.swift
//  ForaBank
//
//  Created by Дмитрий on 02.02.2022.
//

import Foundation

typealias ClientPhotoData = ImageData
typealias ClientNameData = String

struct ClientInfoData: Codable, Equatable, Identifiable {
    
    let id: Int
    let lastName: String
    let firstName: String
    let patronymic: String?
    let birthDay: String?
    let regSeries: String?
    let regNumber: String
    let birthPlace: String?
    let dateOfIssue: String?
    let codeDepartment: String?
    let regDepartment: String?
    let address: String
    let addressInfo: AddressInfo?
    let addressResidential: String?
    let addressResidentialInfo: AddressInfo?
    let phone: String
    let phoneSMS: String?
    let email: String?
    let INN: String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "clientId"
        case lastName, firstName, patronymic, birthDay,regSeries, regNumber, birthPlace, dateOfIssue, codeDepartment, regDepartment, address, addressInfo, addressResidential, addressResidentialInfo, phone, phoneSMS, email, INN
    }
    
    struct AddressInfo: Codable {
        
        let postIndex: String?
        let country: String?
        let area: String?
        let region: String?
        let street: String?
        let house: String?
        let frame: String?
        let flat: String?
    }
    
    static func == (lhs: ClientInfoData, rhs: ClientInfoData) -> Bool {
        return  lhs.id == rhs.id &&
        lhs.lastName == rhs.lastName &&
        lhs.firstName == rhs.firstName &&
        lhs.patronymic == rhs.patronymic &&
        lhs.birthDay == rhs.birthDay &&
        lhs.regSeries == rhs.regSeries &&
        lhs.regNumber == rhs.regNumber &&
        lhs.birthPlace == rhs.birthPlace &&
        lhs.dateOfIssue == rhs.dateOfIssue &&
        lhs.codeDepartment == rhs.codeDepartment &&
        lhs.address == rhs.address &&
        lhs.phone == rhs.phone &&
        lhs.phoneSMS == rhs.phoneSMS &&
        lhs.email == rhs.email &&
        lhs.INN == rhs.INN
    }
}

extension ClientInfoData {
    
    var pasportNumber: String { (regSeries ?? "") + regNumber }
}
