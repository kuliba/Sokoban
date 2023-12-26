//
//  UserAccountViewModelFPSCFLResponseMappingTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.12.2023.
//

@testable import ForaBank
import XCTest

final class UserAccountViewModelFPSCFLResponseMappingTests: XCTestCase {
    
    func test_shouldReturnInActiveOnDoubleYes() {
        
        let list: [FastPaymentContractFullInfoType] = [makeDoubleYes()]
        
        XCTAssertEqual(list.fpsCFLResponse, .inactive)
    }
    
    func test_shouldReturnActiveOnTripleYes() {
        
        let list: [FastPaymentContractFullInfoType] = [makeTripleYes()]
        
        XCTAssertEqual(list.fpsCFLResponse, .active)
    }
    
    func test_shouldReturnMissingOnEmptyList() {
        
        let list: [FastPaymentContractFullInfoType] = []
        
        XCTAssertEqual(list.fpsCFLResponse, .missing)
    }
    
    // MARK: - Helpers
    
    func makeDoubleYes() -> FastPaymentContractFullInfoType {
        
        .init(
            fastPaymentContractAccountAttributeList: nil,
            fastPaymentContractAttributeList: [.stub(
                flagClientAgreementIn: .yes,
                flagClientAgreementOut: .yes
            )],
            fastPaymentContractClAttributeList: nil
        )
    }
    
    func makeTripleYes() -> FastPaymentContractFullInfoType {
        
        .init(
            fastPaymentContractAccountAttributeList: [.stub(
                flagPossibAddAccount: .yes
            )],
            fastPaymentContractAttributeList: [.stub(
                flagClientAgreementIn: .yes,
                flagClientAgreementOut: .yes
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
