//
//  CvvPinServiceTests.swift
//  
//
//  Created by Igor Malyarov on 16.07.2023.
//

import CryptoKit
import CvvPin
import XCTest

final class CvvPinServiceTests: CvvPinServiceTestHelpers {
    
    // MARK: - init
    
    func test_init_shouldNotSendMessagesToGetProcessingSessionCode() {
        
        let sessionCodeSpy = makeSUT().sessionCodeSpy
        
        XCTAssertEqual(sessionCodeSpy.messages, [])
    }
    
    func test_init_shouldNotSendMessagesToExchangeKey() {
        
        let keyExchangeSpy = makeSUT().keyExchangeSpy
        
        XCTAssertEqual(keyExchangeSpy.messages, [])
    }
    
    func test_init_shouldNotSendMessagesToTransferKey() {
        
        let transferKeySpy = makeSUT().transferKeySpy
        
        XCTAssertEqual(transferKeySpy.messages, [])
    }
    
    // MARK: - exchangeKey - public
    
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
    
    func test_exchangeKey_shouldDeliverSuccessOnSuccess() {
        
        let (sut, sessionCodeSpy, keyExchangeSpy, _) = makeSUT()
        let keyExchange = uniqueKeyExchange()
        
        expect(sut, toExchangeKeyWith: [.success(())]) {
            
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
        var exchangeKeyResults = [Result<Void, Error>]()
        
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
        var exchangeKeyResults = [Result<Void, Error>]()
        
        sut?.exchangeKey { exchangeKeyResults.append($0) }
        sessionCodeSpy.complete(with: .success(uniqueSessionCode()))
        sut = nil
        keyExchangeSpy.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(exchangeKeyResults.isEmpty)
    }
    
    // MARK: - confirmExchange - public
    
    func test_confirmExchange_shouldDeliverExchangeStateErrorOnMissingExchangeKey() {
        
        let (sut, _, _, _) = makeSUT()
        
        expect(sut, toConfirmExchangeWith: [
            .failure(CvvPinService.ExchangeStateError())
        ], on: {})
    }
    
    func test_confirmExchange_shouldDeliverErrorOnTransferKeyError() {
        
        let transferKeyError = anyNSError(domain: "key transfer error")
        let (sut, sessionCodeSpy, keyExchangeSpy, transferKeySpy) = makeSUT()
        
        expect(sut, toExchangeKeyWith: [.success(())]) {
            
            sessionCodeSpy.complete(with: .success(uniqueSessionCode()))
            keyExchangeSpy.complete(with: .success(uniqueKeyExchange()))
        }
        
        expect(
            sut,
            toConfirmExchangeWith: [.failure(transferKeyError)],
            on: {
                transferKeySpy.complete(with: .failure(transferKeyError))
            }
        )
    }
    
    func test_confirmExchange_shouldDeliverVoidOnBindPublicKeySuccess() {
        
        let (sut, sessionCodeSpy, keyExchangeSpy, transferKeySpy) = makeSUT()
        
        expect(sut, toExchangeKeyWith: [.success(())]) {
            
            sessionCodeSpy.complete(with: .success(uniqueSessionCode()))
            keyExchangeSpy.complete(with: .success(uniqueKeyExchange()))
        }
        
        expect(sut, toConfirmExchangeWith: [
            .success(uniqueKeyExchange())
        ]) {
            transferKeySpy.complete(with: .success(()))
        }
    }
    
    func test_confirmExchange_shouldNotReceiveBindPublicKeyResultAfterSUTInstanceHasBeenDeallocated() {
        
        let sessionCodeSpy = SessionCodeLoaderSpy()
        let keyExchangeSpy = KeyExchangeServiceSpy()
        let transferKeySpy = TransferKeySpy()
        var sut: CvvPinService? = .init(
            getProcessingSessionCode: sessionCodeSpy.load,
            exchangeKey: keyExchangeSpy.exchangeKey,
            transferPublicKey: transferKeySpy.bind
        )
        var confirmExchangeResults = [CvvPinService.ConfirmExchangeResult]()
        sut?.exchangeKey { (_: Result<Void, Error>) in }
        sessionCodeSpy.complete(with: .success(uniqueSessionCode()))
        keyExchangeSpy.complete(with: .success(uniqueKeyExchange()))
        
        
        sut?.confirmExchange(withOTP: uniqueOTP()) {
            confirmExchangeResults.append($0)
        }
        sut = nil
        transferKeySpy.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(confirmExchangeResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func expect(
        _ sut: CvvPinService,
        toExchangeKeyWith expectedResults: [Result<Void, Error>],
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var exchangeKeyResults = [Result<Void, Error>]()
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
                
            case (.success, .success):
                break
                
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
        
        sut.confirmExchange(withOTP: uniqueOTP()) {
            
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
