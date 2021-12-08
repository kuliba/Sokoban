//
//  GetBankList.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.09.2021.
//

import Foundation
import RealmSwift

// MARK: - GetBankList
class GetBankList: Object {
    
    @objc dynamic var serial: String?
    
    var banksList = List<BankList>()
}

//// MARK: - BankList
class BankList: Object {
    
    @objc dynamic var memberId: String?
    @objc dynamic var name: String?
    @objc dynamic var fullName: String?
    @objc dynamic var engName : String?
    @objc dynamic var rusName : String?
    @objc dynamic var svgImage : String?
    @objc dynamic var bic: String?
    @objc dynamic var fiasId: String?
    @objc dynamic var address: String?
    @objc dynamic var latitude : String?
    @objc dynamic var longitude : String?
    @objc dynamic var inn : String?
    @objc dynamic var kpp: String?
    @objc dynamic var registrationNumber: String?
    @objc dynamic var registrationDate: String?
    @objc dynamic var bankType : String?
    @objc dynamic var bankTypeCode : String?
    @objc dynamic var bankServiceType : String?
    @objc dynamic var bankServiceTypeCode : String?
    
    var accountList = List<BankAccauntList>()
}

//// MARK: - BankAccauntList
class BankAccauntList: Object {
    
    @objc dynamic var account: String?
    @objc dynamic var regulationAccountType: String?
    @objc dynamic var ck: String?
    @objc dynamic var dateIn : String?
    @objc dynamic var dateOut : String?
    @objc dynamic var status : String?
    @objc dynamic var CBRBIC : String?
    
}

extension GetBankList {
    
    convenience init(with data: GetFullBankInfoListDecodableModelDataClass) {
        
        self.init()
        serial = data.serial
        
        if let bankFullInfoListData = data.bankFullInfoList {
            
            banksList.append(objectsIn: bankFullInfoListData.map{ BankList(with: $0) })
        }
    }
}

extension BankList {
    
    convenience init(with data: BankFullInfoList) {
        
        self.init()
        memberId = data.memberID
        name = data.name
        fullName = data.fullName
        engName = data.engName
        rusName = data.rusName
        svgImage = data.svgImage
        bic = data.bic
        fiasId = data.fiasID
        address = data.address
        latitude = data.latitude
        
        longitude = data.longitude
        inn = data.inn
        kpp = data.kpp
        registrationNumber = data.registrationNumber
        bankType = data.bankType
        bankTypeCode = data.bankTypeCode
        bankServiceType = data.bankServiceType
        bankServiceTypeCode = data.bankServiceTypeCode
        
    }
}

extension BankAccauntList {
    
    convenience init(with data: AccountList) {
        
        self.init()
        account = data.account
        regulationAccountType = data.regulationAccountType
        ck = data.ck
        dateIn = data.dateIn
        dateOut = data.dateOut
        status = data.status
        CBRBIC = data.cbrbic
    }
}
