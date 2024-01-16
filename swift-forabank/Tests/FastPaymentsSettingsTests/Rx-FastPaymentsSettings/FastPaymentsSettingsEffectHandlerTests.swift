//
//  FastPaymentsSettingsEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import XCTest

final class FastPaymentsSettingsEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, getSettingsSpy, updateContractSpy, prepareSetBankDefaultSpy, createContractSpy, updateProductSpy) = makeSUT()
        
        XCTAssertNoDiff(getSettingsSpy.callCount, 0)
        XCTAssertNoDiff(updateContractSpy.callCount, 0)
        XCTAssertNoDiff(prepareSetBankDefaultSpy.callCount, 0)
        XCTAssertNoDiff(createContractSpy.callCount, 0)
        XCTAssertNoDiff(updateProductSpy.callCount, 0)
    }
    
    // MARK: - activateContract
    
    func test_activateContract_shouldPassPayload() {
        
        let payload = anyFastPaymentsSettingsEffectTargetContract()
        let (sut, _, updateContractSpy, _,_,_) = makeSUT()
        
        sut.handleEffect(.activateContract(payload)) { _ in }
        
        XCTAssertNoDiff(updateContractSpy.payloads, [payload])
    }
    
    func test_activateContract_shouldDeliverContractUpdateSuccessOnSuccess() {
        
        let targetContract = anyFastPaymentsSettingsEffectTargetContract()
        let activatedContract = anyActivePaymentContract()
        let (sut, _, updateContractSpy, _,_,_) = makeSUT()
        
        expect(sut, with: .activateContract(targetContract), toDeliver: .contractUpdate(.success(activatedContract)), on: {
            
            updateContractSpy.complete(with: .success(activatedContract))
        })
    }
    
    func test_activateContract_shouldDeliverContractUpdateConnectivityFailureOnConnectivityError() {
        
        let targetContract = anyFastPaymentsSettingsEffectTargetContract()
        let (sut, _, updateContractSpy, _,_,_) = makeSUT()
        
        expect(sut, with: .activateContract(targetContract), toDeliver: .contractUpdate(.failure(.connectivityError)), on: {
            
            updateContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_activateContract_shouldDeliverContractUpdateServerErrorFailureOnServerError() {
        
        let targetContract = anyFastPaymentsSettingsEffectTargetContract()
        let message = UUID().uuidString
        let (sut, _, updateContractSpy, _,_,_) = makeSUT()
        
        expect(sut, with: .activateContract(targetContract), toDeliver: .contractUpdate(.failure(.serverError(message))), on: {
            
            updateContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - createContract
    
    func test_createContract_shouldPassPayload() {
        
        let productID = anyEffectProductID()
        let (sut, _,_,_, createContractSpy, _) = makeSUT()
        
        sut.handleEffect(.createContract(productID)) { _ in }
        
        XCTAssertNoDiff(createContractSpy.payloads, [productID])
    }
    
    func test_createContract_shouldDeliverContractOnSuccess() {
        
        let productID = anyEffectProductID()
        let activatedContract = anyActivePaymentContract()
        let (sut, _,_,_, createContractSpy, _) = makeSUT()
        
        expect(sut, with: .createContract(productID), toDeliver: .contractUpdate(.success(activatedContract)), on: {
            
            createContractSpy.complete(with: .success(activatedContract))
        })
    }
    
    func test_createContract_shouldDeliverContractUpdateConnectivityFailureOnConnectivityError() {
        
        let productID = anyEffectProductID()
        let (sut, _,_,_, createContractSpy, _) = makeSUT()
        
        expect(sut, with: .createContract(productID), toDeliver: .contractUpdate(.failure(.connectivityError)), on: {
            
            createContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_createContract_shouldDeliverContractUpdateServerErrorFailureOnServerError() {
        
        let productID = anyEffectProductID()
        let message = UUID().uuidString
        let (sut, _,_,_, createContractSpy, _) = makeSUT()
        
        expect(sut, with: .createContract(productID), toDeliver: .contractUpdate(.failure(.serverError(message))), on: {
            
            createContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - getSettings
    
    func test_getSettings_shouldDeliverLoadedContractedOnContracted() {
        
        let contracted = anyContractedSettings()
        let (sut, getSettingsSpy, _,_,_,_) = makeSUT()
        
        expect(sut, with: .getSettings, toDeliver: .loadedSettings(contracted), on: {
            
            getSettingsSpy.complete(with: contracted)
        })
    }
    
    func test_getSettings_shouldDeliverLoadedMissingSuccessOnMissingSuccess() {
        
        let missingSuccess = anyMissingSuccessSettings()
        let (sut, getSettingsSpy, _,_,_,_) = makeSUT()
        
        expect(sut, with: .getSettings, toDeliver: .loadedSettings(missingSuccess), on: {
            
            getSettingsSpy.complete(with: missingSuccess)
        })
    }
    
    func test_getSettings_shouldDeliverLoadedMissingFailureOnMissingFailure() {
        
        let missingFailure = anyMissingFailureSettings()
        let (sut, getSettingsSpy, _,_,_,_) = makeSUT()
        
        expect(sut, with: .getSettings, toDeliver: .loadedSettings(missingFailure), on: {
            
            getSettingsSpy.complete(with: missingFailure)
        })
    }
    
    func test_getSettings_shouldDeliverLoadedConnectivityErrorOnConnectivityErrorFailure() {
        
        let failure: UserPaymentSettings = .failure(.connectivityError)
        let (sut, getSettingsSpy, _,_,_,_) = makeSUT()
        
        expect(sut, with: .getSettings, toDeliver: .loadedSettings(failure), on: {
            
            getSettingsSpy.complete(with: failure)
        })
    }
    
    func test_getSettings_shouldDeliverLoadedServerErrorOnServerErrorFailure() {
        
        let failure = anyServerErrorSettings()
        let (sut, getSettingsSpy, _,_,_,_) = makeSUT()
        
        expect(sut, with: .getSettings, toDeliver: .loadedSettings(failure), on: {
            
            getSettingsSpy.complete(with: failure)
        })
    }
    
    // MARK: - prepareSetBankDefault
    
    func test_prepareSetBankDefault_shouldDeliverSetBankDefaultPrepareNilFailureOnSuccess() {
        
        let (sut, _,_, prepareSetBankDefaultSpy, _,_) = makeSUT()
        
        expect(sut, with: .prepareSetBankDefault, toDeliver: .setBankDefaultPrepare(nil), on: {
            
            prepareSetBankDefaultSpy.complete(with: .success(()))
        })
    }
    
    func test_prepareSetBankDefault_shouldDeliverSetBankDefaultPrepareConnectivityFailureOnConnectivityError() {
        
        let (sut, _,_, prepareSetBankDefaultSpy, _,_) = makeSUT()
        
        expect(sut, with: .prepareSetBankDefault, toDeliver: .setBankDefaultPrepare(.connectivityError), on: {
            
            prepareSetBankDefaultSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_prepareSetBankDefault_shouldDeliverSetBankDefaultPrepareServerErrorFailureOnServerError() {
        
        let message = UUID().uuidString
        let (sut, _,_, prepareSetBankDefaultSpy, _,_) = makeSUT()
        
        expect(sut, with: .prepareSetBankDefault, toDeliver: .setBankDefaultPrepare(.serverError(message)), on: {
            
            prepareSetBankDefaultSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - updateProduct
    
    func test_updateProduct_shouldPassPayload() {
        
        let payload = anyUpdateProductPayload()
        let (sut, _,_,_,_, updateProductSpy) = makeSUT()
        
        sut.handleEffect(.updateProduct(payload)) { _ in }
        
        XCTAssertNoDiff(updateProductSpy.payloads, [payload])
    }
    
    func test_updateProduct_shouldDeliverUpdateProductNilFailureOnSuccess() {
        
        let payload = anyUpdateProductPayload()
        let (sut, _,_,_,_, updateProductSpy) = makeSUT()
        
        expect(sut, with: .updateProduct(payload), toDeliver: .productUpdate(nil), on: {
            
            updateProductSpy.complete(with: .success(()))
        })
    }
    
    func test_updateProduct_shouldDeliverUpdateProductConnectivityFailureOnConnectivityError() {
        
        let payload = anyUpdateProductPayload()
        let (sut, _,_,_,_, updateProductSpy) = makeSUT()
        
        expect(sut, with: .updateProduct(payload), toDeliver: .productUpdate(.connectivityError), on: {
            
            updateProductSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_updateProduct_shouldDeliverUpdateProductServerErrorFailureOnServerError() {
        
        let payload = anyUpdateProductPayload()
        let message = UUID().uuidString
        let (sut, _,_,_,_, updateProductSpy) = makeSUT()
        
        expect(sut, with: .updateProduct(payload), toDeliver: .productUpdate(.serverError(message)), on: {
            
            updateProductSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsEffectHandler
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias GetSettingsSpy = Spy<Void, UserPaymentSettings>
    private typealias UpdateContractSpy = Spy<SUT.UpdateContractPayload, SUT.UpdateContractResponse>
    private typealias PrepareSetBankDefaultSpy = Spy<Void, SUT.PrepareSetBankDefaultResponse>
    private typealias CreateContractSpy = Spy<SUT.CreateContractPayload, SUT.CreateContractResponse>
    private typealias UpdateProductSpy = Spy<SUT.UpdateProductPayload, SUT.UpdateProductResponse>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        getSettingsSpy: GetSettingsSpy,
        updateContractSpy: UpdateContractSpy,
        prepareSetBankDefaultSpy: PrepareSetBankDefaultSpy,
        createContractSpy: CreateContractSpy,
        updateProductSpy: UpdateProductSpy
    ) {
        let getSettingsSpy = GetSettingsSpy()
        let updateContractSpy = UpdateContractSpy()
        let prepareSetBankDefaultSpy = PrepareSetBankDefaultSpy()
        let createContractSpy = CreateContractSpy()
        let updateProductSpy = UpdateProductSpy()
        let sut = SUT(
            createContract: createContractSpy.process(_:completion:),
            getSettings: getSettingsSpy.process(completion:),
            prepareSetBankDefault: prepareSetBankDefaultSpy.process(completion:),
            updateContract: updateContractSpy.process(_:completion:),
            updateProduct: updateProductSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(getSettingsSpy, file: file, line: line)
        trackForMemoryLeaks(updateContractSpy, file: file, line: line)
        trackForMemoryLeaks(prepareSetBankDefaultSpy, file: file, line: line)
        trackForMemoryLeaks(createContractSpy, file: file, line: line)
        trackForMemoryLeaks(updateProductSpy, file: file, line: line)
        
        return (sut, getSettingsSpy, updateContractSpy, prepareSetBankDefaultSpy, createContractSpy, updateProductSpy)
    }
    
    private func expect(
        _ sut: SUT,
        with effect: Effect,
        toDeliver expectedEvent: Event,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 0.05,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.handleEffect(effect) {
            
            XCTAssertNoDiff($0, expectedEvent, file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
