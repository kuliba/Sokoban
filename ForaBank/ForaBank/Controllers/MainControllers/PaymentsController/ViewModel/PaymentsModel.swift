//
//  PaymentsModel.swift
//  ForaBank
//
//  Created by Mikhail on 04.06.2021.
//

import Foundation

struct PaymentsModel: Hashable {
    var id: Int
    var name: String
    var iconName: String?
    var avatarImageName: String?
    var controllerName: String
    var description: String? = ""
    var lastCountryPayment: ChooseCountryHeaderViewModel? = nil
    var lastPhonePayment: GetLatestPaymentsDatum? = nil
    var productList: GetProductListDatum? = nil
    var lastMobilePayment: GetLatestMobilePaymentsDatum? = nil
    var lastGKHPayment: GetAllLatestPaymentsDatum? = nil

    
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PaymentsModel, rhs: PaymentsModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    init() {
        self.id = Int.random(in: 100 ... 10000)
        self.name = ""
        self.controllerName = ""
    }
    
    init(id: Int, name: String, iconName: String, controllerName: String, description: String? = "") {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.controllerName = controllerName
        self.description = description
    }
    
    init(lastCountryPayment: ChooseCountryHeaderViewModel) {
        self.lastCountryPayment = lastCountryPayment
        self.id = Int.random(in: 100 ... 10000)
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
    
    init(lastPhonePayment: GetLatestPaymentsDatum) {
        self.lastPhonePayment = lastPhonePayment
        self.id = Int.random(in: 100 ... 10000)
        let mask = StringMask(mask: "+7 (000) 000-00-00")
        let maskPhone = mask.mask(string: lastPhonePayment.phoneNumber)
        self.name = maskPhone ?? ""
        self.controllerName = "PaymentByPhoneViewController"
        self.iconName = "smartphonegray"
    }
    init(productList: GetProductListDatum) {
        self.productList = productList
        self.id = Int.random(in: 100 ... 10000)
        self.name = productList.name ?? "1234"
        self.controllerName = "PaymentByPhoneViewController"
        self.iconName = "smartphonegray"
    }
    
    init(lastMobilePayment: GetLatestMobilePaymentsDatum) {
        self.lastMobilePayment = lastMobilePayment
        self.id = Int.random(in: 100 ... 10000)
        let mask = StringMask(mask: "+7 (000) 000-00-00")
        self.name = "\(mask.mask(string: lastMobilePayment.additionalList?[1].fieldValue) ?? "")"
        self.controllerName = "MobilePayViewController"
        self.iconName = "smartphonegray"
    }
    
    init(lastGKHPayment: GetAllLatestPaymentsDatum) {
        self.lastGKHPayment = lastGKHPayment
        self.id = Int.random(in: 100 ... 10000)
        self.name = "\(lastGKHPayment.amount ?? 0.0)"
        self.controllerName = "GKHInputViewController"
        self.iconName = "GKH"
    }

    
}
