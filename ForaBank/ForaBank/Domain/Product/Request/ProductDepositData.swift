//
//  ProductDepositData.swift
//  ForaBank
//
//  Created by Дмитрий on 05.04.2022.
//

import Foundation

class ProductDepositData: ProductData {

    let depositProductId: Int
    let depositId: Int
    let interestRate: Double
    let accountId: Int
    let creditMinimumAmount: Double?
    let minimumBalance: Double?
    let endDate: Date?
    let endDateNf: Bool?
    
    internal init(id: Int, productType: ProductType, number: String, numberMasked: String, accountNumber: String, balance: Double, balanceRub: Double?, currency: String, mainField: String, additionalField: String?, customName: String?, productName: String, openDate: Date, ownerId: Int, branchId: Int, allowCredit: Bool, allowDebit: Bool,extraLargeDesign: SVGImageData, largeDesign: SVGImageData, mediumDesign: SVGImageData, smallDesign: SVGImageData, fontDesignColor: ColorData, background: [ColorData], depositProductId: Int, depositId: Int, interestRate: Double, accountId: Int, creditMinimumAmount: Double, minimumBalance: Double, endDate: Date?, endDateNf: Bool?) {
        
        self.depositProductId = depositProductId
        self.depositId = depositId
        self.interestRate = interestRate
        self.accountId = accountId
        self.creditMinimumAmount = creditMinimumAmount
        self.minimumBalance = minimumBalance
        self.endDate = endDate
        self.endDateNf = endDateNf
        
        super.init(id: id, productType: productType, number: number, numberMasked: numberMasked, accountNumber: accountNumber, balance: balance, balanceRub: balanceRub, currency: currency, mainField: mainField, additionalField: additionalField, customName: customName, productName: productName, openDate: openDate, ownerId: ownerId, branchId: branchId, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: extraLargeDesign, largeDesign: largeDesign, mediumDesign: mediumDesign, smallDesign: smallDesign, fontDesignColor: fontDesignColor, background: background)
    }
    
    private enum CodingKeys : String, CodingKey {
        
        case depositProductId = "depositProductID"
        case depositId = "depositID"
        case accountId = "accountID"
        case interestRate, creditMinimumAmount, minimumBalance
        case endDate
        case endDateNf = "endDate_nf"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        depositProductId = try container.decode(Int.self, forKey: .depositProductId)
        depositId = try container.decode(Int.self, forKey: .depositId)
        interestRate = try container.decode(Double.self, forKey: .interestRate)
        accountId = try container.decode(Int.self, forKey: .accountId)
        creditMinimumAmount = try container.decodeIfPresent(Double.self, forKey: .creditMinimumAmount)
        minimumBalance = try container.decodeIfPresent(Double.self, forKey: .minimumBalance)
        if let endDateValue = try container.decodeIfPresent(Int.self, forKey: .endDate) {
            
            endDate = Date(timeIntervalSince1970: TimeInterval(endDateValue / 1000))
            
        } else {
            
            endDate = nil
        }
        endDateNf = try container.decodeIfPresent(Bool.self, forKey: .endDateNf)

        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(depositProductId, forKey: .depositProductId)
        try container.encode(depositId, forKey: .depositId)
        try container.encode(interestRate, forKey: .interestRate)
        try container.encode(accountId, forKey: .accountId)
        try container.encodeIfPresent(creditMinimumAmount, forKey: .creditMinimumAmount)
        try container.encodeIfPresent(minimumBalance, forKey: .minimumBalance)
        if let endDate = endDate {
            
            try container.encode(Int(endDate.timeIntervalSince1970) * 1000, forKey: .endDate)
        }
        try container.encodeIfPresent(endDateNf, forKey: .endDateNf)

        try super.encode(to: encoder)
    }
    
    //MARK: Equitable
    
    static func == (lhs: ProductDepositData, rhs: ProductDepositData) -> Bool {
        
        return  lhs.depositProductId == rhs.depositProductId &&
        lhs.depositId == rhs.depositId &&
        lhs.interestRate == rhs.interestRate &&
        lhs.accountId == rhs.accountId &&
        lhs.creditMinimumAmount == rhs.creditMinimumAmount &&
        lhs.minimumBalance == rhs.minimumBalance
    }
}

//MARK: - Helpers

extension ProductDepositData {
        
    func availableTransferType(with info: DepositInfoDataItem?) -> TransferType? {
        
        guard let endDate = endDate else {
            return nil
        }

        if depositProductId == Self.foraHitProductId {
            
            // Fora Hit Deposit

            if endDate > Date() {
                
                guard let interestAmount = info?.sumPayPrc, interestAmount > 0 else {
                    return nil
                }
                
                return .interest
                
            } else {
                
                return .remains
            }

        } else {
            
            // All other deposits
            
            guard endDate <= Date() else {
                return nil
            }
            
            return .remains
        }
    }
    
    static let foraHitProductId = 10000003792
    
    enum TransferType {
        
        case remains
        case interest
    }
}
