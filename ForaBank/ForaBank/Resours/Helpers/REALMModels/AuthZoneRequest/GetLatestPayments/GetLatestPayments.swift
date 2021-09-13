//
//  GetLatestPayments.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.09.2021.
//

import Foundation
import RealmSwift

//// MARK: - GetLatestPayments
class GetLatestPayments: Object {
    
    @objc dynamic var paymentDate: String?
    @objc dynamic var phoneNumber: String?
    @objc dynamic var bankName: String?
    @objc dynamic var bankId: String?
    @objc dynamic var amount: String?
    
}
