//
//  GetPaymentSystemList.swift
//  ForaBank
//
//  Created by Константин Савялов on 05.09.2021.
//

import Foundation
import RealmSwift

// MARK: - GetPaymentSystemList
//class GetPaymentSystemList: Object {
//    
//    @objc dynamic var statusCode: Int = 0
//    @objc dynamic var errorMessage: String?
//    
//    var data = List<GetPaymentList>()
//    
//    func set(_ typePayment: [GetPaymentList]) {
//        typePayment.forEach { t in
//            data.append(t)
//        }
//    }
//
//    init(statusCode: Int,
//         errorMessage: String,
//         purefList: [GetPaymentList]) {
//        
//        super.init()
//        self.statusCode = statusCode
//        self.errorMessage = errorMessage
//        
//        set(purefList)
//    }
//
//}
//
//// MARK: - GetPaymentList
//class GetPaymentList: Object {
//    
//    @objc dynamic var serial: String?
//    let paymentSystemList = List<TempGetPaymentList>()
//    
//    func set(_ typePayment: [TempGetPaymentList]) {
//        typePayment.forEach { t in
//            paymentSystemList.append(t)
//        }
//    }
//    
//    init(_ serial: String, _ typePayment: [TempGetPaymentList]) {
//        super.init()
//        self.serial = serial
//        set(typePayment)
//    }
//    
//}
//
//
//// MARK: - TempGetPaymentList
//class TempGetPaymentList: Object {
//    
//    var list = List<GetPayment>()
//    
//    func set(_ listA: [GetPayment]) {
//        listA.forEach { t in
//            list.append(t)
//        }
//    }
//    
//    init( _ list: [GetPayment]) {
//        super.init()
//        set(list)
//    }
//}
//
//// MARK: - GetPayment
//class GetPayment: Object {
//    
//    @objc dynamic var code: String?
//    @objc dynamic var name: String?
//    @objc dynamic var md5Hash: String?
//    @objc dynamic var svgImage: String?
//    let purefList = List<TempGetPayment_1>()
//    
//    func set(_ typePayment: [TempGetPayment_1]) {
//        typePayment.forEach { t in
//            purefList.append(t)
//        }
//    }
//    
//    init(code: String,
//         name: String,
//         md5Hash: String,
//         svgImage: String,
//         purefList: [TempGetPayment_1]) {
//        
//        super.init()
//        self.code = code
//        self.name = name
//        self.md5Hash = md5Hash
//        self.svgImage = svgImage
//        
//        set(purefList)
//    }
//    
//}
//
//class TempGetPayment_1: Object {
//    
//    var purefList = List<TempGetPayment_2>()
//    
//    func set(_ typePayment: [TempGetPayment_2]) {
//        typePayment.forEach { t in
//            purefList.append(t)
//        }
//    }
//    
//    init( _ typePayment: [TempGetPayment_2]) {
//        super.init()
//        set(typePayment)
//    }
//}
//
//class TempGetPayment_2: Object {
//    
//    @objc dynamic var key: String?
//    var purefList = List<TempGetPayment_3>()
//    
//    func set(_ typePayment: [TempGetPayment_3]) {
//        typePayment.forEach { t in
//            purefList.append(t)
//        }
//    }
//    
//    init(_ key: String, _ typePayment: [TempGetPayment_3]) {
//        super.init()
//        self.key = key
//        set(typePayment)
//    }
//}
//
//class TempGetPayment_3: Object {
//    
//    var purefList = List<GetPaymentPuref>()
//    
//    func set(_ typePayment: [GetPaymentPuref]) {
//        typePayment.forEach { t in
//            purefList.append(t)
//        }
//    }
//    
//    init( _ typePayment: [GetPaymentPuref]) {
//        super.init()
//        set(typePayment)
//    }
//    
//}
//
//
//// MARK: - GetPaymentPuref
//class GetPaymentPuref: Object {
//    
//    @objc dynamic var puref: String?
//    let type = List<GetPaymentPurefType>()
//    
//    func set(_ typePayment: [GetPaymentPurefType]) {
//        typePayment.forEach { t in
//            type.append(t)
//        }
//    }
//    
//    init(_ puref: String, _ typePayment: [GetPaymentPurefType]) {
//        super.init()
//        self.puref = puref
//        set(typePayment)
//    }
//}
//
//// GetPaymentPurefTypeEnum
//class GetPaymentPurefType: Object {
//    @objc dynamic var account: String?
//    @objc dynamic var addressing: String?
//    @objc dynamic var addressless: String?
//    @objc dynamic var card: String?
//    @objc dynamic var phone: String?
//    
//    init(account: String,
//         addressing: String,
//         addressless: String,
//         card: String,
//         phone: String) {
//        
//        self.account = account
//        self.addressing = addressing
//        self.addressless = addressless
//        self.card = card
//        self.phone = phone
//    }
//}
