//
//  ProductLoanData.swift
//  ForaBank
//
//  Created by Дмитрий on 05.04.2022.
//

import Foundation

class ProductLoanData: ProductData {
    
    let currencyNumber: Int?
    let bankProductId: Int
    let amount: Double
    let currentInterestRate: Double
    let principalDebt: Double?
    let defaultPrincipalDebt: Double?
    let totalAmountDebt: Double?
    let principalDebtAccount: String
    let settlementAccount: String
    let settlementAccountId: Int
    let dateLong: Date
    let strDateLong: String
    
    init(id: Int, productType: ProductType, number: String?, numberMasked: String?, accountNumber: String?, balance: Double?, balanceRub: Double?, currency: String, mainField: String, additionalField: String?, customName: String?, productName: String, openDate: Date?, ownerId: Int, branchId: Int?, allowCredit: Bool, allowDebit: Bool, extraLargeDesign: SVGImageData, largeDesign: SVGImageData, smallDesign: SVGImageData, fontDesignColor: ColorData, background: [ColorData], currencyNumber: Int?, bankProductId: Int, amount: Double, currentInterestRate: Double, principalDebt: Double?, defaultPrincipalDebt: Double?, totalAmountDebt: Double?, principalDebtAccount: String, settlementAccount: String, settlementAccountId: Int, dateLong: Date, strDateLong: String, order: Int, visibility: Bool, smallDesignMd5hash: String, smallBackgroundDesignHash: String) {
        
        self.currencyNumber = currencyNumber
        self.bankProductId = bankProductId
        self.amount = amount
        self.currentInterestRate = currentInterestRate
        self.principalDebt = principalDebt
        self.defaultPrincipalDebt = defaultPrincipalDebt
        self.totalAmountDebt = totalAmountDebt
        self.principalDebtAccount = principalDebtAccount
        self.settlementAccount = settlementAccount
        self.settlementAccountId = settlementAccountId
        self.dateLong = dateLong
        self.strDateLong = strDateLong
        
        super.init(id: id, productType: productType, number: number, numberMasked: numberMasked, accountNumber: accountNumber, balance: balance, balanceRub: balanceRub, currency: currency, mainField: mainField, additionalField: additionalField, customName: customName, productName: productName, openDate: openDate, ownerId: ownerId, branchId: branchId, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: extraLargeDesign, largeDesign: largeDesign,  smallDesign: smallDesign, fontDesignColor: fontDesignColor, background: background, order: order, isVisible: visibility, smallDesignMd5hash: smallDesignMd5hash, smallBackgroundDesignHash: smallBackgroundDesignHash)
    }
    
    private enum CodingKeys : String, CodingKey {
        case bankProductId = "bankProductID"
        case currencyNumber, amount, currentInterestRate, principalDebt, defaultPrincipalDebt, totalAmountDebt, principalDebtAccount, settlementAccount, settlementAccountId, dateLong, strDateLong
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currencyNumber = try container.decodeIfPresent(Int.self, forKey: .currencyNumber)
        bankProductId = try container.decode(Int.self, forKey: .bankProductId)
        amount = try container.decode(Double.self, forKey: .amount)
        currentInterestRate = try container.decode(Double.self, forKey: .currentInterestRate)
        principalDebt = try container.decodeIfPresent(Double.self, forKey: .principalDebt)
        defaultPrincipalDebt = try container.decodeIfPresent(Double.self, forKey: .defaultPrincipalDebt)
        totalAmountDebt = try container.decodeIfPresent(Double.self, forKey: .totalAmountDebt)
        principalDebtAccount = try container.decode(String.self, forKey: .principalDebtAccount)
        settlementAccount = try container.decode(String.self, forKey: .settlementAccount)
        settlementAccountId = try container.decode(Int.self, forKey: .settlementAccountId)
        let dateLongValue = try container.decode(Int.self, forKey: .dateLong)
        dateLong = Date.dateUTC(with: dateLongValue)
        strDateLong = try container.decode(String.self, forKey: .strDateLong)

        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currencyNumber, forKey: .currencyNumber)
        try container.encode(bankProductId, forKey: .bankProductId)
        try container.encode(amount, forKey: .amount)
        try container.encode(currentInterestRate, forKey: .currentInterestRate)
        try container.encode(principalDebt, forKey: .principalDebt)
        try container.encode(defaultPrincipalDebt, forKey: .defaultPrincipalDebt)
        try container.encode(totalAmountDebt, forKey: .totalAmountDebt)
        try container.encode(principalDebtAccount, forKey: .principalDebtAccount)
        try container.encode(settlementAccount, forKey: .settlementAccount)
        try container.encode(settlementAccountId, forKey: .settlementAccountId)
        try container.encode(dateLong.secondsSince1970UTC, forKey: .dateLong)
        try container.encode(strDateLong, forKey: .strDateLong)

        try super.encode(to: encoder)
    }
    
    //MARK: Equitable
    
    static func == (lhs: ProductLoanData, rhs: ProductLoanData) -> Bool {
        
        return lhs.currencyNumber == rhs.currencyNumber &&
        lhs.bankProductId == rhs.bankProductId &&
        lhs.amount == rhs.amount &&
        lhs.currentInterestRate == rhs.currentInterestRate &&
        lhs.principalDebt == rhs.principalDebt &&
        lhs.defaultPrincipalDebt == rhs.defaultPrincipalDebt &&
        lhs.totalAmountDebt == rhs.totalAmountDebt &&
        lhs.principalDebtAccount == rhs.principalDebtAccount &&
        lhs.settlementAccount == rhs.settlementAccount &&
        lhs.settlementAccountId == rhs.settlementAccountId &&
        lhs.dateLong == rhs.dateLong &&
        lhs.strDateLong == rhs.strDateLong
    }
}

extension ProductLoanData {
    
    enum LoanType {
     
        case mortgage
        case consumer
    }
}

extension ProductLoanData {
    
    var loanType: LoanType {
        
        switch productName {
        case "Ф_ПотКред": return .consumer
        case "Ф_ИпКред": return .mortgage
        default: return .consumer
        }
    }
}

extension ProductLoanData {
    
    var totalAmountDebtValue: Double { totalAmountDebt ?? 0 }
}

