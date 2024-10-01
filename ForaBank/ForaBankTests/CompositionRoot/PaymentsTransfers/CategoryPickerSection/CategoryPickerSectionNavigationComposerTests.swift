//
//  CategoryPickerSectionMicroServicesComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 30.09.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class CategoryPickerSectionMicroServicesComposerTests: XCTestCase {
    
    // MARK: - getNavigation
    
    func test_getNavigation_shouldDeliverMobileOnMobile() {
        
        getNavigation(flow: .mobile) {
            
            switch $0 {
            case .paymentFlow(.mobile):
                break
                
            default:
                XCTFail("Expected mobile, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverQROnQR() {
        
        getNavigation(flow: .qr) {
            
            switch $0 {
            case .paymentFlow(.qr):
                break
                
            default:
                XCTFail("Expected QR, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverStandardFailureOnStandardFailure() {
        
        let sut = makeSUT(standard: .failure(.init()))
        
        getNavigation(sut, flow: .standard) {
            
            switch $0 {
            case .paymentFlow(.standard(.failure)):
                break
                
            default:
                XCTFail("Expected standard failure, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverStandardOnStandard() {
        
        let sut = makeSUT(standard: .success(makeStandard()))
        
        getNavigation(sut, flow: .standard) {
            
            switch $0 {
            case .paymentFlow(.standard(.success)):
                break
                
            default:
                XCTFail("Expected standard, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverTaxAndStateServicesOnTaxAndStateServices() {
        
        getNavigation(flow: .taxAndStateServices) {
            
            switch $0 {
            case .paymentFlow(.taxAndStateServices):
                break
                
            default:
                XCTFail("Expected taxAndStateServices, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverFailureOnTransportFailure() {
        
        let sut = makeSUT(transport: nil)
        
        getNavigation(sut, flow: .transport) {
            
            switch $0 {
            case let .failure(failure):
                XCTAssertNoDiff(failure.message, "Ошибка создания транспортных платежей")
                
            default:
                XCTFail("Expected failure, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverTransportOnTransportSuccess() {
        
        let sut = makeSUT(transport: makeTransport())
        
        getNavigation(sut, flow: .transport) {
            
            switch $0 {
            case .paymentFlow(.transport):
                break
                
            default:
                XCTFail("Expected transport, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverListOnEmptyList() {
        
        getNavigation(with: .list([])) {
            
            switch $0 {
            case .list:
                break
                
            default:
                XCTFail("Expected list, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverListOnListOfOne() {
        
        getNavigation(with: .list([makeServiceCategory()])) {
            
            switch $0 {
            case .list:
                break
                
            default:
                XCTFail("Expected list, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverListOnListOfTwo() {
        
        getNavigation(with: .list([makeServiceCategory(), makeServiceCategory()])) {
            
            switch $0 {
            case .list:
                break
                
            default:
                XCTFail("Expected list, got \($0) instead.")
            }
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = CategoryPickerSectionMicroServicesComposer
    
    private func makeSUT(
        standard: StandardSelectedCategoryDestination = .failure(.init()),
        transport: TransportPaymentsViewModel? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            nanoServices: .init(
                makeMobile: makeMobile,
                makeQR: { .preview() },
                makeStandard: { $1(standard) },
                makeTax: makeTax,
                makeTransport: { transport }
            ),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func getNavigation(
        _ sut: SUT? = nil,
        flow: ServiceCategory.PaymentFlow,
        notify: @escaping (CategoryPickerSection.FlowDomain.Event) -> Void = { _ in },
        completion: @escaping (CategoryPickerSectionNavigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        getNavigation(sut, with: makeCategorySelect(flow: flow), notify: notify, completion: completion, file: file, line: line)
    }
    
    private func getNavigation(
        _ sut: SUT? = nil,
        with select: CategoryPickerSection.Select,
        notify: @escaping (CategoryPickerSection.FlowDomain.Event) -> Void = { _ in },
        completion: @escaping (CategoryPickerSectionNavigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        let microServices = sut.compose()
        let exp = expectation(description: "wait for completion")
        
        microServices.getNavigation(select, notify) {
            
            completion($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func makeMobile() -> ClosePaymentsViewModelWrapper {
        
        return makeClosePaymentsViewModelWrapper()
    }
    
    private func makeTax() -> ClosePaymentsViewModelWrapper {
        
        return makeClosePaymentsViewModelWrapper()
    }
    
    private func makeClosePaymentsViewModelWrapper(
        model: Model = .mockWithEmptyExcept(),
        category: Payments.Category = .fast,
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate
    ) -> ClosePaymentsViewModelWrapper {
        
        return .init(model: model, category: category, scheduler: scheduler)
    }
    
    private func makeStandard(
    ) -> PaymentProviderPicker.Binder {
        
        return .init(
            content: .init(
                operationPicker: (),
                providerList: .init(
                    initialState: .init(
                        lastPayments: [],
                        operators: [],
                        searchText: ""
                    ),
                    reduce: { state, _ in return (state, nil) },
                    handleEffect: { _,_ in }
                ),
                search: .none,
                cancellables: []
            ),
            flow: .init(
                initialState: .init(),
                reduce: { state, _ in return (state, nil) },
                handleEffect: { _,_ in }
            ),
            bind: { _,_ in [] }
        )
    }
    
    private func makeTransport(
    ) -> TransportPaymentsViewModel {
        
        return .init(
            operators: [],
            latestPayments: .sample,
            makePaymentsViewModel: { _ in .sample }
        )
    }
    
    private func makeCategorySelect(
        flow: ServiceCategory.PaymentFlow
    ) -> CategoryPickerSection.Select {
        
        return .category(makeServiceCategory(flow: flow))
    }
    
    private func makeCategorySelect(
        _ serviceCategory: ServiceCategory? = nil
    ) -> CategoryPickerSection.Select {
        
        return .category(serviceCategory ?? makeServiceCategory())
    }
    
    private func makeServiceCategory(
        latestPaymentsCategory: ServiceCategory.LatestPaymentsCategory? = nil,
        md5Hash: String = anyMessage(),
        name: String = anyMessage(),
        ord: Int = .random(in: 1...100),
        flow paymentFlow: ServiceCategory.PaymentFlow = .mobile,
        hasSearch: Bool = false,
        type: ServiceCategory.CategoryType = .networkMarketing
    ) -> ServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            hasSearch: hasSearch,
            type: type
        )
    }
}
