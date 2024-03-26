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
    let endDateNf: Bool
    let isDemandDeposit: Bool
    let isDebitInterestAvailable: Bool?
    
    init(id: Int, productType: ProductType, number: String?, numberMasked: String?, accountNumber: String?, balance: Double?, balanceRub: Double?, currency: String, mainField: String, additionalField: String?, customName: String?, productName: String, openDate: Date?, ownerId: Int, branchId: Int?, allowCredit: Bool, allowDebit: Bool, extraLargeDesign: SVGImageData, largeDesign: SVGImageData, mediumDesign: SVGImageData, smallDesign: SVGImageData, fontDesignColor: ColorData, background: [ColorData], depositProductId: Int, depositId: Int, interestRate: Double, accountId: Int, creditMinimumAmount: Double, minimumBalance: Double, endDate: Date?, endDateNf: Bool, isDemandDeposit: Bool, isDebitInterestAvailable: Bool?, order: Int, visibility: Bool, smallDesignMd5hash: String, smallBackgroundDesignHash: String) {
        
        self.depositProductId = depositProductId
        self.depositId = depositId
        self.interestRate = interestRate
        self.accountId = accountId
        self.creditMinimumAmount = creditMinimumAmount
        self.minimumBalance = minimumBalance
        self.endDate = endDate
        self.endDateNf = endDateNf
        self.isDemandDeposit = isDemandDeposit
        self.isDebitInterestAvailable = isDebitInterestAvailable
        
        super.init(id: id, productType: productType, number: number, numberMasked: numberMasked, accountNumber: accountNumber, balance: balance, balanceRub: balanceRub, currency: currency, mainField: mainField, additionalField: additionalField, customName: customName, productName: productName, openDate: openDate, ownerId: ownerId, branchId: branchId, allowCredit: allowCredit, allowDebit: allowDebit, extraLargeDesign: extraLargeDesign, largeDesign: largeDesign, mediumDesign: mediumDesign, smallDesign: smallDesign, fontDesignColor: fontDesignColor, background: background, order: order, isVisible: visibility, smallDesignMd5hash: smallDesignMd5hash, smallBackgroundDesignHash: smallBackgroundDesignHash)
    }
    
    private enum CodingKeys : String, CodingKey {
        
        case interestRate, creditMinimumAmount, minimumBalance, endDate, isDebitInterestAvailable
        case isDemandDeposit = "demandDeposit"
        case depositProductId = "depositProductID"
        case depositId = "depositID"
        case accountId = "accountID"
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
        isDemandDeposit = try container.decode(Bool.self, forKey: .isDemandDeposit)
        
        if let debitInterestAvailable = try container.decodeIfPresent(Bool.self, forKey: .isDebitInterestAvailable) {
            
            isDebitInterestAvailable = debitInterestAvailable
            
        } else {
            
            isDebitInterestAvailable = false
        }
        
        if let endDateValue = try container.decodeIfPresent(Int.self, forKey: .endDate) {
            
            endDate = Date.dateUTC(with: endDateValue)
            
        } else {
            
            endDate = nil
        }
        endDateNf = try container.decode(Bool.self, forKey: .endDateNf)

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
        try container.encodeIfPresent(isDemandDeposit, forKey: .isDemandDeposit)
        try container.encodeIfPresent(isDebitInterestAvailable, forKey: .isDebitInterestAvailable)

        if let endDate = endDate {
            
            try container.encode(endDate.secondsSince1970UTC, forKey: .endDate)
        }
        try container.encode(endDateNf, forKey: .endDateNf)

        try super.encode(to: encoder)
    }
    
    //MARK: Equitable
    
    static func == (lhs: ProductDepositData, rhs: ProductDepositData) -> Bool {
        
        return  lhs.depositProductId == rhs.depositProductId &&
        lhs.depositId == rhs.depositId &&
        lhs.interestRate == rhs.interestRate &&
        lhs.accountId == rhs.accountId &&
        lhs.creditMinimumAmount == rhs.creditMinimumAmount &&
        lhs.minimumBalance == rhs.minimumBalance &&
        lhs.isDemandDeposit == rhs.isDemandDeposit &&
        lhs.isDebitInterestAvailable == rhs.isDebitInterestAvailable
    }
}

//MARK: - Helpers

extension ProductDepositData {
        
    func availableTransferType(with info: DepositInfoDataItem?) -> TransferType? {
        
        if isDemandDeposit, allowDebit {
            
            return .remains
            
        } else {
            
            if isDebitInterestAvailable == true {
                
                // Fora Hit Deposit
                
                if endDateNf {
                    
                    if let balance = info?.balance {
                        
                        return .close(balance)
                        
                    } else {
                        
                        return .interest(0)
                    }
                    
                } else {
                    
                    if let endDate = endDate {
                        
                        if endDate > Date() {
                            
                            if let interestAmount = info?.sumPayPrc {
                                
                                return .interest(interestAmount)
                                
                            } else {
                                
                                return .interest(0)
                            }
                            
                        } else {
                            
                            return .remains
                        }
                        
                    } else {
                        
                        return .remains
                    }
                }
                
            } else {
                
                // All other deposits
                
                if endDateNf,
                   let balance = info?.balance {
                    
                    return .close(balance)
                } else {
                   
                    return nil
                }
            }
        }
    }
    
    var depositType: DepositType? {
        
        DepositType(rawValue: depositProductId)
    }
    
    var isCanClosedDeposit: Bool {
        
        !endDateNf
    }
    
    var isCanReplenish: Bool {
        
        if isDemandDeposit {
        
            return allowCredit
            
        } else if let endDate = endDate,
           endDate <= Date() {
            
           return false
            
        } else {
            
            return true
        }
    }
    
    enum TransferType: Equatable {
        
        case remains
        case interest(Double)
        case close(Double)
    }
    
    enum DepositType: Int {
        
        case multi = 10000001870
        case birjevoy = 10000003655
        case forahit = 10000003792
    }
}
