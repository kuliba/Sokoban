//
//  ContractDetails+extTests.swift
//
//
//  Created by Igor Malyarov on 17.01.2024.
//

import FastPaymentsSettings

extension UserPaymentSettings.ContractDetails {
    
    func updated(
        paymentContract: UserPaymentSettings.PaymentContract? = nil,
        consentResult: UserPaymentSettings.ConsentResult? = nil,
        bankDefault: UserPaymentSettings.BankDefault? = nil,
        productSelector: UserPaymentSettings.ProductSelector? = nil
    ) -> Self {
        
        .init(
            paymentContract: paymentContract ?? self.paymentContract,
            consentResult: consentResult ?? self.consentResult,
            bankDefault: bankDefault ?? self.bankDefault,
            productSelector: productSelector ?? self.productSelector
        )
    }
}

import XCTest

final class ContractDetails_extTests: XCTestCase {
    
    func test_updated_paymentContract() {
        
        let initial = contractDetails(paymentContract: paymentContract(contractStatus: .active))
        let newContract = paymentContract(contractStatus: .inactive)
        
        let new = initial.updated(paymentContract: newContract)
        
        XCTAssertNoDiff(new, .init(
            paymentContract: newContract,
            consentResult: initial.consentResult,
            bankDefault: initial.bankDefault,
            productSelector: initial.productSelector
        ))
    }
    
    func test_updated_consentResult() {
        
        let initial = contractDetails(consentResult: consentResultFailure())
        let newConsentResult = consentResultSuccess()
        
        let new = initial.updated(consentResult: newConsentResult)
        
        XCTAssertNoDiff(new, .init(
            paymentContract: initial.paymentContract,
            consentResult: newConsentResult,
            bankDefault: initial.bankDefault,
            productSelector: initial.productSelector
        ))
    }
    
    func test_updated_bankDefault() {
        
        let initial = contractDetails(bankDefault: .offDisabled)
        let newBankDefault: UserPaymentSettings.BankDefault = .onDisabled
        
        let new = initial.updated(bankDefault: newBankDefault)
        
        XCTAssertNoDiff(new, .init(
            paymentContract: initial.paymentContract,
            consentResult: initial.consentResult,
            bankDefault: newBankDefault,
            productSelector: initial.productSelector
        ))
    }
    
    func test_updated_productSelector() {
        
        let initial = contractDetails()
        let newProductSelector = makeProductSelector()
        
        let new = initial.updated(productSelector: newProductSelector)
        
        XCTAssertNoDiff(new, .init(
            paymentContract: initial.paymentContract,
            consentResult: initial.consentResult,
            bankDefault: initial.bankDefault,
            productSelector: newProductSelector
        ))
    }
}
