//
//  SelectedCategoryGetNavigationComposerTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 30.09.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class SelectedCategoryGetNavigationComposerTests: XCTestCase {
    
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
    
    private func makePaymentComplete(
        model: Model = .mockWithEmptyExcept(),
        sections: [PaymentsSectionViewModel] = []
    ) -> QRNavigation.PaymentComplete {
        
        return .init(model: model, sections: sections)
    }
    
    func test_getNavigation_shouldDeliverStandardOnStandard() {
        
        let sut = makeSUT()
        
        getNavigation(sut, flow: .standard) {
            
            switch $0 {
            case .paymentFlow(.standard):
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
    
    // MARK: - Helpers
    
    private typealias Domain = CategoryPickerSectionDomain
    private typealias SUT = SelectedCategoryGetNavigationComposer
    
    private func makeSUT(
        transport: TransportPaymentsViewModel? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            model: .mockWithEmptyExcept(),
            nanoServices: .init(
                makeMobile: makeMobile,
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
        notify: @escaping Domain.Notify = { _ in },
        completion: @escaping (Domain.Navigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        getNavigation(
            sut,
            with: makeServiceCategory(flow: flow),
            notify: notify,
            completion: completion,
            file: file, line: line
        )
    }
    
    private func getNavigation(
        _ sut: SUT? = nil,
        with select: Domain.Select,
        notify: @escaping Domain.Notify = { _ in },
        completion: @escaping (SUT.Navigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for completion")
        
        sut.getNavigation(select, notify) {
            
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
    
    private func makeTransport(
    ) -> TransportPaymentsViewModel {
        
        return .init(
            operators: [],
            latestPayments: .sample,
            makePaymentsViewModel: { _ in .sample }
        )
    }
}
