//
//  GetConsentListAndDefaultBankServiceAdapterTests.swift
//
//
//  Created by Igor Malyarov on 30.12.2023.
//

import Tagged

#warning("keep to preserve API; move to compsition root")
extension ComposedGetConsentListAndDefaultBankService: GetConsentListAndDefaultBankService {}

final class GetConsentListAndDefaultBankServiceAdapter {
    
    typealias Service = GetConsentListAndDefaultBankService
    
    typealias LoadResult = Result<DefaultBank, LoadError>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    private let service: Service
    private let load: Load
    
    init(
        service: Service,
        load: @escaping Load
    ) {
        self.service = service
        self.load = load
    }
}

extension GetConsentListAndDefaultBankServiceAdapter {
    
#warning("replace with typed error")
    typealias LoadError = Error
}

import XCTest

final class GetConsentListAndDefaultBankServiceAdapterTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, serviceSpy, loadSpy) = makeSUT()
        
        XCTAssertNoDiff(serviceSpy.callCount, 0)
        XCTAssertNoDiff(loadSpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = GetConsentListAndDefaultBankServiceAdapter
    private typealias ServiceSpy = ResponseSpy<PhoneNumber, GetConsentListAndDefaultBankResults>
    private typealias LoadSpy = Spy<Void, DefaultBank, Error>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        serviceSpy: ServiceSpy,
        loadSpy: LoadSpy
    ) {
        let serviceSpy = ServiceSpy()
        let loadSpy = LoadSpy()
        let sut = SUT(
            service: serviceSpy,
            load: loadSpy.process
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(serviceSpy, file: file, line: line)
        trackForMemoryLeaks(loadSpy, file: file, line: line)
        
        return (sut, serviceSpy, loadSpy)
    }
}

extension ResponseSpy: GetConsentListAndDefaultBankService
where Payload == PhoneNumber,
      Response == GetConsentListAndDefaultBankResults {}
