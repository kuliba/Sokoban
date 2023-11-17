//
//  CvvPinServiceTests.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

import CryptoKit
@testable import CvvPin
import XCTest

final class CvvPinServiceInternalTests: CvvPinServiceTestHelpers {
    
    // MARK: - exchangeKey - internal
    
    func test_exchangeKey_shouldDeliverErrorOnSessionCodeError() {
        
        let sessionCodeError = anyNSError(domain: "session code error")
        let (sut, sessionCodeSpy, _, _) = makeSUT()
        
        expect(
            sut,
            toExchangeKeyWith: [.failure(sessionCodeError)],
            on: {
                sessionCodeSpy.complete(with: .failure(sessionCodeError))
            }
        )
    }
    
    func test_exchangeKey_shouldDeliverErrorOnKeyExchangeError() {
        
        let keyExchangeError = anyNSError(domain: "key exchange error")
        let (sut, sessionCodeSpy, keyExchangeSpy, _) = makeSUT()
        
        expect(
            sut,
            toExchangeKeyWith: [.failure(keyExchangeError)],
            on: {
                sessionCodeSpy.complete(with: .success(uniqueSessionCode()))
                keyExchangeSpy.complete(with: .failure(keyExchangeError))
            }
        )
    }
    
    func test_exchangeKey_shouldDeliverKeyExchangeOnSuccess() {
        
        let keyExchange = uniqueKeyExchange()
        let (sut, sessionCodeSpy, keyExchangeSpy, _) = makeSUT()
        
        expect(sut, toExchangeKeyWith: [.success(keyExchange)]) {
            
            sessionCodeSpy.complete(with: .success(uniqueSessionCode()))
            keyExchangeSpy.complete(with: .success(keyExchange))
        }
    }
    
    func test_exchangeKey_shouldNotReceiveSessionCodeResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeSpy = SessionCodeLoaderSpy()
        let keyExchangeSpy = KeyExchangeServiceSpy()
        let transferKeySpy = TransferKeySpy()
        var sut: CvvPinService? = .init(
            getProcessingSessionCode: sessionCodeSpy.load,
            exchangeKey: keyExchangeSpy.exchangeKey,
            transferPublicKey: transferKeySpy.bind
        )
        var exchangeKeyResults = [KeyExchangeDomain.Result]()
        
        sut?.exchangeKey { exchangeKeyResults.append($0) }
        sut = nil
        sessionCodeSpy.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(exchangeKeyResults.isEmpty)
    }
    
    func test_exchangeKey_shouldNotReceiveSymmetricKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeSpy = SessionCodeLoaderSpy()
        let keyExchangeSpy = KeyExchangeServiceSpy()
        let transferKeySpy = TransferKeySpy()
        var sut: CvvPinService? = .init(
            getProcessingSessionCode: sessionCodeSpy.load,
            exchangeKey: keyExchangeSpy.exchangeKey,
            transferPublicKey: transferKeySpy.bind
        )
        var exchangeKeyResults = [KeyExchangeDomain.Result]()
        
        sut?.exchangeKey { exchangeKeyResults.append($0) }
        sessionCodeSpy.complete(with: .success(uniqueSessionCode()))
        sut = nil
        keyExchangeSpy.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(exchangeKeyResults.isEmpty)
    }
    
    // MARK: - confirmExchange - internal
    
    func test_confirmExchange_shouldDeliverErrorOnTransferKeyError() {
        
        let transferKeyError = anyNSError(domain: "key transfer error")
        let (sut, _, _, transferKeySpy) = makeSUT()
        
        expect(
            sut,
            toConfirmExchangeWith: [.failure(transferKeyError)],
            on: {
                transferKeySpy.complete(with: .failure(transferKeyError))
            }
        )
    }
    
    func test_confirmExchange_shouldDeliverVoidOnTransferKeySuccess() {
        
        let (sut, _, _, transferKeySpy) = makeSUT()
        
        expect(
            sut,
            toConfirmExchangeWith: [.success(uniqueKeyExchange())],
            on: {
                transferKeySpy.complete(with: .success(()))
            }
        )
    }
    
    func test_confirmExchange_shouldNotReceiveTransferKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeSpy = SessionCodeLoaderSpy()
        let keyExchangeSpy = KeyExchangeServiceSpy()
        let transferKeySpy = TransferKeySpy()
        var sut: CvvPinService? = .init(
            getProcessingSessionCode: sessionCodeSpy.load,
            exchangeKey: keyExchangeSpy.exchangeKey,
            transferPublicKey: transferKeySpy.bind
        )
        var confirmExchangeResults = [CvvPinService.ConfirmExchangeResult]()
        
        sut?.confirmExchange(
            withOTP: uniqueOTP(),
            keyExchange: uniqueKeyExchange()
        ) {
            confirmExchangeResults.append($0)
        }
        sut = nil
        transferKeySpy.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(confirmExchangeResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func expect(
        _ sut: CvvPinService,
        toExchangeKeyWith expectedResults: [KeyExchangeDomain.Result],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var exchangeKeyResults = [KeyExchangeDomain.Result]()
        let exp = expectation(description: "wait for key exchange")
        
        sut.exchangeKey {
            exchangeKeyResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(exchangeKeyResults.count, expectedResults.count, "Expected \(expectedResults.count) results, got \(exchangeKeyResults.count) instead.", file: file, line: line)
        
        zip(exchangeKeyResults, expectedResults).enumerated().forEach { index, element in
            
            switch element {
            case let (.failure(received as NSError?), .failure(expected as NSError?)):
                XCTAssertNoDiff(received, expected, file: file, line: line)
                
            case let (.success(received), .success(expected)):
                XCTAssertNoDiff(received, expected, file: file, line: line)
                
            default:
                XCTFail("Expected \(element.1), got \(element.0) instead.", file: file, line: line)
            }
        }
    }
    
    private func expect(
        _ sut: CvvPinService,
        toConfirmExchangeWith expectedResults: [KeyExchangeDomain.Result],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var exchangeKeyResults = [CvvPinService.ConfirmExchangeResult]()
        let exp = expectation(description: "wait for key exchange")
        
        sut.confirmExchange(
            withOTP: uniqueOTP(),
            keyExchange: uniqueKeyExchange()
        ) {
            exchangeKeyResults.append($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertNoDiff(exchangeKeyResults.count, expectedResults.count, "Expected \(expectedResults.count) results, got \(exchangeKeyResults.count) instead.", file: file, line: line)
        
        zip(exchangeKeyResults, expectedResults).enumerated().forEach { index, element in
            
            switch element {
            case let (.failure(received as NSError?), .failure(expected as NSError?)):
                XCTAssertNoDiff(received, expected, file: file, line: line)
                
            case (.success(()), .success):
                break
                
            default:
                XCTFail("Expected \(element.1), got \(element.0) instead.", file: file, line: line)
            }
        }
    }
}
