//
//  GetPaymentSystemSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 05.09.2021.
//

import Foundation
import RealmSwift

struct GetPaymentSystemSaved {
    
//    static func add(_ param: [String : String], _ body: [String: AnyObject]) {
//
//        var getPaymentSystemList: GetPaymentSystemList?
//        var getPaymentList: GetPaymentList?
//        var tempGetPaymentList: TempGetPaymentList?
//        var getPayment: GetPayment?
//        var tempGetPayment_1: TempGetPayment_1?
//        var tempGetPayment_2: TempGetPayment_2?
//        var tempGetPayment_3: TempGetPayment_3?
//        var getPaymentPuref: GetPaymentPuref?
//        var getPaymentPurefType: GetPaymentPurefType?
//
//        NetworkManager<GetPaymentSystemListDecodableModel>.addRequest(.getPaymentSystemList, param, body) { model, error in
//
//            var realm = try? Realm()
//            if error != nil {
//                print("DEBUG: error", error!)
//            } else {
//                guard let model = model else { return }
//                guard let paymentSystem = model.data else { return }
//
//                paymentSystem.paymentSystemList?.forEach{ paymentSystemList in
//                    paymentSystemList.purefList?.forEach({ purefList in
//                        purefList.forEach { key, value in
//                            value.forEach { pList in
//                                pList.type
//                            }
//                        }
//                    })
//                }
//
//
//
//
//            }
//
//
//        }
//
//
//
//    }
}
