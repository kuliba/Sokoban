//
//  ClearRealm.swift
//  ForaBank
//
//  Created by Константин Савялов on 06.12.2021.
//

import Foundation
import RealmSwift

struct ClearRealm {
    
    static func clear() {
        lazy var realm = try! Realm()
        try! realm.write {
//            realm.delete(realm.objects(GetNotificationsEntitytModel.self))
            realm.delete(realm.objects(GetNotificationsCellModel.self))
            realm.delete(realm.objects(UserAllCardsModel.self))
            realm.delete(realm.objects(UserAllCardsbackgroundModel.self))
            realm.delete(realm.objects(GetLatestPhonePayments.self))
            realm.delete(realm.objects(GetProductTemplateList.self))
            realm.delete(realm.objects(GetPaymentCountriesList.self))
            realm.delete(realm.objects(GKHHistoryModel.self))
            realm.delete(realm.objects(AdditionalListModel.self))
            realm.delete(realm.objects(GetProductListByFilter.self))
            realm.delete(realm.objects(GetProductListByFilterList.self))
            realm.delete(realm.objects(GetLatestPayments.self))
            
            let timeOut = realm.objects(GetSessionTimeout.self)
            timeOut.first?.mustCheckTimeOut = true
            realm.add(timeOut)
        }
//        AppDelegate.shared.isAuth = false
    }
}
