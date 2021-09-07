//
//  GetPaymentSystemSaved.swift
//  ForaBank
//
//  Created by Константин Савялов on 05.09.2021.
//

import Foundation
import RealmSwift

struct GetPaymentSystemSaved {
    
    static func add(_ param: [String : String], _ body: [String: AnyObject]) {
        
        NetworkManager<GetPaymentSystemListDecodableModel>.addRequest(.getPaymentSystemList, param, body) { model, error in
            
            if error != nil {
                print("DEBUG: error", error!)
            } else {
                guard let model = model else { return }
                guard let paymentSystem = model.data else { return }
                
                let getPaymentSystemList = GetPaymentSystemList()
                getPaymentSystemList.serial = paymentSystem.serial
                
                paymentSystem.paymentSystemList?.forEach { paymentSystemList in
                    let getPaymentList = GetPaymentList()
                    getPaymentList.code = paymentSystemList.code
                    getPaymentList.name = paymentSystemList.name
                    getPaymentList.md5Hash = paymentSystemList.md5Hash
                    getPaymentList.svgImage = paymentSystemList.svgImage
                    
                    var tempGetPayment_1Array = TempGetPayment_1()
                    paymentSystemList.purefList?.forEach { purefList in
                        
                        purefList.forEach { key, value in
                            let tempGetPayment_1 = TempGetPayment_1()
                            tempGetPayment_1.key = key
                            
                            var getPaymentArray = [GetPayment]()
                            value.forEach { pList in
                                let getPayment = GetPayment()
                                getPayment.puref = pList.puref
                                getPayment.type = pList.type
                                getPaymentArray.append(getPayment)
                            }
                            getPaymentArray.forEach { v in
                                tempGetPayment_1.purefList.append(v)
                            }
                            tempGetPayment_1Array = tempGetPayment_1
                        }
                    }
                    
                    getPaymentList.purefList.append(tempGetPayment_1Array)
                    
                    getPaymentSystemList.paymentSystemList.append(getPaymentList)
                    
                    /// Сохраняем в REALM
                    let realm = try? Realm()
                    do {
                        let operators = realm?.objects(GetPaymentSystemList.self)
                        realm?.beginWrite()
                        realm?.delete(operators!)
                        realm?.add(getPaymentSystemList)
                        try realm?.commitWrite()
                        print("REALM",realm?.configuration.fileURL?.absoluteString ?? "")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}
