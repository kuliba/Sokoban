//
//  GetLatestPhonePayments.swift
//  ForaBank
//
//  Created by Константин Савялов on 08.09.2021.
//

import Foundation
import RealmSwift

//// MARK: - GetLatestPhonePayments
class GetLatestPhonePayments: Object {
    
    @objc dynamic var bankName: String?
    @objc dynamic var bankId: String?
    @objc dynamic var payment: String?
    
}

