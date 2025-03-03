//
//  MakeOpenSavingsAccountResponse.swift
//  
//
//  Created by Andryusina Nataly on 25.11.2024.
//

import Foundation

public struct MakeOpenSavingsAccountResponse: Equatable {
    
    public let documentInfo: DocumentInfo
    public let paymentInfo: PaymentInfo
    public let paymentOperationDetailID: Int?
    
    public init(
        documentInfo: DocumentInfo,
        paymentInfo: PaymentInfo,
        paymentOperationDetailID: Int?
    ) {
        self.documentInfo = documentInfo
        self.paymentInfo = paymentInfo
        self.paymentOperationDetailID = paymentOperationDetailID
    }
    
    public struct DocumentInfo: Equatable {
        
        public let documentStatus: DocumentStatus?
        public let needMake: Bool
        public let needOTP: Bool
        public let scenario: AntiFraudScenario?
        
        public init(
            documentStatus: DocumentStatus?,
            needMake: Bool,
            needOTP: Bool,
            scenario: AntiFraudScenario?
        ) {
            self.documentStatus = documentStatus
            self.needMake = needMake
            self.needOTP = needOTP
            self.scenario = scenario
        }
    }
    
    public struct PaymentInfo: Equatable {
        
        public let amount: Decimal?
        public let accountNumber: String?
        public let accountId: Int?
        public let creditAmount: Decimal?
        public let currencyAmount: String?
        public let currencyPayee: String?
        public let currencyPayer: String?
        public let currencyRate: Decimal?
        public let dateOpen: String?
        public let debitAmount: Decimal?
        public let fee: Decimal?
        public let payeeName: String?
        
        public init(
            amount: Decimal?,
            accountNumber: String?,
            accountId: Int?,
            creditAmount: Decimal?,
            currencyAmount: String?,
            currencyPayee: String?,
            currencyPayer: String?,
            currencyRate: Decimal?,
            dateOpen: String?,
            debitAmount: Decimal?,
            fee: Decimal?,
            payeeName: String?
        ) {
            self.amount = amount
            self.accountNumber = accountNumber
            self.accountId = accountId
            self.creditAmount = creditAmount
            self.currencyAmount = currencyAmount
            self.currencyPayee = currencyPayee
            self.currencyPayer = currencyPayer
            self.currencyRate = currencyRate
            self.dateOpen = dateOpen
            self.debitAmount = debitAmount
            self.fee = fee
            self.payeeName = payeeName
        }
    }
    
    public enum DocumentStatus: Equatable {
        
        case complete, inProgress, rejected
    }

    public enum AntiFraudScenario: Equatable {
        
        case ok, suspect
    }
}

