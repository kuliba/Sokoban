//
//  Services+makeActivationServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 09.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

final class Services_makeActivationServiceTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
    
        let (_, getCodeSpy, formSessionKeySpy, bindPublicKeySpy) = makeSUT()
        
        XCTAssertEqual(getCodeSpy.callCount, 0)
        XCTAssertEqual(formSessionKeySpy.callCount, 0)
        XCTAssertEqual(bindPublicKeySpy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CVVPINFunctionalityActivationService
    private typealias GetCodeService = FetcherSpy<Void, GetProcessingSessionCodeService.Response, GetProcessingSessionCodeService.Error>
    private typealias FormKeyService = FetcherSpy<Void, FormSessionKeyService.Success, FormSessionKeyService.Error>
    private typealias BindPublicKeyService = FetcherSpy<BindPublicKeyWithEventIDService.OTP, Void, BindPublicKeyWithEventIDService.Error>

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getCodeSpy: GetCodeService,
        formSessionKeySpy: FormKeyService,
        bindPublicKeySpy: BindPublicKeyService
    ) {

        let getCodeSpy = GetCodeService()
        let formSessionKeySpy = FormKeyService()
        let bindPublicKeySpy = BindPublicKeyService()

        let sut = Services.makeActivationService(
            getCode: getCodeSpy.fetch,
            formSessionKey: formSessionKeySpy.fetch,
            bindPublicKeyWithEventID: bindPublicKeySpy.fetch
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getCodeSpy, file: file, line: line)
        trackForMemoryLeaks(formSessionKeySpy, file: file, line: line)
        trackForMemoryLeaks(bindPublicKeySpy, file: file, line: line)
        
        return (sut, getCodeSpy, formSessionKeySpy, bindPublicKeySpy)
    }
}

extension FetcherSpy
where Payload == Void {
    
    func fetch(completion: @escaping FetchCompletion) {
        
        fetch((), completion: completion)
    }
}
