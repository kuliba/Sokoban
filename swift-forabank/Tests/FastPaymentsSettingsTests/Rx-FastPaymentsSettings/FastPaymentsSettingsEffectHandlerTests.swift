//
//  FastPaymentsSettingsEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 15.01.2024.
//

import FastPaymentsSettings
import RxViewModel
import XCTest

extension FastPaymentsSettingsEffectHandler: EffectHandler {}

final class FastPaymentsSettingsEffectHandlerTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_, changeConsentListSpy, getSettingsSpy, updateContractSpy, prepareSetBankDefaultSpy, createContractSpy, updateProductSpy) = makeSUT()
        
        XCTAssertNoDiff(changeConsentListSpy.callCount, 0)
        XCTAssertNoDiff(getSettingsSpy.callCount, 0)
        XCTAssertNoDiff(updateContractSpy.callCount, 0)
        XCTAssertNoDiff(prepareSetBankDefaultSpy.callCount, 0)
        XCTAssertNoDiff(createContractSpy.callCount, 0)
        XCTAssertNoDiff(updateProductSpy.callCount, 0)
    }
    
    // MARK: - activateContract
    
    func test_activateContract_shouldPassPayload() {
        
        let payload = fastPaymentsSettingsEffectTargetContract()
        let (sut, _,_, updateContractSpy, _,_,_) = makeSUT()
        
        sut.handleEffect(activateContract(payload)) { _ in }
        
        XCTAssertNoDiff(updateContractSpy.payloads, [payload])
    }
    
    func test_activateContract_shouldDeliverContractUpdateSuccessOnSuccess() {
        
        let targetContract = fastPaymentsSettingsEffectTargetContract()
        let activatedContract = paymentContract(contractStatus: .active)
        let (sut, _,_, updateContractSpy, _,_,_) = makeSUT()
        
        expect(sut, with: activateContract(targetContract), toDeliver: updateContractSuccess(activatedContract), on: {
            
            updateContractSpy.complete(with: .success(activatedContract))
        })
    }
    
    func test_activateContract_shouldDeliverContractUpdateConnectivityFailureOnConnectivityError() {
        
        let targetContract = fastPaymentsSettingsEffectTargetContract()
        let (sut, _,_, updateContractSpy, _,_,_) = makeSUT()
        
        expect(sut, with: activateContract(targetContract), toDeliver: updateContractConnectivityError(), on: {
            
            updateContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_activateContract_shouldDeliverContractUpdateServerErrorFailureOnServerError() {
        
        let targetContract = fastPaymentsSettingsEffectTargetContract()
        let message = UUID().uuidString
        let (sut, _,_, updateContractSpy, _,_,_) = makeSUT()
        
        expect(sut, with: activateContract(targetContract), toDeliver: updateContractServerError(message), on: {
            
            updateContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - createContract
    
    func test_createContract_shouldPassPayload() {
        
        let product = makeProduct()
        let (sut, _, _, _, _, createContractSpy, _) = makeSUT()
        
        sut.handleEffect(createContract(product)) { _ in }
        
        XCTAssertNoDiff(createContractSpy.payloads, [product])
    }
    
    func test_createContract_shouldDeliverContractOnSuccess() {
        
        let product = makeProduct()
        let activatedContract = paymentContract(contractStatus: .active)
        let (sut, _, _, _, _, createContractSpy, _) = makeSUT()
        
        expect(sut, with: createContract(product), toDeliver: updateContractSuccess(activatedContract), on: {
            
            createContractSpy.complete(with: .success(activatedContract))
        })
    }
    
    func test_createContract_shouldDeliverContractUpdateConnectivityFailureOnConnectivityError() {
        
        let product = makeProduct()
        let (sut, _, _, _, _, createContractSpy, _) = makeSUT()
        
        expect(sut, with: createContract(product), toDeliver: updateContractConnectivityError(), on: {
            
            createContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_createContract_shouldDeliverContractUpdateServerErrorFailureOnServerError() {
        
        let product = makeProduct()
        let message = UUID().uuidString
        let (sut, _, _, _, _, createContractSpy, _) = makeSUT()
        
        expect(sut, with: createContract(product), toDeliver: updateContractServerError(message), on: {
            
            createContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - deactivateContract
    
    func test_deactivateContract_shouldPassPayload() {
        
        let payload = fastPaymentsSettingsEffectTargetContract()
        let (sut, _,_, updateContractSpy, _,_,_) = makeSUT()
        
        sut.handleEffect(deactivateContract(payload)) { _ in }
        
        XCTAssertNoDiff(updateContractSpy.payloads, [payload])
    }
    
    func test_deactivateContract_shouldDeliverContractUpdateSuccessOnSuccess() {
        
        let targetContract = fastPaymentsSettingsEffectTargetContract()
        let activatedContract = paymentContract(contractStatus: .active)
        let (sut, _,_, updateContractSpy, _,_,_) = makeSUT()
        
        expect(sut, with: deactivateContract(targetContract), toDeliver: updateContractSuccess(activatedContract), on: {
            
            updateContractSpy.complete(with: .success(activatedContract))
        })
    }
    
    func test_deactivateContract_shouldDeliverContractUpdateConnectivityFailureOnConnectivityError() {
        
        let targetContract = fastPaymentsSettingsEffectTargetContract()
        let (sut, _,_, updateContractSpy, _,_,_) = makeSUT()
        
        expect(sut, with: deactivateContract(targetContract), toDeliver: updateContractConnectivityError(), on: {
            
            updateContractSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_deactivateContract_shouldDeliverContractUpdateServerErrorFailureOnServerError() {
        
        let targetContract = fastPaymentsSettingsEffectTargetContract()
        let message = UUID().uuidString
        let (sut, _,_, updateContractSpy, _,_,_) = makeSUT()
        
        expect(sut, with: deactivateContract(targetContract), toDeliver: updateContractServerError(message), on: {
            
            updateContractSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - getSettings
    
    func test_getSettings_shouldDeliverLoadedContractedOnContracted() {
        
        let contracted = contractedSettings()
        let (sut, _, getSettingsSpy, _,_,_,_) = makeSUT()
        
        expect(sut, with: .getSettings, toDeliver: .loadSettings(contracted), on: {
            
            getSettingsSpy.complete(with: contracted)
        })
    }
    
    func test_getSettings_shouldDeliverLoadedMissingSuccessOnMissingSuccess() {
        
        let missingSuccess = missingConsentSuccessSettings()
        let (sut, _, getSettingsSpy, _,_,_,_) = makeSUT()
        
        expect(sut, with: .getSettings, toDeliver: .loadSettings(missingSuccess), on: {
            
            getSettingsSpy.complete(with: missingSuccess)
        })
    }
    
    func test_getSettings_shouldDeliverLoadedMissingFailureOnMissingFailure() {
        
        let missingFailure = missingConsentFailureSettings()
        let (sut, _, getSettingsSpy, _,_,_,_) = makeSUT()
        
        expect(sut, with: .getSettings, toDeliver: .loadSettings(missingFailure), on: {
            
            getSettingsSpy.complete(with: missingFailure)
        })
    }
    
    func test_getSettings_shouldDeliverLoadedConnectivityErrorOnConnectivityErrorFailure() {
        
        let failure: UserPaymentSettingsResult = .failure(.connectivityError)
        let (sut, _, getSettingsSpy, _,_,_,_) = makeSUT()
        
        expect(sut, with: .getSettings, toDeliver: .loadSettings(failure), on: {
            
            getSettingsSpy.complete(with: failure)
        })
    }
    
    func test_getSettings_shouldDeliverLoadedServerErrorOnServerErrorFailure() {
        
        let failure = serverErrorSettings()
        let (sut, _, getSettingsSpy, _,_,_,_) = makeSUT()
        
        expect(sut, with: .getSettings, toDeliver: .loadSettings(failure), on: {
            
            getSettingsSpy.complete(with: failure)
        })
    }
    
    // MARK: - prepareSetBankDefault
    
    func test_prepareSetBankDefault_shouldDeliverSetBankDefaultSuccessFailureOnSuccess() {
        
        let (sut, _,_,_, prepareSetBankDefaultSpy, _,_) = makeSUT()
        
        expect(sut, with: .prepareSetBankDefault, toDeliver: setBankDefaultSuccess(), on: {
            
            prepareSetBankDefaultSpy.complete(with: .success(()))
        })
    }
    
    func test_prepareSetBankDefault_shouldDeliverSetBankDefaultIncorrectOTPOnServerErrorWithMessage() {
        
        let tryAgain = "Введен некорректный код. Попробуйте еще раз"
        let (sut, _,_,_, prepareSetBankDefaultSpy, _,_) = makeSUT()
        
        expect(sut, with: .prepareSetBankDefault, toDeliver: setBankDefaultIncorrectOTP(), on: {
            
            prepareSetBankDefaultSpy.complete(with: .failure(.serverError(tryAgain)))
        })
    }
    
    func test_prepareSetBankDefault_shouldDeliverSetBankDefaultConnectivityFailureOnConnectivityError() {
        
        let (sut, _,_,_, prepareSetBankDefaultSpy, _,_) = makeSUT()
        
        expect(sut, with: .prepareSetBankDefault, toDeliver: setBankDefaultConnectivityError(), on: {
            
            prepareSetBankDefaultSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_prepareSetBankDefault_shouldDeliverSetBankDefaultServerErrorFailureOnServerError() {
        
        let message = UUID().uuidString
        let (sut, _,_,_, prepareSetBankDefaultSpy, _,_) = makeSUT()
        
        expect(sut, with: .prepareSetBankDefault, toDeliver: setBankDefaultServerError(message), on: {
            
            prepareSetBankDefaultSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - updateProduct
    
    func test_updateProduct_shouldPassPayload() {
        
        let payload = updateProductPayload()
        let (sut, _,_,_,_,_, updateProductSpy) = makeSUT()
        
        sut.handleEffect(.updateProduct(payload)) { _ in }
        
        XCTAssertNoDiff(updateProductSpy.payloads, [payload])
    }
    
    func test_updateProduct_shouldDeliverUpdateProductOnSuccess() {
        
        let product = makeProduct()
        let payload = updateProductPayload(product: product)
        let (sut, _,_,_,_,_, updateProductSpy) = makeSUT()
        
        expect(sut, with: .updateProduct(payload), toDeliver: updateProductSuccess(product), on: {
            
            updateProductSpy.complete(with: .success(()))
        })
    }
    
    func test_updateProduct_shouldDeliverUpdateProductConnectivityFailureOnConnectivityError() {
        
        let payload = updateProductPayload()
        let (sut, _,_,_,_,_, updateProductSpy) = makeSUT()
        
        expect(sut, with: .updateProduct(payload), toDeliver: updateProductConnectivityError(), on: {
            
            updateProductSpy.complete(with: .failure(.connectivityError))
        })
    }
    
    func test_updateProduct_shouldDeliverUpdateProductServerErrorFailureOnServerError() {
        
        let payload = updateProductPayload()
        let message = UUID().uuidString
        let (sut, _,_,_,_,_, updateProductSpy) = makeSUT()
        
        expect(sut, with: .updateProduct(payload), toDeliver: updateProductServerError(message), on: {
            
            updateProductSpy.complete(with: .failure(.serverError(message)))
        })
    }
    
    // MARK: - Helpers
    
    private typealias SUT = FastPaymentsSettingsEffectHandler
    private typealias State = SUT.State
    private typealias Event = SUT.Event
    private typealias Effect = SUT.Effect
    
    private typealias ChangeConsentListSpy = Spy<ConsentListRxEffectHandler.ChangeConsentListPayload, ConsentListRxEffectHandler.ChangeConsentListResponse>
    private typealias GetC2BSubSpy = Spy<Void, SUT.GetC2BSubResult>
    private typealias GetSettingsSpy = Spy<Void, UserPaymentSettingsResult>
    private typealias UpdateContractSpy = Spy<ContractEffectHandler.UpdateContractPayload, ContractEffectHandler.UpdateContractResult>
    private typealias PrepareSetBankDefaultSpy = Spy<Void, SUT.PrepareSetBankDefaultResponse>
    private typealias CreateContractSpy = Spy<ContractEffectHandler.CreateContractPayload, ContractEffectHandler.CreateContractResult>
    private typealias UpdateProductSpy = Spy<SUT.UpdateProductPayload, SUT.UpdateProductResponse>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        changeConsentListSpy: ChangeConsentListSpy,
        getSettingsSpy: GetSettingsSpy,
        updateContractSpy: UpdateContractSpy,
        prepareSetBankDefaultSpy: PrepareSetBankDefaultSpy,
        createContractSpy: CreateContractSpy,
        updateProductSpy: UpdateProductSpy
    ) {
        let changeConsentListSpy = ChangeConsentListSpy()
        let getC2BSubSpy = GetC2BSubSpy()
        let getSettingsSpy = GetSettingsSpy()
        let updateContractSpy = UpdateContractSpy()
        let prepareSetBankDefaultSpy = PrepareSetBankDefaultSpy()
        let createContractSpy = CreateContractSpy()
        let updateProductSpy = UpdateProductSpy()
        
        let consentListEffectHandler = ConsentListRxEffectHandler(
            changeConsentList: changeConsentListSpy.process(_:completion:)
        )
        let contractEffectHandler = ContractEffectHandler(
            createContract: createContractSpy.process(_:completion:),
            updateContract: updateContractSpy.process(_:completion:)
        )
        let sut = SUT(
            handleConsentListEffect: consentListEffectHandler.handleEffect(_:_:),
            handleContractEffect: contractEffectHandler.handleEffect(_:_:), 
            getC2BSub: getC2BSubSpy.process(completion:),
            getSettings: getSettingsSpy.process(completion:),
            prepareSetBankDefault: prepareSetBankDefaultSpy.process(completion:),
            updateProduct: updateProductSpy.process(_:completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(changeConsentListSpy, file: file, line: line)
        #warning("use `getC2BSubSpy` in tests")
        trackForMemoryLeaks(getC2BSubSpy, file: file, line: line)
        trackForMemoryLeaks(getSettingsSpy, file: file, line: line)
        trackForMemoryLeaks(updateContractSpy, file: file, line: line)
        trackForMemoryLeaks(prepareSetBankDefaultSpy, file: file, line: line)
        trackForMemoryLeaks(createContractSpy, file: file, line: line)
        trackForMemoryLeaks(updateProductSpy, file: file, line: line)
        
        return (sut, changeConsentListSpy, getSettingsSpy, updateContractSpy, prepareSetBankDefaultSpy, createContractSpy, updateProductSpy)
    }
}
