//
//  FastPaymentsSettingsIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 17.01.2024.
//

import FastPaymentsSettings
import RxViewModel
import XCTest

final class FastPaymentsSettingsIntegrationTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborators() {
        
        let (_,_, getSettingsSpy, updateContractSpy, prepareSetBankDefaultSpy, createContractSpy, updateProductSpy) = makeSUT()
        
        XCTAssertEqual(getSettingsSpy.callCount, 0)
        XCTAssertEqual(updateContractSpy.callCount, 0)
        XCTAssertEqual(prepareSetBankDefaultSpy.callCount, 0)
        XCTAssertEqual(createContractSpy.callCount, 0)
        XCTAssertEqual(updateProductSpy.callCount, 0)
    }
    
    func test_flow_abc1d1_deactivationSuccessOfLoadedActiveContract() {
        
        let details = contractedState(.active).details
        let newContract = paymentContract(contractStatus: .inactive)
        let (sut, stateSpy, getSettingsSpy, updateContractSpy, _,_,_) = makeSUT()
        
        sut.event(.appear)
        getSettingsSpy.complete(with: .contracted(details))
        
        sut.event(deactivateContract())
        updateContractSpy.complete(with: .success(newContract))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: .contracted(details)),
            .init(userPaymentSettings: .contracted(details), status: .inflight),
            .init(userPaymentSettings: .contracted(details.updated(
                paymentContract: newContract
            ))),
        ])
        
        XCTAssertNoDiff(stateSpy.values.map(\.settingsStatus), [
            nil,
            nil,
            .active,
            .active,
            .inactive,
        ])
    }
    
    func test_flow_abc1d2_deactivationFailureOfLoadedActiveContract() {
        
        let details = contractedState(.active).details
        let message = anyMessage()
        let (sut, stateSpy, getSettingsSpy, updateContractSpy, _,_,_) = makeSUT()
        
        sut.event(.appear)
        getSettingsSpy.complete(with: .contracted(details))
        
        sut.event(deactivateContract())
        updateContractSpy.complete(with: .failure(.serverError(message)))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: .contracted(details)),
            .init(userPaymentSettings: .contracted(details), status: .inflight),
            .init(userPaymentSettings: .contracted(details), status: .serverError(message)),
        ])
        
        XCTAssertNoDiff(stateSpy.values.map(\.settingsStatus), [
            nil,
            nil,
            .active,
            .active,
            .active,
        ])
    }
    
    func test_flow_abc1d3_deactivationFailureOfLoadedActiveContract() {
        
        let details = contractedState(.active).details
        let (sut, stateSpy, getSettingsSpy, updateContractSpy, _,_,_) = makeSUT()
        
        sut.event(.appear)
        getSettingsSpy.complete(with: .contracted(details))
        
        sut.event(deactivateContract())
        updateContractSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: .contracted(details)),
            .init(userPaymentSettings: .contracted(details), status: .inflight),
            .init(userPaymentSettings: .contracted(details), status: .connectivityError),
        ])
        
        XCTAssertNoDiff(stateSpy.values.map(\.settingsStatus), [
            nil,
            nil,
            .active,
            .active,
            .active,
        ])
    }
    
    func test_flow_abc2d1_activationSuccessOfLoadedInactiveContract() {
        
        let details = contractedState(.inactive).details
        let newContract = paymentContract(contractStatus: .active)
        let (sut, stateSpy, getSettingsSpy, updateContractSpy, _,_,_) = makeSUT()
        
        sut.event(.appear)
        getSettingsSpy.complete(with: .contracted(details))
        
        sut.event(activateContract())
        updateContractSpy.complete(with: .success(newContract))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: .contracted(details)),
            .init(userPaymentSettings: .contracted(details), status: .inflight),
            .init(userPaymentSettings: .contracted(details.updated(
                paymentContract: newContract
            ))),
        ])
        
        XCTAssertNoDiff(stateSpy.values.map(\.settingsStatus), [
            nil,
            nil,
            .inactive,
            .inactive,
            .active,
        ])
    }
    
    func test_flow_abc2d2_activationFailureOfLoadedInactiveContract() {
        
        let details = contractedState(.inactive).details
        let message = anyMessage()
        let (sut, stateSpy, getSettingsSpy, updateContractSpy, _,_,_) = makeSUT()
        
        sut.event(.appear)
        getSettingsSpy.complete(with: .contracted(details))
        
        sut.event(activateContract())
        updateContractSpy.complete(with: .failure(.serverError(message)))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: .contracted(details)),
            .init(userPaymentSettings: .contracted(details), status: .inflight),
            .init(userPaymentSettings: .contracted(details), status: .serverError(message)),
        ])
        
        XCTAssertNoDiff(stateSpy.values.map(\.settingsStatus), [
            nil,
            nil,
            .inactive,
            .inactive,
            .inactive,
        ])
    }
    
    func test_flow_abc2d3_activationFailureOfLoadedInactiveContract() {
        
        let details = contractedState(.inactive).details
        let (sut, stateSpy, getSettingsSpy, updateContractSpy, _,_,_) = makeSUT()
        
        sut.event(.appear)
        getSettingsSpy.complete(with: .contracted(details))
        
        sut.event(activateContract())
        updateContractSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: .contracted(details)),
            .init(userPaymentSettings: .contracted(details), status: .inflight),
            .init(userPaymentSettings: .contracted(details), status: .connectivityError),
        ])
        
        XCTAssertNoDiff(stateSpy.values.map(\.settingsStatus), [
            nil,
            nil,
            .inactive,
            .inactive,
            .inactive,
        ])
    }
    
    func test_flow_abc3d1_activationSuccessOfLoadedMissingContract() {
        
        let consentResult = consentResultFailure()
        let missing = missingContract(consentResult)
        let (product1, product2) = (makeProduct(), makeProduct())
        let newContract = paymentContract(productID: product2.id)
        let (sut, stateSpy, getSettingsSpy, _,_, createContractSpy, _) = makeSUT(
            products: [product1, product2]
        )
        
        sut.event(.appear)
        getSettingsSpy.complete(with: missing)
        
        sut.event(activateContract())
        createContractSpy.complete(with: .success(newContract))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: missing),
            .init(userPaymentSettings: missing, status: .inflight),
            .init(userPaymentSettings: .contracted(.init(
                paymentContract: newContract,
                consentResult: consentResult,
                bankDefault: .offEnabled,
                productSelector: .init(
                    selectedProduct: product2,
                    products: [product1, product2]
                )
            ))),
        ])
        
        XCTAssertNoDiff(stateSpy.values.map(\.settingsStatus), [
            nil,
            nil,
            .missingContract,
            .missingContract,
            .active,
        ])
    }
    
    func test_flow_abc3d1_activationSuccessOfLoadedMissingContractWithoutProduct() {
        
        let consentResult = consentResultFailure()
        let missing = missingContract(consentResult)
        let (product1, product2) = (makeProduct(), makeProduct())
        let newContract = paymentContract(productID: product2.id)
        let (sut, stateSpy, getSettingsSpy, _,_, createContractSpy, _) = makeSUT(
            products: [product1]
        )
        
        sut.event(.appear)
        getSettingsSpy.complete(with: missing)
        
        sut.event(activateContract())
        createContractSpy.complete(with: .success(newContract))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: missing),
            .init(userPaymentSettings: missing, status: .inflight),
            .init(userPaymentSettings: .contracted(.init(
                paymentContract: newContract,
                consentResult: consentResult,
                bankDefault: .offEnabled,
                productSelector: .init(
                    selectedProduct: nil,
                    products: [product1]
                )
            ))),
        ])
    }
    
    func test_flow_abc3d2_activationFailureOfLoadedMissingContract() {
        
        let consentResult = consentResultSuccess()
        let missing: UserPaymentSettings = .missingContract(consentResult)
        let message = anyMessage()
        let product = makeProduct()
        let (sut, stateSpy, getSettingsSpy, _,_, createContractSpy,_) = makeSUT(
            products: [product]
        )
        
        sut.event(.appear)
        getSettingsSpy.complete(with: missing)
        
        sut.event(activateContract())
        createContractSpy.complete(with: .failure(.serverError(message)))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: missing),
            .init(userPaymentSettings: missing, status: .inflight),
            .init(userPaymentSettings: missing, status: .serverError(message)),
        ])
        
        XCTAssertNoDiff(stateSpy.values.map(\.settingsStatus), [
            nil,
            nil,
            .missingContract,
            .missingContract,
            .missingContract,
        ])
    }
    
    func test_flow_abc3d3_activationFailureOfLoadedMissingContract() {
        
        let consentResult = consentResultSuccess()
        let missing: UserPaymentSettings = .missingContract(consentResult)
        let product = makeProduct()
        let (sut, stateSpy, getSettingsSpy, _,_, createContractSpy,_) = makeSUT(
            products: [product]
        )
        
        sut.event(.appear)
        getSettingsSpy.complete(with: missing)
        
        sut.event(activateContract())
        createContractSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: missing),
            .init(userPaymentSettings: missing, status: .inflight),
            .init(userPaymentSettings: missing, status: .connectivityError),
        ])
        
        XCTAssertNoDiff(stateSpy.values.map(\.settingsStatus), [
            nil,
            nil,
            .missingContract,
            .missingContract,
            .missingContract,
        ])
    }
    
    func test_flow_abc1d1_productChangeSuccessOfLoadedActiveContract() {
        
        let (different, products, details) = makeActive()
        let (sut, stateSpy, getSettingsSpy, _,_,_, updateProductSpy) = makeSUT(products: products)
        
        sut.event(.appear)
        getSettingsSpy.complete(with: .contracted(details))
        
        sut.event(.products(.expandProducts))
        sut.event(.products(.selectProduct(different)))
        updateProductSpy.complete(with: .success(()))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: .contracted(details)),
            .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.updated(
                        status: .expanded
                    )
                ))),
            .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.updated(
                        status: .expanded
                    ))),
                status: .inflight
            ),
            .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.updated(
                        selectedProduct: different,
                        status: .collapsed
                    ))),
                status: nil
            ),
        ])
    }
    
    func test_flow_abc1d2_productChangeServerErrorFailureOfLoadedActiveContract() {
        
        let message = anyMessage()
        let (different, products, details) = makeActive()
        let (sut, stateSpy, getSettingsSpy, _,_,_, updateProductSpy) = makeSUT(products: products)
        
        sut.event(.appear)
        getSettingsSpy.complete(with: .contracted(details))
        
        sut.event(.products(.expandProducts))
        sut.event(.products(.selectProduct(different)))
        updateProductSpy.complete(with: .failure(.serverError(message)))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: .contracted(details)),
            .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.updated(
                        status: .expanded
                    )
                ))),
            .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.updated(
                        status: .expanded
                    ))),
                status: .inflight
            ),
            .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.updated(
                        status: .collapsed
                    ))),
                status: .serverError(message)
            ),
        ])
    }
    
    func test_flow_abc1d3_productChangeConnectivityFailureOfLoadedActiveContract() {
        
        let (different, products, details) = makeActive()
        let (sut, stateSpy, getSettingsSpy, _,_,_, updateProductSpy) = makeSUT(products: products)
        
        sut.event(.appear)
        getSettingsSpy.complete(with: .contracted(details))
        
        sut.event(.products(.expandProducts))
        sut.event(.products(.selectProduct(different)))
        updateProductSpy.complete(with: .failure(.connectivityError))
        
        XCTAssertNoDiff(stateSpy.values, [
            .init(),
            .init(status: .inflight),
            .init(userPaymentSettings: .contracted(details)),
            .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.updated(
                        status: .expanded
                    )
                ))),
            .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.updated(
                        status: .expanded
                    ))),
                status: .inflight
            ),
            .init(
                userPaymentSettings: .contracted(details.updated(
                    productSelector: details.productSelector.updated(
                        status: .collapsed
                    ))),
                status: .connectivityError
            ),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias State = FastPaymentsSettingsState
    private typealias Event = FastPaymentsSettingsEvent
    private typealias Effect = FastPaymentsSettingsEffect
    
    private typealias SUT = RxViewModel<State, Event, Effect>
    private typealias Reducer = FastPaymentsSettingsReducer
    private typealias EffectHandler = FastPaymentsSettingsEffectHandler
    
    private typealias StateSpy = ValueSpy<State>
    
    private typealias GetSettingsSpy = Spy<Void, UserPaymentSettings>
    private typealias UpdateContractSpy = Spy<EffectHandler.UpdateContractPayload, EffectHandler.UpdateContractResponse>
    private typealias PrepareSetBankDefaultSpy = Spy<Void, EffectHandler.PrepareSetBankDefaultResponse>
    private typealias CreateContractSpy = Spy<EffectHandler.CreateContractPayload, EffectHandler.CreateContractResponse>
    private typealias UpdateProductSpy = Spy<EffectHandler.UpdateProductPayload, EffectHandler.UpdateProductResponse>
    
    
    private func makeSUT(
        initialState: State = .init(),
        products: [Product] = [makeProduct()],
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        stateSpy: StateSpy,
        getSettingsSpy: GetSettingsSpy,
        updateContractSpy: UpdateContractSpy,
        prepareSetBankDefaultSpy: PrepareSetBankDefaultSpy,
        createContractSpy: CreateContractSpy,
        updateProductSpy: UpdateProductSpy
    ) {
        let bankDefaultReducer = BankDefaultReducer()
        let reducer = Reducer(
            getProducts: { products },
            bankDefaultReduce: bankDefaultReducer.reduce(_:_:)
        )
        
        let getSettingsSpy = GetSettingsSpy()
        let updateContractSpy = UpdateContractSpy()
        let prepareSetBankDefaultSpy = PrepareSetBankDefaultSpy()
        let createContractSpy = CreateContractSpy()
        let updateProductSpy = UpdateProductSpy()
        
        let effectHandler = EffectHandler(
            createContract: createContractSpy.process(_:completion:),
            getSettings: getSettingsSpy.process(completion:),
            prepareSetBankDefault: prepareSetBankDefaultSpy.process(completion:),
            updateContract: updateContractSpy.process(_:completion:),
            updateProduct: updateProductSpy.process(_:completion:)
        )
        
        let sut = SUT(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            scheduler: .immediate
        )
        
        let stateSpy = StateSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(reducer, file: file, line: line)
        trackForMemoryLeaks(effectHandler, file: file, line: line)
        
        return (sut, stateSpy, getSettingsSpy, updateContractSpy, prepareSetBankDefaultSpy, createContractSpy, updateProductSpy)
    }
    
    private func makeActive() -> (
        different: Product,
        products: [Product],
        details: UserPaymentSettings.ContractDetails
    ) {
        let (selected, different) = (makeProduct(), makeProduct())
        let productSelector = makeProductSelector(
            selected: selected,
            products: [selected, different]
        )
        let (details, _) = contractedState(
            .active,
            productSelector: productSelector
        )
        
        return (different, [selected, different], details)
    }
}

// MARK: - DSL

private extension FastPaymentsSettingsState {
    
    var settingsStatus: SettingsStatus? {
        
        switch userPaymentSettings {
        case .none:
            return nil
            
        case let .contracted(details):
            switch details.paymentContract.contractStatus {
            case .active:   return .active
            case .inactive: return .inactive
            }
            
        case .missingContract:
            return .missingContract
            
        case .failure:
            return .failure
        }
    }
    
    enum SettingsStatus: Equatable {
        
        case active, inactive, missingContract, failure
    }
}
