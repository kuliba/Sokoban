//
//  ProductData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import Foundation
import SwiftUI

class ProductData: Identifiable, Codable {
    
    let id: Int
    
    let productType: ProductType
    
    let number: String? // 4444555566661122
    let numberMasked: String? //4444-XXXX-XXXX-1122
    let accountNumber: String? // 40817810000000000001
    
    private(set) var balance: Double?
    private(set) var balanceRub: Double?
    //TODO: Currency type??
    let currency: String // example: RUB
    
    let mainField: String // example: Gold
    let additionalField: String? // example: Зарплатная
    private(set) var customName: String? // example: Моя карта
    let productName: String // example: VISA REWARDS R-5
    
    let openDate: Date?
    let ownerId: Int
    let branchId: Int?
    
    let allowCredit: Bool
    let allowDebit: Bool
    
    let extraLargeDesign: SVGImageData
    let largeDesign: SVGImageData
    let mediumDesign: SVGImageData
    let smallDesign: SVGImageData
    let fontDesignColor: ColorData
    let background: [ColorData]
    
    init(id: Int, productType: ProductType, number: String?, numberMasked: String?, accountNumber: String?, balance: Double?, balanceRub: Double?, currency: String, mainField: String, additionalField: String?, customName: String?, productName: String, openDate: Date?, ownerId: Int, branchId: Int?, allowCredit: Bool, allowDebit: Bool, extraLargeDesign: SVGImageData, largeDesign: SVGImageData, mediumDesign: SVGImageData, smallDesign: SVGImageData, fontDesignColor: ColorData, background: [ColorData]) {
        self.id = id
        self.productType = productType
        self.number = number
        self.numberMasked = numberMasked
        self.accountNumber = accountNumber
        self.balance = balance
        self.balanceRub = balanceRub
        self.currency = currency
        self.mainField = mainField
        self.additionalField = additionalField
        self.customName = customName
        self.productName = productName
        self.openDate = openDate
        self.ownerId = ownerId
        self.branchId = branchId
        self.allowCredit = allowCredit
        self.allowDebit = allowDebit
        self.extraLargeDesign = extraLargeDesign
        self.largeDesign = largeDesign
        self.mediumDesign = mediumDesign
        self.smallDesign = smallDesign
        self.fontDesignColor = fontDesignColor
        self.background = background
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case extraLargeDesign = "XLDesign"
        case balanceRub = "balanceRUB"
        case ownerId = "ownerID"
        case accountNumber, additionalField, allowCredit, allowDebit, background, balance, branchId, currency, customName, fontDesignColor, id, largeDesign, mainField, mediumDesign, number, numberMasked, openDate, productName, productType, smallDesign
    }
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productType = try container.decode(ProductType.self, forKey: .productType)
        id = try container.decode(Int.self, forKey: .id)
        number = try container.decodeIfPresent(String.self, forKey: .number)
        numberMasked = try container.decodeIfPresent(String.self, forKey: .numberMasked)
        accountNumber = try container.decodeIfPresent(String.self, forKey: .accountNumber)
        balance = try container.decodeIfPresent(Double.self, forKey: .balance)
        balanceRub = try container.decodeIfPresent(Double.self, forKey: .balanceRub)
        currency = try container.decode(String.self, forKey: .currency)
        mainField = try container.decode(String.self, forKey: .mainField)
        additionalField = try container.decodeIfPresent(String.self, forKey: .additionalField)
        customName = try container.decodeIfPresent(String.self, forKey: .customName)
        productName = try container.decode(String.self, forKey: .productName)
        if let openDateValue = try container.decodeIfPresent(Int.self, forKey: .openDate) {
            
            openDate = Date(timeIntervalSince1970: TimeInterval(openDateValue / 1000))
        } else {
            
            openDate = nil
        }
        ownerId = try container.decode(Int.self, forKey: .ownerId)
        branchId = try container.decodeIfPresent(Int.self, forKey: .branchId)
        allowCredit = try container.decode(Bool.self, forKey: .allowCredit)
        allowDebit = try container.decode(Bool.self, forKey: .allowDebit)
        extraLargeDesign = try container.decode(SVGImageData.self, forKey: .extraLargeDesign)
        largeDesign = try container.decode(SVGImageData.self, forKey: .largeDesign)
        mediumDesign = try container.decode(SVGImageData.self, forKey: .mediumDesign)
        smallDesign = try container.decode(SVGImageData.self, forKey: .smallDesign)
        fontDesignColor = try container.decode(ColorData.self, forKey: .fontDesignColor)
        background = try container.decode([ColorData].self, forKey: .background)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(productType, forKey: .productType)
        try container.encodeIfPresent(number, forKey: .number)
        try container.encodeIfPresent(numberMasked, forKey: .numberMasked)
        try container.encode(accountNumber, forKey: .accountNumber)
        try container.encodeIfPresent(balance, forKey: .balance)
        try container.encodeIfPresent(balanceRub, forKey: .balanceRub)
        try container.encode(currency, forKey: .currency)
        try container.encode(mainField, forKey: .mainField)
        try container.encodeIfPresent(additionalField, forKey: .additionalField)
        try container.encodeIfPresent(customName, forKey: .customName)
        try container.encode(productName, forKey: .productName)
        if let openDate = openDate {
            try container.encodeIfPresent(Int(openDate.timeIntervalSince1970) * 1000, forKey: .openDate)
        }
        try container.encode(ownerId, forKey: .ownerId)
        try container.encodeIfPresent(branchId, forKey: .branchId)
        try container.encode(allowCredit, forKey: .allowCredit)
        try container.encode(allowDebit, forKey: .allowDebit)
        try container.encode(extraLargeDesign, forKey: .extraLargeDesign)
        try container.encode(largeDesign, forKey: .largeDesign)
        try container.encode(mediumDesign, forKey: .mediumDesign)
        try container.encode(smallDesign, forKey: .smallDesign)
        try container.encode(fontDesignColor, forKey: .fontDesignColor)
        try container.encode(background, forKey: .background)
    }
}

extension ProductData {
    
    func update(with params: ProductDynamicParamsData) {
        
        self.balance = params.balance
        self.customName = params.customName
        self.balanceRub = params.balanceRub
    }
}


extension ProductData {
    
    var displayNumber: String? {
        
        switch self {
        case let loanProduct as ProductLoanData:
            return String(loanProduct.settlementAccount.suffix(4))
            
        case let depositProduct as ProductDepositData:
            guard let accountNumber = depositProduct.accountNumber else {
               return nil
            }
            
            return String(accountNumber.suffix(4))
            
        default:
            guard let number = number else {
                return nil
            }
            
            return String(number.suffix(4))
        }
    }
    
    var displayPeriod: String? {
        
        let formatter = DateFormatter.productPeriod
        
        if let cardProduct = self as? ProductCardData {
            
            return cardProduct.expireDate
            
        } else if let loanProduct = self as? ProductLoanData {
            
            return formatter.string(from: loanProduct.dateLong)
            
        } else {
            
            return nil
        }
    }
    
    var displayName: String { customName ?? mainField }
    var balanceValue: Double { balance ?? 0 }
    var backgroundColor: Color { background.first?.color ?? .mainColorsBlackMedium }
}

extension ProductData: Equatable {
    
    static func == (lhs: ProductData, rhs: ProductData) -> Bool {
        
        return  lhs.id == rhs.id &&
        lhs.productType == rhs.productType &&
        lhs.number == rhs.number &&
        lhs.numberMasked == rhs.numberMasked &&
        lhs.accountNumber == rhs.accountNumber &&
        lhs.balance == rhs.balance &&
        lhs.balanceRub == rhs.balanceRub &&
        lhs.currency == rhs.currency &&
        lhs.mainField == rhs.mainField &&
        lhs.additionalField == rhs.additionalField &&
        lhs.customName == rhs.customName &&
        lhs.productName == rhs.productName &&
        lhs.openDate == rhs.openDate &&
        lhs.ownerId == rhs.ownerId &&
        lhs.branchId == rhs.branchId &&
        lhs.allowCredit == rhs.allowCredit &&
        lhs.allowDebit == rhs.allowDebit &&
        lhs.extraLargeDesign == rhs.extraLargeDesign &&
        lhs.largeDesign == rhs.largeDesign &&
        lhs.mediumDesign == rhs.mediumDesign &&
        lhs.smallDesign == rhs.smallDesign &&
        lhs.fontDesignColor == rhs.fontDesignColor &&
        lhs.background == rhs.background
    }
}

extension ProductData {
    
    enum Status: String, Codable, Equatable, Unknownable {
        
        case blockedByClient = "Блокирована по решению Клиента"
        case active = "Действует"
        case issuedToClient = "Выдано клиенту"
        case blockedByBank = "Заблокирована банком"
        case notBlocked = "NOT_BLOCKED"
        case blockedDebet = "BLOCKED_DEBET"
        case blockedCredit = "BLOCKED_CREDIT"
        case blocked = "BLOCKED"
        case unknown
    }
    
    enum StatusPC: String, Codable, Unknownable {
        
        case active = "0"
        case operationsBlocked = "3"
        case blockedByBank = "5"
        case lost = "6"
        case stolen = "7"
        case notActivated = "17"
        case temporarilyBlocked = "20"
        case blockedByClient = "21"
        case unknown
    }
    
    var isAccountNumber: Bool {
        
        guard let accountNumber = accountNumber else {
            return false
        }
        
        return accountNumber.hasPrefix("40817") || accountNumber.hasPrefix("40820")
    }
    
    func allowProduct(_ currencyOperation: CurrencyOperation) -> Bool {
        allowDebit(currencyOperation) || allowCredit(currencyOperation)
    }
    
    private func allowDebit(_ currencyOperation: CurrencyOperation) -> Bool {
        allowDebit == (currencyOperation == .buy) ? true : false
    }
    
    private func allowCredit(_ currencyOperation: CurrencyOperation) -> Bool {
        allowCredit == (currencyOperation == .sell) ? true : false
    }
}
