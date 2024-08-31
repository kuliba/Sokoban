//
//  PaymentFlowMicroServiceComposerTests.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import ServiceCategoriesBackend

struct PaymentFlowMicroService<Mobile, QR, Standard, Tax> {
    
    let makePaymentFlow: MakePaymentFlow
}

extension PaymentFlowMicroService {
    
#warning("decouple")
    typealias ServiceCategory = ResponseMapper.GetServiceCategoryListResponse.Category
    
    typealias MakePaymentFlow = (ServiceCategory, @escaping (Flow) -> Void) -> Void
    typealias Flow = PaymentFlow<Mobile, QR, Standard, Tax>
}

enum PaymentFlow<Mobile, QR, Standard, Tax> {
    
    case mobile(Mobile)
    case qr(QR)
    case standard(Standard)
    case taxAndStateServices(Tax)
    case transport
}
extension PaymentFlow: Equatable where Mobile: Equatable, QR: Equatable, Standard: Equatable, Tax: Equatable {}

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

struct PaymentFlowMicroServiceComposerNanoServices<Mobile, QR, Standard, Tax> {
    
    let makeMobile: MakeMobile
    let makeQR: MakeQR
    let makeStandard: MakeStandard
    let makeTax: MakeTax
}

extension PaymentFlowMicroServiceComposerNanoServices {
    
    typealias MakeMobile = (@escaping (Mobile) -> Void) -> Void
    typealias MakeQR = (@escaping (QR) -> Void) -> Void
    typealias MakeStandard = (@escaping (Standard) -> Void) -> Void
    typealias MakeTax = (@escaping (Tax) -> Void) -> Void
}

final class PaymentFlowMicroServiceComposer<Mobile, QR, Standard, Tax> {
    
    private let nanoServices: NanoServices
    
    init(nanoServices: NanoServices) {
        
        self.nanoServices = nanoServices
    }
    
    typealias NanoServices = PaymentFlowMicroServiceComposerNanoServices<Mobile, QR, Standard, Tax>
}

extension PaymentFlowMicroServiceComposer {
    
    func compose() -> PaymentFlowMicroService<Mobile, QR, Standard, Tax> {
        
        return .init(makePaymentFlow: makePaymentFlow)
    }
    
    typealias MicroService = PaymentFlowMicroService<Mobile, QR, Standard, Tax>
}

private extension PaymentFlowMicroServiceComposer {
    
    func makePaymentFlow(
        category: MicroService.ServiceCategory,
        completion: @escaping (MicroService.Flow) -> Void
    ) {
        switch category.paymentFlow {
        case .mobile:
            nanoServices.makeMobile { completion(.mobile($0)) }
            
        case .qr:
            nanoServices.makeQR { completion(.qr($0)) }
            
        case .standard:
            nanoServices.makeStandard { completion(.standard($0)) }
            
        case .taxAndStateServices:
            nanoServices.makeTax { completion(.taxAndStateServices($0)) }
            
        case .transport:
            completion(.transport)
        }
    }
}

import XCTest
import RemoteServices

final class PaymentFlowMicroServiceComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, mobileSpy, qrSpy, standardSpy, taxSpy) = makeSUT()
        
        XCTAssertEqual(mobileSpy.callCount, 0)
        XCTAssertEqual(qrSpy.callCount, 0)
        XCTAssertEqual(standardSpy.callCount, 0)
        XCTAssertEqual(taxSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - id
    
    func test_shouldDeliverMobileFlowIDOnMobile() {
        
        let (sut, mobileSpy, _,_,_) = makeSUT()
        
        expectFlow(sut, with: makeCategory(flow: .mobile), hasID: .mobile) {
            
            mobileSpy.complete(with: self.makeMobile())
        }
    }
    
    func test_shouldDeliverQRFlowIDOnQR() {
    
        let (sut, _, makeQR, _,_) = makeSUT()
        
        expectFlow(sut, with: makeCategory(flow: .qr), hasID: .qr) {
            
            makeQR.complete(with: self.makeQR())
        }
    }
    
    func test_shouldDeliverStandardFlowIDOnStandart() {
        
        let (sut, _,_, standardSpy, _) = makeSUT()

        expectFlow(sut, with: makeCategory(flow: .standard), hasID: .standard) {
            
            standardSpy.complete(with: self.makeStandard())
        }
    }
    
    func test_shouldDeliverTaxAnDStateServicesFlowIDOnTaxAnDStateServices() {
        
        let (sut, _,_,_, makeTax) = makeSUT()
        
        expectFlow(sut, with: makeCategory(flow: .taxAndStateServices), hasID: .taxAndStateServices) {
            
            makeTax.complete(with: self.makeTax())
        }
    }
    
    func test_shouldDeliverTransportFlowIDOnTransport() {
        
        expectFlow(with: makeCategory(flow: .transport), hasID: .transport) {}
    }
    
    // MARK: - associated type
    
    func test_shouldDeliverMobileFlowOnMobile() {
        
        let (sut, mobileSpy, _,_,_) = makeSUT()
        
        expectMobile(sut, with: makeCategory(flow: .mobile), is: Mobile.self) {
            
            mobileSpy.complete(with: self.makeMobile())
        }
    }
    
    func test_shouldDeliverQRFlowOnQR() {
        
        let (sut, _, qrSpy, _,_) = makeSUT()
        
        expectQR(sut, with: makeCategory(flow: .qr), is: QR.self) {
            
            qrSpy.complete(with: self.makeQR())
        }
    }
    
    func test_shouldDeliverStandardFlowOnStandard() {
        
        let (sut, _,_, standardSpy, _) = makeSUT()
        
        expectStandard(sut, with: makeCategory(flow: .standard), is: Standard.self) {
            
            standardSpy.complete(with: self.makeStandard())
        }
    }
    
    //    func test_shouldDeliverTaxAnDStateServicesFlowIDOnTaxAnDStateServices() {
    //
    //        expectFlow(with: makeCategory(flow: .taxAndStateServices), is: .taxAndStateServices)
    //    }
    //
    //    func test_shouldDeliverTransportFlowIDOnTransport() {
    //
    //        expectFlow(with: makeCategory(flow: .transport), is: .transport)
    //    }
    
    // MARK: - Helpers
    
    private typealias Composer = PaymentFlowMicroServiceComposer<Mobile, QR, Standard, Tax>
    private typealias SUT = PaymentFlowMicroService<Mobile, QR, Standard, Tax>
    private typealias Flow = SUT.Flow
    private typealias MakeMobileSpy = Spy<Void, Mobile>
    private typealias MakeQRSpy = Spy<Void, QR>
    private typealias MakeStandardSpy = Spy<Void, Standard>
    private typealias MakeTaxSpy = Spy<Void, Tax>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeMobile: MakeMobileSpy,
        makeQR: MakeQRSpy,
        makeStandard: MakeStandardSpy,
        makeTax: MakeTaxSpy
    ) {
        let makeMobile = MakeMobileSpy()
        let makeQR = MakeQRSpy()
        let makeStandard = MakeStandardSpy()
        let makeTax = MakeTaxSpy()
        let composer = Composer(nanoServices: .init(
            makeMobile: makeMobile.process(completion:),
            makeQR: makeQR.process(completion:),
            makeStandard: makeStandard.process(completion:),
            makeTax: makeTax.process(completion:)
        ))
        let sut = composer.compose()
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(makeMobile, file: file, line: line)
        trackForMemoryLeaks(makeQR, file: file, line: line)
        trackForMemoryLeaks(makeStandard, file: file, line: line)
        trackForMemoryLeaks(makeTax, file: file, line: line)
        
        return (sut, makeMobile, makeQR, makeStandard, makeTax)
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
    
    private func flow(
        _ sut: SUT? = nil,
        with category: SUT.ServiceCategory,
        action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Flow {
        
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        var flow: Flow?
        
        sut.makePaymentFlow(category) {
            
            flow = $0
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        return try XCTUnwrap(flow, "Expected to have flow, but got nil instead.", file: file, line: line)
    }
    
    private func expectFlow(
        _ sut: SUT? = nil,
        with category: SUT.ServiceCategory,
        hasID expectedID: Flow.ID,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            let flow = try flow(sut, with: category, action: action)
            XCTAssertNoDiff(flow.id, expectedID, file: file, line: line)
        } catch {
            XCTFail("Expected flow, but got nil instead.", file: file, line: line)
        }
    }
    
    private func expectMobile<T>(
        _ sut: SUT? = nil,
        with category: SUT.ServiceCategory,
        is expectedType: T.Type,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let flow = try? flow(sut, with: category, action: action)
        guard case let .mobile(mobile) = flow else {
            
            return XCTFail("Expected flow mobile case, but got \(String(describing: flow?.id)) instead.", file: file, line: line)
        }
        
        XCTAssert(mobile is T, "Expected mobile to be of type \(T.self), but got \(type(of: mobile)) instead.", file: file, line: line)
    }
    
    private func expectQR<T>(
        _ sut: SUT? = nil,
        with category: SUT.ServiceCategory,
        is expectedType: T.Type,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let flow = try? flow(sut, with: category, action: action)
        guard case let .qr(qr) = flow else {
            
            return XCTFail("Expected flow qr case, but got \(String(describing: flow?.id)) instead.", file: file, line: line)
        }
        
        XCTAssert(qr is T, "Expected qr to be of type \(T.self), but got \(type(of: qr)) instead.", file: file, line: line)
    }
    
    private func expectStandard<T>(
        _ sut: SUT? = nil,
        with category: SUT.ServiceCategory,
        is expectedType: T.Type,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let flow = try? flow(sut, with: category, action: action)
        guard case let .standard(standard) = flow else {
            
            return XCTFail("Expected flow standard case, but got \(String(describing: flow?.id)) instead.", file: file, line: line)
        }
        
        XCTAssert(standard is T, "Expected standard to be of type \(T.self), but got \(type(of: standard)) instead.", file: file, line: line)
    }
    
    private func expectTax<T>(
        _ sut: SUT? = nil,
        with category: SUT.ServiceCategory,
        is expectedType: T.Type,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let flow = try? flow(sut, with: category, action: action)
        guard case let .taxAndStateServices(taxAndStateServices) = flow else {
            
            return XCTFail("Expected flow taxAndStateServices case, but got \(String(describing: flow?.id)) instead.", file: file, line: line)
        }
        
        XCTAssert(taxAndStateServices is T, "Expected taxAndStateServices to be of type \(T.self), but got \(type(of: taxAndStateServices)) instead.", file: file, line: line)
    }
    
    private struct Mobile: Equatable {
        
        let value: String
    }
    
    private func makeMobile(
        _ value: String = anyMessage()
    ) -> Mobile {
        
        return .init(value: value)
    }
    
    private struct QR: Equatable {
        
        let value: String
    }
    
    private func makeQR(
        _ value: String = anyMessage()
    ) -> QR {
        
        return .init(value: value)
    }
    
    private struct Standard: Equatable {
        
        let value: String
    }
    
    private func makeStandard(
        _ value: String = anyMessage()
    ) -> Standard {
        
        return .init(value: value)
    }
    
    private struct Tax: Equatable {
        
        let value: String
    }
    
    private func makeTax(
        _ value: String = anyMessage()
    ) -> Tax {
        
        return .init(value: value)
    }
}
