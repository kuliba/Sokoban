//
//  GetPaymentSystemList.swift
//  ForaBank
//
//  Created by Константин Савялов on 05.09.2021.
//

import Foundation
import RealmSwift

// MARK: - GetPaymentSystemList
class GetPaymentSystemList: Object {
    
    @objc dynamic var serial: String?
    
    var paymentSystemList = List<GetPaymentList>()

}

//// MARK: - GetPaymentList
class GetPaymentList: Object {
    
    @objc dynamic var code: String?
    @objc dynamic var name: String?
    @objc dynamic var md5Hash: String?
    @objc dynamic var svgImage: String?
    var purefList = List<TempGetPayment_1>()
    
}

//// MARK: - TempGetPayment_1
class TempGetPayment_1: Object {

    @objc dynamic var key: String?
    var purefList = List<GetPayment>()
    
}

//// MARK: - GetPayment
class GetPayment: Object {

    @objc dynamic var puref: String?
    @objc dynamic var type: String?
    
}


