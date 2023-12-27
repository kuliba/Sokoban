//
//  FastPaymentsSettingsUserAccountViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 26.12.2023.
//

import Combine
@testable import ForaBank
import XCTest

final class FastPaymentsSettingsUserAccountViewModelTests: XCTestCase {
    
    func test_init_shouldSetFPSCFLResponseToNil() {
        
        let (_,_, responseSpy) = makeSUT()
        
        XCTAssertNoDiff(responseSpy.values, [nil])
    }
    
    func test_init_shouldCallGetFastPaymentContractFindList() {
        
        let (_, findListSpy, _) = makeSUT()
        
        XCTAssertNoDiff(findListSpy.callCount, 1)
    }
    
    func test_shouldSetFPSCFLResponse() {
        
        let (_, findListSpy, responseSpy) = makeSUT()
        
        findListSpy.emitAndWait(.active("abcd123"))
        
        XCTAssertNoDiff(responseSpy.values, [
            nil,
            .active("abcd123"),
        ])
        
        findListSpy.emitAndWait(.inactive)
        
        XCTAssertNoDiff(responseSpy.values, [
            nil,
            .active("abcd123"),
            .inactive,
        ])
        
        findListSpy.emitAndWait(.missing)
        
        XCTAssertNoDiff(responseSpy.values, [
            nil,
            .active("abcd123"),
            .inactive,
            .missing,
        ])
        
        findListSpy.emitAndWait(.error)
        
        XCTAssertNoDiff(responseSpy.values, [
            nil,
            .active("abcd123"),
            .inactive,
            .missing,
            .error,
        ])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = UserAccountViewModel
    private typealias FPSCFLResponse = FastPaymentsServices.FPSCFLResponse
    private typealias FindListSpy = Spy<FPSCFLResponse>
    private typealias ResponseSpy = ValueSpy<FPSCFLResponse?>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        findListSpy: FindListSpy,
        responseSpy: ResponseSpy
    ) {
        let model: Model = .mockWithEmptyExcept()
        let findListSpy = FindListSpy()
        let sut = SUT(
            model: model,
            fastPaymentsFactory: .default,
            fastPaymentsServices: .init(
                getFastPaymentContractFindList: findListSpy.get
            ),
            clientInfo: .stub(),
            dismissAction: {}
        )
        let responseSpy = ValueSpy(sut.$fpsCFLResponse)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(findListSpy, file: file, line: line)
        trackForMemoryLeaks(responseSpy, file: file, line: line)
        
        return (sut, findListSpy, responseSpy)
    }
    
    private final class Spy<Value> {
        
        private(set) var callCount = 0
        private let subject = PassthroughSubject<Value, Never>()
        
        func get() -> AnyPublisher<Value, Never> {
            
            callCount += 1
            return subject.eraseToAnyPublisher()
        }
        
        func emitAndWait(_ value: Value) {
            
            subject.send(value)
            _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
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
