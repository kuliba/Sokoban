//
//  PaymentFlowMicroServiceComposerTests.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import ServiceCategoriesBackend

struct PaymentFlowMicroService {
    
    let makePaymentFlow: MakePaymentFlow
}

extension PaymentFlowMicroService {
    
#warning("decouple")
    typealias ServiceCategory = ResponseMapper.GetServiceCategoryListResponse.Category
#warning("decouple")
    typealias MakePaymentFlow = (ServiceCategory, @escaping (PaymentFlow) -> Void) -> Void
    
}

enum PaymentFlow {
    
    case mobile
    case qr
    case standard
    case taxAndStateServices
    case transport
}

extension PaymentFlow {
    
    var id: ID {
        
        switch self {
        case .mobile:              return .mobile
        case .qr:                  return .qr
        case .standard:            return .standard
        case .taxAndStateServices: return .taxAndStateServices
        case .transport:           return .transport
        }
    }
    
    enum ID: Hashable {
        
        case mobile
        case qr
        case standard
        case taxAndStateServices
        case transport
    }
}

final class PaymentFlowMicroServiceComposer {
    
}

extension PaymentFlowMicroServiceComposer {
    
    func compose() -> PaymentFlowMicroService {
        
        return .init(makePaymentFlow: makePaymentFlow)
    }
}

private extension PaymentFlowMicroServiceComposer {
    
    func makePaymentFlow(
        category: PaymentFlowMicroService.ServiceCategory,
        completion: @escaping (PaymentFlow) -> Void
    ) {
        completion(.init(category: category))
    }
}

private extension PaymentFlow {
    
    init(category: PaymentFlowMicroService.ServiceCategory) {
        
        switch category.paymentFlow {
        case .mobile:              self = .mobile
        case .qr:                  self = .qr
        case .standard:            self = .standard
        case .taxAndStateServices: self = .taxAndStateServices
        case .transport:           self = .transport
        }
    }
}

import XCTest
import RemoteServices

final class PaymentFlowMicroServiceComposerTests: XCTestCase {
    
    // MARK: - id
    
    func test_shouldDeliverMobileFlowIDOnMobile() {
        
        expectFlow(with: makeCategory(flow: .mobile), hasID: .mobile)
    }
    
    func test_shouldDeliverQRFlowIDOnQR() {
        
        expectFlow(with: makeCategory(flow: .qr), hasID: .qr)
    }
    
    func test_shouldDeliverStandartFlowIDOnStandart() {
        
        expectFlow(with: makeCategory(flow: .standard), hasID: .standard)
    }
    
    func test_shouldDeliverTaxAnDStateServicesFlowIDOnTaxAnDStateServices() {
        
        expectFlow(with: makeCategory(flow: .taxAndStateServices), hasID: .taxAndStateServices)
    }
    
    func test_shouldDeliverTransportFlowIDOnTransport() {
        
        expectFlow(with: makeCategory(flow: .transport), hasID: .transport)
    }
    
    // MARK: - Helpers
    
    private typealias Composer = PaymentFlowMicroServiceComposer
    private typealias SUT = PaymentFlowMicroService
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        let composer = Composer()
        let sut = composer.compose()
        
        trackForMemoryLeaks(composer, file: file, line: line)
        
        return sut
    }
    
    private func makeCategory(
        latestPaymentsCategory: SUT.ServiceCategory.LatestPaymentsCategory? = nil,
        md5Hash: String = anyMessage(),
        name: String = anyMessage(),
        ord: Int = .random(in: 1...100),
        flow paymentFlow: SUT.ServiceCategory.PaymentFlow = .mobile,
        search: Bool = true,
        type: SUT.ServiceCategory.CategoryType = .charity
    ) -> SUT.ServiceCategory {
        
        return .init(
            latestPaymentsCategory: latestPaymentsCategory,
            md5Hash: md5Hash,
            name: name,
            ord: ord,
            paymentFlow: paymentFlow,
            search: search,
            type: type
        )
    }
    
    private func expectFlow(
        _ sut: SUT? = nil,
        with category: SUT.ServiceCategory,
        hasID expectedID: PaymentFlow.ID,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.makePaymentFlow(category) {
            
            XCTAssertNoDiff($0.id, expectedID, file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}
