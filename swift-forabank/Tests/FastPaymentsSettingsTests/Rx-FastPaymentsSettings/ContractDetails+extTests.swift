//
//  Details+extTests.swift
//
//
//  Created by Igor Malyarov on 17.01.2024.
//

import FastPaymentsSettings
import XCTest

final class ContractDetails_extTests: XCTestCase {
    
    func test_updated_paymentContract() {
        
        let initial = contractDetails(paymentContract: paymentContract(contractStatus: .active))
        let newContract = paymentContract(contractStatus: .inactive)
        
        let new = initial.updated(paymentContract: newContract)
        
        XCTAssertNoDiff(new, .init(
            paymentContract: newContract,
            consentList: initial.consentList,
            bankDefaultResponse: initial.bankDefaultResponse,
            productSelector: initial.productSelector
        ))
    }
    
    func test_updated_consentResult() {
        
        let initial = contractDetails(consentList: consentListFailure())
        let newConsentResult = consentListSuccess()
        
        let new = initial.updated(consentList: newConsentResult)
        
        XCTAssertNoDiff(new, .init(
            paymentContract: initial.paymentContract,
            consentList: newConsentResult,
            bankDefaultResponse: initial.bankDefaultResponse,
            productSelector: initial.productSelector
        ))
    }
    #warning("add tests for bankDefault with non-nil limit")
    func test_updated_bankDefault() {
        
        let initial = contractDetails(bankDefaultResponse: bankDefault(.offDisabled))
        let newBankDefault = bankDefault(.onDisabled)
        
        let new = initial.updated(bankDefaultResponse: newBankDefault)
        
        XCTAssertNoDiff(new, .init(
            paymentContract: initial.paymentContract,
            consentList: initial.consentList,
            bankDefaultResponse: newBankDefault,
            productSelector: initial.productSelector
        ))
    }
    
    func test_updated_productSelector() {
        
        let initial = contractDetails()
        let newProductSelector = makeProductSelector()
        
        let new = initial.updated(productSelector: newProductSelector)
        
        XCTAssertNoDiff(new, .init(
            paymentContract: initial.paymentContract,
            consentList: initial.consentList,
            bankDefaultResponse: initial.bankDefaultResponse,
            productSelector: newProductSelector
        ))
    }
}
