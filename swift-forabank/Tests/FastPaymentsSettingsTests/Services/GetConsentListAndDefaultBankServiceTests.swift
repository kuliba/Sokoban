//
//  GetConsentListAndDefaultBankServiceTests.swift
//
//
//  Created by Igor Malyarov on 30.12.2023.
//

import Tagged

final class GetConsentListAndDefaultBankService {
    
    typealias BankID = Tagged<_BankID, String>
    enum _BankID {}
    
    typealias GetConsentListResult = Result<[BankID], Error>
    typealias GetConsentListCompletion = (GetConsentListResult) -> Void
    typealias GetConsentList = (@escaping GetConsentListCompletion) -> Void
    
    typealias DefaultBank = Tagged<_DefaultBank, Bool>
    enum _DefaultBank {}
    
    typealias PhoneNumber = Tagged<_PhoneNumber, String>
    enum _PhoneNumber {}
    
    typealias GetDefaultBankResult = Result<DefaultBank, Error>
    typealias GetDefaultBankCompletion = (GetDefaultBankResult) -> Void
    typealias GetDefaultBank = (PhoneNumber, @escaping GetDefaultBankCompletion) -> Void
    
    private let getConsentList: GetConsentList
    private let getDefaultBank: GetDefaultBank
    
    init(
        getConsentList: @escaping GetConsentList,
        getDefaultBank: @escaping GetDefaultBank
    ) {
        self.getConsentList = getConsentList
        self.getDefaultBank = getDefaultBank
    }
}

import XCTest

final class GetConsentListAndDefaultBankServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getConsentListSpy, getDefaultBankSpy) = makeSUT()
        
        XCTAssertNoDiff(getConsentListSpy.callCount, 0)
        XCTAssertNoDiff(getDefaultBankSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = GetConsentListAndDefaultBankService
    private typealias GetConsentListSpy = Spy<Void, [SUT.BankID], Error>
    private typealias GetDefaultBankSpy = Spy<SUT.PhoneNumber, SUT.DefaultBank, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getConsentListSpy: GetConsentListSpy,
        getDefaultBankSpy: GetDefaultBankSpy
    ) {
        let getConsentListSpy = GetConsentListSpy()
        let getDefaultBankSpy = GetDefaultBankSpy()
        let sut = SUT(
            getConsentList: getConsentListSpy.process,
            getDefaultBank: getDefaultBankSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getConsentListSpy, file: file, line: line)
        trackForMemoryLeaks(getDefaultBankSpy, file: file, line: line)
        
        return (sut, getConsentListSpy, getDefaultBankSpy)
    }
}
