//
//  UserAllCardsModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 25.08.2021.
//

import Foundation
import RealmSwift

// MARK: - UserAllCardsModel
class UserAllCardsModel: Object {
    
    @objc dynamic var number: String?
    @objc dynamic var numberMasked: String?
    @objc dynamic var balance = 0.0
    @objc dynamic var currency: String?
    @objc dynamic var productType: String?
    @objc dynamic var productName: String?
    @objc dynamic var ownerID = 0
    @objc dynamic var accountNumber: String?
    @objc dynamic var allowDebit = false
    @objc dynamic var allowCredit = false
    @objc dynamic var customName: String?
    @objc dynamic var cardID = 0
    @objc dynamic var name: String?
    @objc dynamic var validThru = 0
    @objc dynamic var status: String?
    @objc dynamic var holderName: String?
    @objc dynamic var product: String?
    @objc dynamic var branch: String?
    @objc dynamic var miniStatement: String?
    @objc dynamic var mainField: String?
    @objc dynamic var additionalField: String?
    @objc dynamic var smallDesign: String?
    @objc dynamic var mediumDesign: String?
    @objc dynamic var largeDesign: String?
    @objc dynamic var paymentSystemName: String?
    @objc dynamic var paymentSystemImage: String?
    @objc dynamic var fontDesignColor: String?
    @objc dynamic var id: Int = 0
    @objc dynamic var endDate: Int = 0
    @objc dynamic var endDate_nf: Bool = false
    
    @objc dynamic var smallDesignMd5Hash: String?
    @objc dynamic var mediumDesignMd5Hash: String?
    @objc dynamic var largeDesignMd5Hash: String?
    @objc dynamic var paymentSystemImageMd5Hash: String?

    var background = List<UserAllCardsbackgroundModel>()
    @objc dynamic var openDate = 0
    @objc dynamic var branchId = 0
    @objc dynamic var accountID = 0
    @objc dynamic var expireDate: String?
    @objc dynamic var XLDesign: String?
    @objc dynamic var statusPC: String?
    @objc dynamic var interestRate: String?
    @objc dynamic var depositProductID: Int = 0
    @objc dynamic var depositID: Int = 0
    @objc dynamic var creditMinimumAmount: Double = 0.0
    @objc dynamic var minimumBalance: Double = 0.0
    @objc dynamic var balanceRUB: Double = 0.0
    @objc dynamic var amount = 0.0
    @objc dynamic var clientID = 0
    @objc dynamic var currencyCode: String?
    @objc dynamic var currencyNumber = 0
    @objc dynamic var bankProductID = 0
    @objc dynamic var finOperBrief: String?
    @objc dynamic var currentInterestRate = 0.0
    @objc dynamic var principalDebt = 0.0
    @objc dynamic var defaultPrincipalDebt = 0.0
    @objc dynamic var totalAmountDebt = 0.0
    @objc dynamic var principalDebtAccount: String?
    @objc dynamic var settlementAccount: String?
    @objc dynamic var settlementAccountId = 0
    @objc dynamic var dateLong = 0
    @objc dynamic var isMain: Bool = true
    
    @objc dynamic var loanBaseParam: LoanBaseParamModel? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
}    

class UserAllCardsbackgroundModel: Object {
    @objc dynamic var color: String?
}

class LoanBaseParamModel: Object {
    
    @objc dynamic var loanID: Int = 0
    @objc dynamic var clientID: Int = 0
    @objc dynamic var number: String = ""
    @objc dynamic var currencyID: Int = 0
    @objc dynamic var currencyNumber: Int = 0
    @objc dynamic var currencyCode: String = ""
    @objc dynamic var minimumPayment: Double = 0.0
    @objc dynamic var gracePeriodPayment: Double = 0.0
    @objc dynamic var overduePayment: Double = 0.0
    @objc dynamic var availableExceedLimit: Double = 0.0
    @objc dynamic var ownFunds: Double = 0.0
    @objc dynamic var debtAmount: Double = 0.0
    @objc dynamic var totalAvailableAmount: Double = 0.0
    @objc dynamic  var totalDebtAmount: Double = 0.0
}

extension UserAllCardsModel: Identifiable {
    
    convenience init(with data: GetProductListDatum) {
        
        self.init()
        number             = data.number
        numberMasked       = data.numberMasked
        balance            = data.balance ?? 0.0
        currency           = data.currency
        productType        = data.productType
        productName        = data.productName
        ownerID            = data.ownerID ?? 0
        accountNumber      = data.accountNumber
        allowDebit         = data.allowDebit ?? false
        allowCredit        = data.allowCredit ?? false
        customName         = data.customName
        cardID             = data.cardID ?? 0
        name               = data.name
        validThru          = data.validThru ?? 0
        status             = data.status
        holderName         = data.holderName
        product            = data.product
        branch             = data.branch
        mainField          = data.mainField
        additionalField    = data.additionalField
        smallDesign        = data.smallDesign
        mediumDesign       = data.mediumDesign
        largeDesign        = data.largeDesign
        paymentSystemName  = data.paymentSystemName
        paymentSystemImage = data.paymentSystemImage
        fontDesignColor    = data.fontDesignColor
        id                 = data.id ?? 0
        openDate           = data.openDate ?? 0
        branchId           = data.branchId ?? 0
        accountID          = data.accountID ?? 0
        expireDate         = data.expireDate
        XLDesign           = data.XLDesign
        statusPC           = data.statusPC
        interestRate       = "\(data.interestRate ?? 0.0)"
        depositProductID   = data.depositProductID ?? 0
        depositID          = data.depositID ?? 0
        creditMinimumAmount = data.creditMinimumAmount ?? 0.0
        minimumBalance     = data.minimumBalance ?? 0.0
        balanceRUB         = data.balanceRUB ?? 0.0
        amount             = data.amount ?? 0.0
        clientID           = data.clientID ?? 0
        currencyCode       = data.currencyCode
        currencyNumber     = data.currencyNumber ?? 0
        bankProductID      = data.bankProductID ?? 0
        finOperBrief       = data.finOperBrief
        currentInterestRate = data.currentInterestRate ?? 0.0
        principalDebt      = data.principalDebt ?? 0.0
        defaultPrincipalDebt = data.defaultPrincipalDebt ?? 0.0
        totalAmountDebt    = data.totalAmountDebt ?? 0.0
        principalDebtAccount = data.principalDebtAccount
        settlementAccount  = data.settlementAccount
        settlementAccountId = data.settlementAccountId ?? 0
        dateLong           = data.dateLong ?? 0
        isMain             = data.isMain ?? true
        endDate            = data.endDate ?? 0
        endDate_nf            = data.endDate_nf ?? false
        smallDesignMd5Hash = data.smallDesignMd5Hash
        mediumDesignMd5Hash = data.mediumDesignMd5Hash
        largeDesignMd5Hash = data.largeDesignMd5Hash
        paymentSystemImageMd5Hash = data.paymentSystemImageMd5Hash

        data.background.forEach { color in
            
            background.append(UserAllCardsbackgroundModel(with: color))
        }
        
        loanBaseParam = LoanBaseParamModel(with: data.loanBaseParam)
    }
}

extension UserAllCardsbackgroundModel {
    
    convenience init(with color: String?) {
        
        self.init()
        self.color = color
    }
}

extension LoanBaseParamModel {
    
    convenience init(with loanBaseParam: GetProductListDatum.LoanBaseParam?) {
        
        self.init()
        
        if let clientID = loanBaseParam?.clientID {
            
            self.clientID = clientID
        }
        
        if let number = loanBaseParam?.number {
            
            self.number = number
        }
        
        if let currencyID = loanBaseParam?.currencyID {
            
            self.currencyID = currencyID
        }
        
        if let currencyNumber = loanBaseParam?.currencyNumber {
            
            self.currencyNumber = currencyNumber
        }
        
        if let currencyCode = loanBaseParam?.currencyCode {
            
            self.currencyCode = currencyCode
        }
        
        if let minimumPayment = loanBaseParam?.minimumPayment {
            
            self.minimumPayment = minimumPayment
        }
        
        if let gracePeriodPayment = loanBaseParam?.gracePeriodPayment {
            
            self.gracePeriodPayment = gracePeriodPayment
        }
        
        if let overduePayment = loanBaseParam?.overduePayment {
            
            self.overduePayment = overduePayment
        }
        
        if let availableExceedLimit = loanBaseParam?.availableExceedLimit {
            
            self.availableExceedLimit = availableExceedLimit
        }
        
        if let ownFunds = loanBaseParam?.ownFunds {
            
            self.ownFunds = ownFunds
        }
        
        if let debtAmount = loanBaseParam?.debtAmount {
            
            self.debtAmount = debtAmount
        }
        
        if let totalAvailableAmount = loanBaseParam?.totalAvailableAmount {
            
            self.totalAvailableAmount = totalAvailableAmount
        }
        
        if let totalDebtAmount = loanBaseParam?.totalDebtAmount {
            
            self.totalDebtAmount = totalDebtAmount
        }
    }
}

extension UserAllCardsModel {
    
    var productTypeEnum: ProductType {
        
        guard let productType = productType, let productTypeEnum = ProductType(rawValue: productType) else {
            
            //FIXME: dirty hack for refactoring period!!!
            return .account
        }
        
        return productTypeEnum
    }
}
