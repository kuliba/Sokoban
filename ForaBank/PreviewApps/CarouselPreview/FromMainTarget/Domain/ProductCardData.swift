//
//  ProductCardData.swift
//  ForaBank
//
//  Created by Дмитрий on 05.04.2022.
//

import Foundation

class ProductCardData: ProductData {

    let accountId: Int?
    let cardId: Int
    let name: String
    let validThru: Date
    private(set) var status: Status
    let expireDate: String?
    let holderName: String?
    let product: String?
    let branch: String
    let miniStatement: [PaymentDataItem]?
    let paymentSystemName: String?
    let paymentSystemImage: String?
    private(set) var statusPc: StatusPC?
    #warning("NOT OPTIONAL!")
    let isMain: Bool?
    let externalId: Int?
    
    init(id: Int, productType: ProductType, number: String?, numberMasked: String?, accountNumber: String?, balance: Double?, balanceRub: Double?, currency: String, mainField: String, additionalField: String?, customName: String?, productName: String, openDate: Date?, ownerId: Int, branchId: Int?, allowCredit: Bool, allowDebit: Bool, extraLargeDesign: String, largeDesign: String, mediumDesign: String, smallDesign: String, fontDesignColor: ColorData, background: [ColorData], accountId: Int?, cardId: Int, name: String, validThru: Date, status: Status, expireDate: String?, holderName: String?, product: String?, branch: String, miniStatement: [PaymentDataItem]?, paymentSystemName: String?, paymentSystemImage: String?, statusPc: ProductData.StatusPC?, isMain: Bool?, externalId: Int?, order: Int, visibility: Bool, smallDesignMd5hash: String, smallBackgroundDesignHash: String) {

        self.accountId = accountId
        self.cardId = cardId
        self.name = name
        self.validThru = validThru
        self.status = status
        self.expireDate = expireDate
        self.holderName = holderName
        self.product = product
        self.branch = branch
        self.miniStatement = miniStatement
        self.paymentSystemName = paymentSystemName
        self.paymentSystemImage = paymentSystemImage
        self.statusPc = statusPc
        self.isMain = isMain
        self.externalId = externalId
        
        super.init(id: id, productType: productType, number: number, numberMasked: numberMasked, accountNumber: accountNumber, balance: balance, balanceRub: balanceRub, currency: currency, mainField: mainField, additionalField: additionalField, customName: customName, productName: productName, openDate: openDate, ownerId: ownerId, branchId: branchId, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: extraLargeDesign, largeDesign: largeDesign, mediumDesign: mediumDesign, smallDesign: smallDesign, background: background, order: order, isVisible: visibility, smallDesignMd5hash: smallDesignMd5hash, smallBackgroundDesignHash: smallBackgroundDesignHash)
    }
    
    //MARK: Equitable
    
    static func == (lhs: ProductCardData, rhs: ProductCardData) -> Bool {
        
        return  lhs.product == rhs.product &&
        lhs.accountId == rhs.accountId &&
        lhs.cardId == rhs.cardId &&
        lhs.name == rhs.name &&
        lhs.validThru == rhs.validThru &&
        lhs.status == rhs.status &&
        lhs.expireDate == rhs.expireDate &&
        lhs.holderName == rhs.holderName &&
        lhs.product == rhs.product &&
        lhs.branch == rhs.branch &&
        lhs.miniStatement == rhs.miniStatement &&
        lhs.paymentSystemName == rhs.paymentSystemName &&
        lhs.paymentSystemImage == rhs.paymentSystemImage &&
        lhs.statusPc == rhs.statusPc &&
        lhs.isMain == rhs.isMain &&
        lhs.externalId == rhs.externalId
    }
}

//MARK: - PaymentDataItem

extension ProductCardData {
    
    struct PaymentDataItem: Codable, Equatable {
        
        let account: String?
        let date: Date?
        let amount: Double?
        let currency: String?
        let purpose: String?
        
        init(account: String?, date: Date?, amount: Double?, currency: String?, purpose: String?) {
            
            self.account = account
            self.amount = amount
            self.date = date
            self.currency = currency
            self.purpose = purpose
        }
    }
}

//MARK: - Helpers

extension ProductCardData {

    var isNotActivated: Bool {

        guard status == .active || status == .issuedToClient,
              statusPc == .notActivated else {
                  return false
              }

        return true
    }
    
    var isActivated: Bool {
        isNotActivated == false
    }
    
    func activate() {
        
        status = .active
        statusPc = .active
    }

    var isBlocked: Bool {

        guard status == .blockedByBank || status == .blockedByClient, statusPc == .operationsBlocked || statusPc == .blockedByBank || statusPc == .lost || statusPc == .stolen || statusPc == .temporarilyBlocked || statusPc == .blockedByClient || status == .blockedByClient else {
            return false
        }

        return true
    }
  
    
    var canBeUnblocked: Bool {

        return statusPc == .temporarilyBlocked || statusPc == .blockedByClient
    }
}
