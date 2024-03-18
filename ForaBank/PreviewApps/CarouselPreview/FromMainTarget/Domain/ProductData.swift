//
//  ProductData.swift
//  ForaBank
//
//  Created by Max Gribov on 01.02.2022.
//

import SwiftUI

public class ProductData: Identifiable {
    
    public let id: Int
    
    let productType: ProductType
    
    private(set) var order: Int
    private(set) var isVisible: Bool
    
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
    
    let extraLargeDesign: String
    let largeDesign: String
    let mediumDesign: String
    let smallDesign: String
    let background: [ColorData]
    
    //image md5Hash
    let smallDesignMd5hash: String
    let smallBackgroundDesignHash: String
    
    public init(id: Int, productType: ProductType, number: String?, numberMasked: String?, accountNumber: String?, balance: Double?, balanceRub: Double?, currency: String, mainField: String, additionalField: String?, customName: String?, productName: String, openDate: Date?, ownerId: Int, branchId: Int?, allowCredit: Bool, allowDebit: Bool, extraLargeDesign: String, largeDesign: String, mediumDesign: String, smallDesign: String, background: [ColorData], order: Int, isVisible: Bool, smallDesignMd5hash: String, smallBackgroundDesignHash: String) {
        
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
        self.background = background
        self.order = order
        self.isVisible = isVisible
        self.smallDesignMd5hash = smallDesignMd5hash
        self.smallBackgroundDesignHash = smallBackgroundDesignHash
    }
}

extension ProductData {

    var displayPeriod: String? {
        
        switch self {
        case let card as ProductCardData:
            return card.expireDate
            
        default:
            return nil

        }
    }
    
    var displayName: String { customName ?? mainField }
    var balanceValue: Double { balance ?? 0 }
    var backgroundColor: Color { background.first?.color ?? Color("mainColorsBlackMedium") }
    var overlayImageColor: Color {
        
        if background.first?.description == "F6F6F7" {
            return Color("iconGray")
        } else {
            return Color("iconWhite")
        }
    }
}

extension ProductData: Equatable {
    
    public static func == (lhs: ProductData, rhs: ProductData) -> Bool {
        
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
        lhs.background == rhs.background &&
        lhs.isVisible == rhs.isVisible &&
        lhs.order == rhs.order
    }
}

extension ProductData {
    
    enum Status: String, Equatable {
        
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
    
    enum StatusPC: String {
        
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
}
