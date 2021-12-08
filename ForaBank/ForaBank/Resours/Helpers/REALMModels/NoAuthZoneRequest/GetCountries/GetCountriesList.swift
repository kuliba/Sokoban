//
//  GetCountriesList.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.09.2021.
//

import Foundation
import RealmSwift

// MARK: - GetBankList
class GetCountries: Object {
    
    @objc dynamic var serial: String?
    
    var countriesList = List<GetCountriesList>()
}

//// MARK: - BankList
class GetCountriesList: Object {
    
    @objc dynamic var code: String?
    @objc dynamic var contactCode: String?
    @objc dynamic var name: String?
    @objc dynamic var sendC: String?
    @objc dynamic var md5hash : String?
    @objc dynamic var svgImage : String?
    var paymentSystemIdList = List<String>()
}

//MARK: - convenience inits

extension GetCountries {
    
    convenience init(with data: GetCountriesDataClass) {
        
        self.init()
        
        serial = data.serial
        
        if let countriesListData = data.countriesList {
            
            countriesList.append(objectsIn: countriesListData.map{ GetCountriesList(with: $0)} )
        }
    }
}

extension GetCountriesList {
    
    convenience init(with data: CountriesList) {
        
        self.init()
        code = data.code
        contactCode = data.contactCode
        name = data.name
        md5hash = data.md5Hash
        svgImage = data.svgImage
        
        if let paymentSystemCodeListData = data.paymentSystemCodeList {
            
            paymentSystemIdList.append(objectsIn: paymentSystemCodeListData)
        }
    }
}


