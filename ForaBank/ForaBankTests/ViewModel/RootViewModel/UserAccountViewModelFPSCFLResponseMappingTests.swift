//
//  UserAccountViewModelFPSCFLResponseMappingTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.12.2023.
//

@testable import ForaBank
import XCTest

final class UserAccountViewModelFPSCFLResponseMappingTests: XCTestCase {
    
    func test_shouldReturnMissingOnDoubleYesWithoutPhone() {
        
        let list: [FastPaymentContractFullInfoType] = [makeDoubleYes(phone: nil)]
        
        XCTAssertEqual(list.fpsCFLResponse, .missing)
    }
    
    func test_shouldReturnMissingOnDoubleYesWithEmptyPhone() {
        
        let list: [FastPaymentContractFullInfoType] = [makeDoubleYes(phone: "")]
        
        XCTAssertEqual(list.fpsCFLResponse, .missing)
    }
    
    func test_shouldReturnInactiveOnDoubleYesWithPhone() {
        
        let list: [FastPaymentContractFullInfoType] = [makeDoubleYes(phone: "abc123")]
        
        XCTAssertEqual(list.fpsCFLResponse, .inactive)
    }
    
    func test_shouldReturnMissingOnTripleYesWithoutPhone() {
        
        let list: [FastPaymentContractFullInfoType] = [makeTripleYes(phone: nil)]
        
        XCTAssertEqual(list.fpsCFLResponse, .missing)
    }
    
    func test_shouldReturnMissingOnTripleYesWithEmptyPhone() {
        
        let list: [FastPaymentContractFullInfoType] = [makeTripleYes(phone: "")]
        
        XCTAssertEqual(list.fpsCFLResponse, .missing)
    }
    
    func test_shouldReturnActiveWithPhoneOnTripleYesWithPhone() {
        
        let phone = UUID().uuidString
        let list: [FastPaymentContractFullInfoType] = [makeTripleYes(phone: phone)]
        
        XCTAssertEqual(list.fpsCFLResponse, .active(.init(phone)))
    }
    
    func test_shouldReturnMissingOnEmptyList() {
        
        let list: [FastPaymentContractFullInfoType] = []
        
        XCTAssertEqual(list.fpsCFLResponse, .missing)
    }
    
    // MARK: - Helpers
    
    private func makeDoubleYes(
        phone: String?
    ) -> FastPaymentContractFullInfoType {
        
        .init(
            fastPaymentContractAccountAttributeList: nil,
            fastPaymentContractAttributeList: [.stub(
                flagClientAgreementIn: .yes,
                flagClientAgreementOut: .yes,
                phoneNumber: phone
            )],
            fastPaymentContractClAttributeList: nil
        )
    }
    
    private func makeTripleYes(
        phone: String?
    ) -> FastPaymentContractFullInfoType {
        
        .init(
            fastPaymentContractAccountAttributeList: [.stub(
                flagPossibAddAccount: .yes
            )],
            fastPaymentContractAttributeList: [.stub(
                flagClientAgreementIn: .yes,
                flagClientAgreementOut: .yes,
                phoneNumber: phone
            )],
            fastPaymentContractClAttributeList: nil
        )
    }
}

extension FastPaymentContractAccountAttributeTypeData {
    
    static func stub(
        accountId: Int? = nil,
        accountNumber: String? = nil,
        flagPossibAddAccount: FastPaymentFlag? = nil,
        maxAddAccount: Double? = nil,
        minAddAccount: Double? = nil
    ) -> Self {
        
        .init(
            accountId: accountId,
            accountNumber: accountNumber,
            flagPossibAddAccount: flagPossibAddAccount,
            maxAddAccount: maxAddAccount,
            minAddAccount: minAddAccount
        )
    }
}

extension FastPaymentContractAttributeTypeData {
    
    static func stub(
        accountId: Int? = nil,
        branchBic: String? = nil,
        branchId: Int? = nil,
        clientId: Int? = nil,
        flagBankDefault: FastPaymentFlag? = nil,
        flagClientAgreementIn: FastPaymentFlag? = nil,
        flagClientAgreementOut: FastPaymentFlag? = nil,
        fpcontractId: Int? = nil,
        phoneNumber: String? = nil
    ) -> Self {
        
        .init(
            accountId: accountId,
            branchBic: branchBic,
            branchId: branchId,
            clientId: clientId,
            flagBankDefault: flagBankDefault,
            flagClientAgreementIn: flagClientAgreementIn,
            flagClientAgreementOut: flagClientAgreementOut,
            fpcontractId: fpcontractId,
            phoneNumber: phoneNumber
        )
    }
}
