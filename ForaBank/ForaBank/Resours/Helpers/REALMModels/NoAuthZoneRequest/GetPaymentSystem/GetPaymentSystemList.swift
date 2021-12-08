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

//MARK: - convenience inits

extension GetPaymentSystemList {
    
    convenience init(with data: GetPaymentSystemListDataClass) {
        
        self.init()
        
        serial = data.serial
        
        if let dataPaymentSystemList = data.paymentSystemList {
            
            paymentSystemList.append(objectsIn: dataPaymentSystemList.map{ GetPaymentList(with: $0) } )
        }
    }
}

extension GetPaymentList {
    
    convenience init(with data: PaymentSystemList) {
        
        self.init()
        code = data.code
        name = data.name
        md5Hash = data.md5Hash
        svgImage = data.svgImage
        
        if let dataPureList = data.purefList {
            
            var pureListObjects = [TempGetPayment_1]()
            
            for item in dataPureList {
                
                item.forEach { key, value in
                    
                    pureListObjects.append(TempGetPayment_1(with: key, listData: value))
                }
            }
            
            self.purefList.append(objectsIn: pureListObjects)
        }
    }
}

extension TempGetPayment_1 {
    
    convenience init(with key: String?, listData: [PurefList]) {
        self.init()
        self.key = key
        self.purefList.append(objectsIn: listData.map{ GetPayment(with: $0)} )
    }
}

extension GetPayment {
    
    convenience init(with data: PurefList) {
        
        self.init()
        puref = data.puref
        type = data.type
    }
}

