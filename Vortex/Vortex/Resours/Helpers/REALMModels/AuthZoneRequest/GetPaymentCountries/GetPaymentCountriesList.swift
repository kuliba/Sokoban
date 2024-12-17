//
//  GetPaymentCountries.swift
//  ForaBank
//
//  Created by Константин Савялов on 13.09.2021.
//

import Foundation
import RealmSwift

//// MARK: - GetPaymentCountriesList
class GetPaymentCountriesList: Object {
    
    @objc dynamic var surName: String?
    @objc dynamic var firstName: String?
    @objc dynamic var middleName: String?
    @objc dynamic var shortName: String?
    @objc dynamic var countryName: String?
    @objc dynamic var countryCode: String?
    @objc dynamic var puref: String?
    @objc dynamic var phoneNumber: String?
}
