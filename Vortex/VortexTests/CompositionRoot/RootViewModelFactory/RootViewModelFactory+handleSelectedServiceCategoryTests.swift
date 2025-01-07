//
//  RootViewModelFactory+handleSelectedServiceCategoryTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 06.12.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_handleSelectedServiceCategoryTests: RootViewModelFactoryTests {
    
    func test_shouldDeliverFailureOnLoadOperatorsFailure() {
        
        let category = makeServiceCategory()
        let (sut, spies) = makeSUT()
        let failure = makeFailure(sut: sut, category: category)
        
        expect(
            sut: sut,
            spies: spies,
            category: makeServiceCategory(),
            assert: {
                switch $0 {
                case .failure: break
                default: XCTFail("Expected failure.")
                }
            },
            on: {
                spies.loadOperators.complete(with: .failure(anyError()))
                spies.makeFailure.complete(with: failure)
            }
        )
    }
    
    func test_shouldDeliverFailureOnEmptyLoadedOperators() {
        
        let category = makeServiceCategory()
        let (sut, spies) = makeSUT()
        let failure = makeFailure(sut: sut, category: category)
        
        expect(
            sut: sut,
            spies: spies,
            category: makeServiceCategory(),
            assert: {
                switch $0 {
                case .failure: break
                default: XCTFail("Expected failure.")
                }
            },
            on: {
                spies.loadOperators.complete(with: .success([]))
                spies.makeFailure.complete(with: failure)
            }
        )
    }
    
    func test_shouldDeliverSuccessOnOneLoadedOperatorsEmptyLatest() {
        
        let payload = makePayload(latestCount: 0, operatorsCount: 1)
        let (sut, spies) = makeSUT()
        let binder = makeBinder(sut: sut, payload: payload)
        
        expect(
            sut: sut,
            spies: spies,
            category: payload.category,
            assert: {
                switch $0 {
                case .success: break
                default: XCTFail("Expected success.")
                }
            },
            on: {
                spies.loadOperators.complete(with: .success(payload.operators))
                spies.loadLatest.complete(with: .success(payload.latest))
                spies.makeSuccess.complete(with: binder)
            }
        )
    }
    
    func test_shouldDeliverSuccessOnOneLoadedOperatorsOneLatest() {
        
        let payload = makePayload(latestCount: 1, operatorsCount: 1)
        let (sut, spies) = makeSUT()
        let binder = makeBinder(sut: sut, payload: payload)
        
        expect(
            sut: sut,
            spies: spies,
            category: payload.category,
            assert: {
                switch $0 {
                case .success: break
                default: XCTFail("Expected success.")
                }
            },
            on: {
                spies.loadOperators.complete(with: .success(payload.operators))
                spies.loadLatest.complete(with: .success(payload.latest))
                spies.makeSuccess.complete(with: binder)
            }
        )
    }
    
    func test_shouldDeliverSuccessOnOneLoadedOperatorsTwoLatest() {
        
        let payload = makePayload(latestCount: 2, operatorsCount: 1)
        let (sut, spies) = makeSUT()
        let binder = makeBinder(sut: sut, payload: payload)
        
        expect(
            sut: sut,
            spies: spies,
            category: payload.category,
            assert: {
                switch $0 {
                case .success: break
                default: XCTFail("Expected success.")
                }
            },
            on: {
                spies.loadOperators.complete(with: .success(payload.operators))
                spies.loadLatest.complete(with: .success(payload.latest))
                spies.makeSuccess.complete(with: binder)
            }
        )
    }
    
    func test_shouldDeliverSuccessOnTwoLoadedOperatorsEmptyLatest() {
        
        let payload = makePayload(latestCount: 0, operatorsCount: 2)
        let (sut, spies) = makeSUT()
        let binder = makeBinder(sut: sut, payload: payload)
        
        expect(
            sut: sut,
            spies: spies,
            category: payload.category,
            assert: {
                switch $0 {
                case .success: break
                default: XCTFail("Expected success.")
                }
            },
            on: {
                spies.loadOperators.complete(with: .success(payload.operators))
                spies.loadLatest.complete(with: .success(payload.latest))
                spies.makeSuccess.complete(with: binder)
            }
        )
    }
    
    func test_shouldDeliverSuccessOnTwoLoadedOperatorsOneLatest() {
        
        let payload = makePayload(latestCount: 1, operatorsCount: 2)
        let (sut, spies) = makeSUT()
        let binder = makeBinder(sut: sut, payload: payload)
        
        expect(
            sut: sut,
            spies: spies,
            category: payload.category,
            assert: {
                switch $0 {
                case .success: break
                default: XCTFail("Expected success.")
                }
            },
            on: {
                spies.loadOperators.complete(with: .success(payload.operators))
                spies.loadLatest.complete(with: .success(payload.latest))
                spies.makeSuccess.complete(with: binder)
            }
        )
    }
    
    func test_shouldDeliverSuccessOnTwoLoadedOperatorsTwoLatest() {
        
        let payload = makePayload(latestCount: 2, operatorsCount: 2)
        let (sut, spies) = makeSUT()
        let binder = makeBinder(sut: sut, payload: payload)
        
        expect(
            sut: sut,
            spies: spies,
            category: payload.category,
            assert: {
                switch $0 {
                case .success: break
                default: XCTFail("Expected success.")
                }
            },
            on: {
                spies.loadOperators.complete(with: .success(payload.operators))
                spies.loadLatest.complete(with: .success(payload.latest))
                spies.makeSuccess.complete(with: binder)
            }
        )
    }
    
    // MARK: - Helpers
    
    private typealias Destination = StandardSelectedCategoryDestination
    private typealias LoadLatestSpy = Spy<Void, Result<[Latest], Error>, Never>
    private typealias LoadOperatorSpy = Spy<Void, Result<[UtilityPaymentProvider], any Error>, Never>
    private typealias MakeFailureSpy = Spy<Void, ServiceCategoryFailureDomain.Binder, Never>
    private typealias MakeSuccessSpy = Spy<SUT.MakeSelectedCategorySuccessPayload, PaymentProviderPickerDomain.Binder, Never>
    
    private struct Spies {
        
        let loadLatest: LoadLatestSpy
        let loadOperators: LoadOperatorSpy
        let makeFailure: MakeFailureSpy
        let makeSuccess: MakeSuccessSpy
        
        var nanoServices: SUT.StandardNanoServices {
            
            return .init(
                loadLatest: loadLatest.process,
                loadOperators: loadOperators.process,
                makeFailure: makeFailure.process,
                makeSuccess: makeSuccess.process
            )
        }
    }
    
    private func makeSpies() -> Spies {
        
        return .init(
            loadLatest: .init(),
            loadOperators: .init(),
            makeFailure: .init(),
            makeSuccess: .init()
        )
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let sut = super.makeSUT().sut
        let spies = makeSpies()
        
        return (sut, spies)
    }
    
    private func makePayload(
        category: ServiceCategory? = nil,
        latestCount: Int,
        operatorsCount: Int
    ) -> SUT.MakeSelectedCategorySuccessPayload {
        
        let category = category ?? makeServiceCategory()
        
        let services = (0..<latestCount).map { _ in makeLatestService() }
        let latest = services.map { Latest.service($0) }
        
        let operators = (0..<operatorsCount).map { _ in makePaymentServiceOperator() }
        
        return .init(category: category, latest: latest, operators: operators)
    }
    
    private func makeBinder(
        sut: SUT,
        payload: RootViewModelFactory.MakeSelectedCategorySuccessPayload
    ) -> PaymentProviderPickerDomain.Binder {
        
        return sut.makePaymentProviderPicker(payload: payload)
    }
    
    private func makeFailure(
        sut: SUT,
        category: ServiceCategory
    ) -> ServiceCategoryFailureDomain.Binder {
        
        sut.makeServiceCategoryFailure(category: category)
    }
    
    private func expect(
        sut: SUT? = nil,
        spies: Spies,
        category: ServiceCategory,
        assert: @escaping (Destination) -> Void,
        on action: @escaping () -> Void,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line).sut
        let exp = expectation(description: "wait for completion")
        
        sut.handleSelectedServiceCategory(
            category,
            nanoServices: spies.nanoServices
        ) {
            assert($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
