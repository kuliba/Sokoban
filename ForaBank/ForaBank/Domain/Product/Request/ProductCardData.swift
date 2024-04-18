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
    #warning("use paymentSystemImageMd5Hash")
    let paymentSystemImage: SVGImageData?
    let loanBaseParam: LoanBaseParamInfoData?
    private(set) var statusPc: StatusPC?
    #warning("NOT OPTIONAL!")
    let isMain: Bool?
    let externalId: Int?
    
    #warning("For compability with rest/v5/getProductListByType")
    let statusCard: StatusCard?
    let cardType: CardType?
    let idParent: Int?
    let paymentSystemImageMd5Hash: String
    
    init(id: Int, productType: ProductType, number: String?, numberMasked: String?, accountNumber: String?, balance: Double?, balanceRub: Double?, currency: String, mainField: String, additionalField: String?, customName: String?, productName: String, openDate: Date?, ownerId: Int, branchId: Int?, allowCredit: Bool, allowDebit: Bool, extraLargeDesign: SVGImageData, largeDesign: SVGImageData, mediumDesign: SVGImageData, smallDesign: SVGImageData, fontDesignColor: ColorData, background: [ColorData], accountId: Int?, cardId: Int, name: String, validThru: Date, status: Status, expireDate: String?, holderName: String?, product: String?, branch: String, miniStatement: [PaymentDataItem]?, paymentSystemName: String?, paymentSystemImage: SVGImageData?, loanBaseParam: LoanBaseParamInfoData?, statusPc: ProductData.StatusPC?, isMain: Bool?, externalId: Int?, order: Int, visibility: Bool, smallDesignMd5hash: String, smallBackgroundDesignHash: String,
        mediumDesignMd5Hash: String = "",
        largeDesignMd5Hash: String = "",
        xlDesignMd5Hash: String = "",
        statusCard: StatusCard? = nil,
        cardType: CardType? = nil,
        idParent: Int? = nil,
        paymentSystemImageMd5Hash: String = ""
    ) {

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
        self.loanBaseParam = loanBaseParam
        self.statusPc = statusPc
        self.isMain = isMain
        self.externalId = externalId
        self.statusCard = statusCard
        self.cardType = cardType
        self.idParent = idParent
        self.paymentSystemImageMd5Hash = paymentSystemImageMd5Hash
        
        super.init(id: id, productType: productType, number: number, numberMasked: numberMasked, accountNumber: accountNumber, balance: balance, balanceRub: balanceRub, currency: currency, mainField: mainField, additionalField: additionalField, customName: customName, productName: productName, openDate: openDate, ownerId: ownerId, branchId: branchId, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: extraLargeDesign, largeDesign: largeDesign, mediumDesign: mediumDesign, smallDesign: smallDesign, fontDesignColor: fontDesignColor, background: background, order: order, isVisible: visibility, smallDesignMd5hash: smallDesignMd5hash, smallBackgroundDesignHash: smallBackgroundDesignHash, mediumDesignMd5Hash: mediumDesignMd5Hash, largeDesignMd5Hash: largeDesignMd5Hash, xlDesignMd5Hash: xlDesignMd5Hash)
    }
    
    private enum CodingKeys : String, CodingKey {
        
        case cardId = "cardID"
        case accountId = "accountID"
        case externalId = "externalID"
        case statusPc = "statusPC"
        case name, validThru, status, expireDate, holderName, branch, product, miniStatement, paymentSystemName, paymentSystemImage, loanBaseParam, isMain,
            statusCard, cardType, idParent, paymentSystemImageMd5Hash
    }
    
    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountId = try container.decodeIfPresent(Int.self, forKey: .accountId)
        cardId = try container.decode(Int.self, forKey: .cardId)
        name = try container.decode(String.self, forKey: .name)
        let validThruValue = try container.decode(Int.self, forKey: .validThru)
        validThru = Date.dateUTC(with: validThruValue)
        status = try container.decode(Status.self, forKey: .status)
        expireDate = try container.decodeIfPresent(String.self, forKey: .expireDate)
        holderName = try container.decodeIfPresent(String.self, forKey: .holderName)
        product = try container.decodeIfPresent(String.self, forKey: .product)
        branch = try container.decode(String.self, forKey: .branch)
        miniStatement = try container.decodeIfPresent([PaymentDataItem].self, forKey: .miniStatement)
        paymentSystemName = try container.decodeIfPresent(String.self, forKey: .paymentSystemName)
        paymentSystemImage = try container.decodeIfPresent(SVGImageData.self, forKey: .paymentSystemImage)
        loanBaseParam = try container.decodeIfPresent(LoanBaseParamInfoData.self, forKey: .loanBaseParam)
        statusPc = try container.decodeIfPresent(ProductData.StatusPC.self, forKey: .statusPc)
        isMain = try container.decodeIfPresent(Bool.self, forKey: .isMain)
        externalId = try container.decodeIfPresent(Int.self, forKey: .externalId)
        statusCard = try container.decodeIfPresent(StatusCard.self, forKey: .statusCard)
        cardType = try container.decodeIfPresent(CardType.self, forKey: .cardType)
        idParent = try container.decodeIfPresent(Int.self, forKey: .idParent)
        paymentSystemImageMd5Hash = try container.decodeIfPresent(String.self, forKey: .paymentSystemImageMd5Hash) ?? ""

        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(accountId, forKey: .accountId)
        try container.encode(cardId, forKey: .cardId)
        try container.encode(name, forKey: .name)
        try container.encode(validThru.secondsSince1970UTC, forKey: .validThru)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(expireDate, forKey: .expireDate)
        try container.encodeIfPresent(holderName, forKey: .holderName)
        try container.encodeIfPresent(product, forKey: .product)
        try container.encode(branch, forKey: .branch)
        try container.encodeIfPresent(miniStatement, forKey: .miniStatement)
        try container.encodeIfPresent(paymentSystemName, forKey: .paymentSystemName)
        try container.encodeIfPresent(paymentSystemImage, forKey: .paymentSystemImage)
        try container.encodeIfPresent(loanBaseParam, forKey: .loanBaseParam)
        try container.encodeIfPresent(statusPc, forKey: .statusPc)
        try container.encodeIfPresent(isMain, forKey: .isMain)
        try container.encodeIfPresent(externalId, forKey: .externalId)
        try container.encodeIfPresent(statusCard, forKey: .statusCard)
        try container.encodeIfPresent(cardType, forKey: .cardType)
        try container.encodeIfPresent(idParent, forKey: .idParent)
        try container.encodeIfPresent(paymentSystemImageMd5Hash, forKey: .paymentSystemImageMd5Hash)

        try super.encode(to: encoder)
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
        
        private enum CodingKeys : String, CodingKey {
            
            case account,  date, amount, currency, purpose
        }
        
        init(from decoder: Decoder) throws {

            let container = try decoder.container(keyedBy: CodingKeys.self)
            account = try container.decodeIfPresent(String.self, forKey: .account)
            let dateValue = try container.decode(Int.self, forKey: .date)
            date = Date.dateUTC(with: dateValue)
            amount = try container.decodeIfPresent(Double.self, forKey: .amount)
            currency = try container.decodeIfPresent(String.self, forKey: .currency)
            purpose = try container.decodeIfPresent(String.self, forKey: .purpose)

        }
        
        func encode(to encoder: Encoder) throws {
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(account, forKey: .account)
            try container.encodeIfPresent(date, forKey: .date)
            try container.encodeIfPresent(amount, forKey: .amount)
            try container.encodeIfPresent(currency, forKey: .currency)
            try container.encodeIfPresent(purpose, forKey: .purpose)
        }
    }
}

//MARK: - LoanBaseParamInfoData

extension ProductCardData {
    
    struct LoanBaseParamInfoData: Codable {
        
        let loanId: Int
        let clientId: Int
        let number: String
        let currencyId: Int?
        let currencyNumber: Int?
        let currencyCode: String?
        let minimumPayment: Double?
        let gracePeriodPayment: Double?
        let overduePayment: Double?
        let availableExceedLimit: Double?
        let ownFunds: Double?
        let debtAmount: Double?
        let totalAvailableAmount: Double?
        let totalDebtAmount: Double?
        
        private enum CodingKeys : String, CodingKey {
            
            case loanId = "loanID"
            case clientId = "clientID"
            case currencyId = "currencyID"
            case number, currencyNumber, currencyCode, minimumPayment, gracePeriodPayment, overduePayment, availableExceedLimit, ownFunds, debtAmount, totalAvailableAmount, totalDebtAmount
        }
        
        internal init(loanId: Int, clientId: Int, number: String, currencyId: Int?, currencyNumber: Int?, currencyCode: String?, minimumPayment: Double?, gracePeriodPayment: Double?, overduePayment: Double?, availableExceedLimit: Double?, ownFunds: Double?, debtAmount: Double?, totalAvailableAmount: Double?, totalDebtAmount: Double?) {
            self.loanId = loanId
            self.clientId = clientId
            self.number = number
            self.currencyId = currencyId
            self.currencyNumber = currencyNumber
            self.currencyCode = currencyCode
            self.minimumPayment = minimumPayment
            self.gracePeriodPayment = gracePeriodPayment
            self.overduePayment = overduePayment
            self.availableExceedLimit = availableExceedLimit
            self.ownFunds = ownFunds
            self.debtAmount = debtAmount
            self.totalAvailableAmount = totalAvailableAmount
            self.totalDebtAmount = totalDebtAmount
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

        guard status == .blockedByBank || status == .blockedByClient || statusPc == .operationsBlocked || statusPc == .blockedByBank || statusPc == .lost || statusPc == .stolen || statusPc == .temporarilyBlocked || statusPc == .blockedByClient || status == .blockedByClient else {
            return false
        }

        return true
    }
  
    
    var canBeUnblocked: Bool {

        return statusPc == .temporarilyBlocked || statusPc == .blockedByClient
    }
    
    var isCreditCard: Bool {
        
        loanBaseParam != nil
    }
}

extension ProductCardData.LoanBaseParamInfoData {
    
    var minimumPaymentValue: Double { minimumPayment ?? 0 }
    var gracePeriodPaymentValue: Double { gracePeriodPayment ?? 0 }
    var overduePaymentValue: Double { overduePayment ?? 0 }
    var availableExceedLimitValue: Double { availableExceedLimit ?? 0 }
    var ownFundsValue: Double { ownFunds ?? 0 }
    var debtAmountValue: Double {
        
        guard let debtAmount = debtAmount else {
            return 0
        }
        
        return max(debtAmount, 0)
    }
    var totalAvailableAmountValue: Double { totalAvailableAmount ?? 0 }
    var totalDebtAmountValue: Double { totalDebtAmount ?? 0 }
}

#warning("For compability with rest/v5/getProductListByType")
extension ProductCardData {
    
    enum StatusCard: String, Codable {
        
        case active = "ACTIVE"
        case blockedUnlockAvailable = "BLOCKED_UNLOCK_AVAILABLE"
        case blockedUnlockNotAvailable = "BLOCKED_UNLOCK_NOT_AVAILABLE"
        case notActivated = "NOT_ACTIVE"
    }

    enum CardType: String, Codable {
        
        case main = "MAIN"
        case regular = "REGULAR"
        case additionalSelf = "ADDITIONAL_SELF"
        case additionalSelfAccOwn = "ADDITIONAL_SELF_ACC_OWN"
        case additionalOther = "ADDITIONAL_OTHER"
    }
}
