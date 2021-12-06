//
//  GKHHistoryModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.08.2021.
//

import Foundation
import RealmSwift

class GKHHistoryModel: Object {
    
    @objc dynamic var paymentDate: String?
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var puref: String?
    
    var additionalList  = List<AdditionalListModel>()
}

extension GKHHistoryModel {
    
    convenience init(with data: GetLatestServicePaymentsDatum) {
        
        self.init()
        amount = data.amount ?? 0
        paymentDate = data.paymentDate
        puref = data.puref
        
        if let dataList = data.additionalList {
            
            dataList.forEach { parameters in
                
                let listItem = AdditionalListModel()
                listItem.fieldName = parameters.fieldName
                listItem.fieldValue = parameters.fieldValue
                
                additionalList.append(listItem)
            }
        }
    }
}

extension GKHHistoryModel {
    
    func isDataEqual(to object: GKHHistoryModel) -> Bool {
        
        guard self.paymentDate == object.paymentDate &&
                self.amount == object.amount &&
                self.puref == object.puref else {
            
                    return false
        }
        
        guard self.additionalList.count == object.additionalList.count else {
            return false
        }
        
        for (index, item) in self.additionalList.enumerated() {
            
            let otherItem = object.additionalList[index]
            
            guard item.fieldName == otherItem.fieldName && item.fieldValue == otherItem.fieldValue else {
                return false
            }
        }
        
        return true
    }
}
