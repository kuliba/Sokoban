//
//  PaymentsModel.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import Foundation

struct PaymentsModel: Hashable {
    
    var id = UUID()
    var name: String
    var iconName: String?
    var avatarImageName: String?
    var controllerName: String
    var description: String? = ""
    var type: String? = ""
    var lastCountryPayment: GetAllLatestPaymentsDatum? = nil
    var lastPhonePayment: GetAllLatestPaymentsDatum? = nil
    var productList: GetProductListDatum? = nil
    var lastMobilePayment: GetAllLatestPaymentsDatum? = nil
    var lastGKHPayment: GetAllLatestPaymentsDatum? = nil
    var lastInternetPayment: GetAllLatestPaymentsDatum? = nil
    var productListFromRealm: UserAllCardsModel? = nil

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PaymentsModel, rhs: PaymentsModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(name: String, iconName: String, controllerName: String, description: String? = "", type: String? = nil) {
        
        self.name = name
        self.iconName = iconName
        self.controllerName = controllerName
        self.description = description
        self.type = type
    }
    
    init(lastCountryPayment: GetAllLatestPaymentsDatum) {
        self.lastCountryPayment = lastCountryPayment
        self.type = lastCountryPayment.type
        if lastCountryPayment.phoneNumber != nil {
            let mask = StringMask(mask: "+000-0000-00-00")
            let maskPhone = mask.mask(string: lastCountryPayment.phoneNumber)
            self.name = maskPhone ?? ""
        } else {
            self.name = "\(lastCountryPayment.firstName ?? "")\n\(lastCountryPayment.surName ?? "")"
        }
        self.controllerName = "ChooseCountryTableViewController"
        self.iconName = "smartphonegray"
    }
    
    init(lastPhonePayment: GetAllLatestPaymentsDatum) {
        self.lastPhonePayment = lastPhonePayment
        self.type = lastPhonePayment.type
        self.name = lastPhonePayment.phoneNumber?.numberFormatter() ?? ""
        self.controllerName = "PaymentByPhoneViewController"
        self.iconName = "smartphonegray"
    }
    
    init(productList: GetProductListDatum) {
        self.productList = productList
        self.name = productList.name ?? ""
        self.controllerName = "PaymentByPhoneViewController"
        self.iconName = "smartphonegray"
    }
    
    init(lastMobilePayment: GetAllLatestPaymentsDatum) {
        self.lastMobilePayment = lastMobilePayment
        self.type = lastMobilePayment.type
        let mask = StringMask(mask: "+7 (000) 000-00-00")
        self.name = "\(mask.mask(string: lastMobilePayment.additionalList?[0].fieldValue) ?? "")"
        self.controllerName = "MobilePayViewController"
        self.iconName = "smartphonegray"
    }
    
    init(lastGKHPayment: GetAllLatestPaymentsDatum) {
        self.lastGKHPayment = lastGKHPayment
        self.type = lastGKHPayment.type
        self.name = "\(lastGKHPayment.amount ?? Amount.string(""))"
        self.controllerName = "GKHInputViewController"
        self.iconName = "GKH"
    }
    
    init(lastInternetPayment: GetAllLatestPaymentsDatum) {
        self.lastInternetPayment = lastInternetPayment
        self.type = lastInternetPayment.type
        self.name = "\(lastInternetPayment.amount ?? Amount.string(""))"
        self.controllerName = "InternetTVDetailsFormController"
        self.iconName = "GKH"
    }

    init(productListFromRealm: UserAllCardsModel) {
        self.productListFromRealm = productListFromRealm
        self.name = productListFromRealm.name ?? "1234"
        self.controllerName = "PaymentByPhoneViewController"
        self.iconName = "smartphonegray"
    }
    
}
