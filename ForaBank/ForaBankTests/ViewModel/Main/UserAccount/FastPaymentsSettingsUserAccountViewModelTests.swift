//
//  FastPaymentsSettingsUserAccountViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.12.2023.
//

@testable import ForaBank
import XCTest

final class FastPaymentsSettingsUserAccountViewModelTests: XCTestCase {
    
    func test_init_shouldCallGetFastPaymentContractFindList() {
    
        let (_,_, findListSpy) = makeSUT()
        
        XCTAssertNoDiff(findListSpy.callCount, 1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UserAccountViewModel
    private typealias FindListSpy = Spy
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        model: Model,
        findListSpy: FindListSpy
    ) {
        let model: Model = .mockWithEmptyExcept()
        let findListSpy = FindListSpy()
        let sut = SUT(
            model: model,
            getFastPaymentContractFindList: findListSpy.get,
            clientInfo: .stub(),
            dismissAction: {}
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model, findListSpy)
    }
    
    private final class Spy {
        
        private(set) var callCount = 0
        
        func get() {
            
            callCount += 1
        }
    }
}

private extension ClientInfoData {
    
    static func stub(
        id: Int = 98765,
        lastName: String = "LastName",
        firstName: String = "FirstName",
        patronymic: String? = "MiddleName",
        birthDay: String? = nil,
        regSeries: String? = nil,
        regNumber: String = "abcdef",
        birthPlace: String? = nil,
        dateOfIssue: String? = nil,
        codeDepartment: String? = nil,
        regDepartment: String? = nil,
        address: String = "Address",
        addressInfo: ClientInfoData.AddressInfo? = nil,
        addressResidential: String? = nil,
        addressResidentialInfo: ClientInfoData.AddressInfo? = nil,
        phone: String = "phone",
        phoneSMS: String? = nil,
        email: String? = nil,
        inn: String? = nil,
        customName: String? = nil
    ) -> Self {
        
        .init(
            id: id,
            lastName: lastName,
            firstName: firstName,
            patronymic: patronymic,
            birthDay: birthDay,
            regSeries: regSeries,
            regNumber: regNumber,
            birthPlace: birthPlace,
            dateOfIssue: dateOfIssue,
            codeDepartment: codeDepartment,
            regDepartment: regDepartment,
            address: address,
            addressInfo: addressInfo,
            addressResidential: addressResidential,
            addressResidentialInfo: addressResidentialInfo,
            phone: phone,
            phoneSMS: phoneSMS,
            email: email,
            inn: inn,
            customName: customName
        )
    }
}
