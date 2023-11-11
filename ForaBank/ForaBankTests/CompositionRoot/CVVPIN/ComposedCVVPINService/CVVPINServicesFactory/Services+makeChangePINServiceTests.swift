//
//  Services+makeChangePINServiceTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.11.2023.
//

import CVVPIN_Services
@testable import ForaBank
import XCTest

final class Services_makeChangePINServiceTests: XCTestCase {
    
    // MARK: - Helpers
    
    private typealias SUT = ChangePINService
    private typealias AuthSpy = FetcherSpy<Void, SessionID, Services.AuthError>
    private typealias LoadSessionSpy = FetcherSpy<Void, Services.ChangePINSession, Error>
    private typealias ChangePINRemoteSpy = FetcherSpy<(SessionID, Data), Void, MappingRemoteServiceError<ChangePINService.ChangePINAPIError>>
    private typealias ConfirmRemoteSpy = FetcherSpy<SessionID, ChangePINService.EncryptedConfirmResponse, MappingRemoteServiceError<ChangePINService.ConfirmAPIError>>
    private typealias TransportKey = LiveExtraLoggingCVVPINCrypto.TransportKey
    private typealias ProcessingKey = LiveExtraLoggingCVVPINCrypto.ProcessingKey

    private func makeSUT(
        transportKeyResult: Result<TransportKey, Error> = anyTransportKeyResult(),
        processingKeyResult: Result<ProcessingKey, Error> = anyProcessingKeyResult(),
        publicRSAKeyDecryptResult: Result<String, Error> = .success("abc1234"),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        authSpy: AuthSpy,
        loadSessionSpy: LoadSessionSpy,
        changePINRemoteSpy: ChangePINRemoteSpy,
        confirmRemoteSpy: ConfirmRemoteSpy
    ) {
        let authSpy = AuthSpy()
        let loadSessionSpy = LoadSessionSpy()
        let changePINRemoteSpy = ChangePINRemoteSpy()
        let confirmRemoteSpy = ConfirmRemoteSpy()

        let cvvPINCrypto = LiveExtraLoggingCVVPINCrypto(
            transportKey: transportKeyResult.get,
            processingKey: processingKeyResult.get,
            log: { _,_,_ in }
        )
        let cvvPINJSONMaker = LiveCVVPINJSONMaker(crypto: cvvPINCrypto)

        let sut = Services.makeChangePINService(
            auth: authSpy.fetch(completion:),
            loadSession: loadSessionSpy.fetch(completion:),
            changePINRemoteService: changePINRemoteSpy,
            confirmChangePINRemoteService: confirmRemoteSpy,
            publicRSAKeyDecrypt: { _, completion in
                
                completion(.init { try publicRSAKeyDecryptResult.get() })
            },
            cvvPINJSONMaker: cvvPINJSONMaker
        )

        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(authSpy, file: file, line: line)
        trackForMemoryLeaks(loadSessionSpy, file: file, line: line)
        trackForMemoryLeaks(changePINRemoteSpy, file: file, line: line)
        trackForMemoryLeaks(confirmRemoteSpy, file: file, line: line)
        
        return (sut, authSpy, loadSessionSpy, changePINRemoteSpy, confirmRemoteSpy)
    }
}
