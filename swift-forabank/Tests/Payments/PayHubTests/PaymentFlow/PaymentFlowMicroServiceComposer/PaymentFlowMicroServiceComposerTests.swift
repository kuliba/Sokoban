//
//  PaymentFlowMicroServiceComposerTests.swift
//
//
//  Created by Igor Malyarov on 30.08.2024.
//

import PayHub
import XCTest

final class PaymentFlowMicroServiceComposerTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, mobileSpy, qrSpy, standardSpy, taxSpy, transportSpy) = makeSUT()
        
        XCTAssertEqual(mobileSpy.callCount, 0)
        XCTAssertEqual(qrSpy.callCount, 0)
        XCTAssertEqual(standardSpy.callCount, 0)
        XCTAssertEqual(taxSpy.callCount, 0)
        XCTAssertEqual(transportSpy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - id
    
    func test_shouldDeliverMobileFlowIDOnMobile() {
        
        let (sut, mobileSpy, _,_,_,_) = makeSUT()
        
        expectFlow(sut, with: .mobile, hasID: .mobile) {
            
            mobileSpy.complete(with: self.makeMobile())
        }
    }
    
    func test_shouldDeliverQRFlowIDOnQR() {
        
        let (sut, _, makeQR, _,_,_) = makeSUT()
        
        expectFlow(sut, with: .qr, hasID: .qr) {
            
            makeQR.complete(with: self.makeQR())
        }
    }
    
    func test_shouldDeliverStandardFlowIDOnStandart() {
        
        let (sut, _,_, standardSpy, _,_) = makeSUT()
        
        expectFlow(sut, with: .standard, hasID: .standard) {
            
            standardSpy.complete(with: self.makeStandard())
        }
    }
    
    func test_shouldDeliverTaxAnDStateServicesFlowIDOnTaxAnDStateServices() {
        
        let (sut, _,_,_, makeTax, _) = makeSUT()
        
        expectFlow(sut, with: .taxAndStateServices, hasID: .taxAndStateServices) {
            
            makeTax.complete(with: self.makeTax())
        }
    }
    
    func test_shouldDeliverTransportFlowIDOnTransport() {
        
        let (sut, _,_,_,_, makeTransport) = makeSUT()
        
        expectFlow(sut, with: .transport, hasID: .transport) {
            
            makeTransport.complete(with: self.makeTransport())
        }
    }
    
    // MARK: - associated type
    
    func test_shouldDeliverMobileFlowOnMobile() {
        
        let (sut, mobileSpy, _,_,_,_) = makeSUT()
        
        expectMobile(sut, with: .mobile, is: Mobile.self) {
            
            mobileSpy.complete(with: self.makeMobile())
        }
    }
    
    func test_shouldDeliverQRFlowOnQR() {
        
        let (sut, _, qrSpy, _,_,_) = makeSUT()
        
        expectQR(sut, with: .qr, is: QR.self) {
            
            qrSpy.complete(with: self.makeQR())
        }
    }
    
    func test_shouldDeliverStandardFlowOnStandard() {
        
        let (sut, _,_, standardSpy, _,_) = makeSUT()
        
        expectStandard(sut, with: .standard, is: Standard.self) {
            
            standardSpy.complete(with: self.makeStandard())
        }
    }
    
    func test_shouldDeliverTaxFlowOnTax() {
        
        let (sut, _,_,_, makeTax, _) = makeSUT()
        
        expectTax(sut, with: .taxAndStateServices, is: Tax.self) {
            
            makeTax.complete(with: self.makeTax())
        }
    }
    
    func test_shouldDeliverTransportFlowOnTransport() {
        
        let (sut, _,_,_,_, makeTransport) = makeSUT()
        
        expectTransport(sut, with: .transport, is: Transport.self) {
            
            makeTransport.complete(with: self.makeTransport())
        }
    }
    
    // MARK: - Helpers
    
    private typealias Composer = PaymentFlowMicroServiceComposer<Mobile, QR, Standard, Tax, Transport>
    private typealias SUT = PaymentFlowMicroService<Mobile, QR, Standard, Tax, Transport>
    private typealias Flow = SUT.Flow
    private typealias MakeMobileSpy = Spy<Void, Mobile>
    private typealias MakeQRSpy = Spy<Void, QR>
    private typealias MakeStandardSpy = Spy<Void, Standard>
    private typealias MakeTaxSpy = Spy<Void, Tax>
    private typealias MakeTransportSpy = Spy<Void, Transport>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        makeMobile: MakeMobileSpy,
        makeQR: MakeQRSpy,
        makeStandard: MakeStandardSpy,
        makeTax: MakeTaxSpy,
        makeTransport: MakeTransportSpy
    ) {
        let makeMobile = MakeMobileSpy()
        let makeQR = MakeQRSpy()
        let makeStandard = MakeStandardSpy()
        let makeTax = MakeTaxSpy()
        let makeTransport = MakeTransportSpy()
        let composer = Composer(nanoServices: .init(
            makeMobile: makeMobile.process(completion:),
            makeQR: makeQR.process(completion:),
            makeStandard: makeStandard.process(completion:),
            makeTax: makeTax.process(completion:),
            makeTransport: makeTransport.process(completion:)
        ))
        let sut = composer.compose()
        
        trackForMemoryLeaks(composer, file: file, line: line)
        trackForMemoryLeaks(makeMobile, file: file, line: line)
        trackForMemoryLeaks(makeQR, file: file, line: line)
        trackForMemoryLeaks(makeStandard, file: file, line: line)
        trackForMemoryLeaks(makeTax, file: file, line: line)
        trackForMemoryLeaks(makeTransport, file: file, line: line)
        
        return (sut, makeMobile, makeQR, makeStandard, makeTax, makeTransport)
    }
    
    private func flow(
        _ sut: SUT? = nil,
        with id: Flow.ID,
        action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Flow {
        
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        var flow: Flow?
        
        sut.makePaymentFlow(id) {
            
            flow = $0
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
        
        return try XCTUnwrap(flow, "Expected to have flow, but got nil instead.", file: file, line: line)
    }
    
    private func expectFlow(
        _ sut: SUT? = nil,
        with id: Flow.ID,
        hasID expectedID: Flow.ID,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        do {
            let flow = try flow(sut, with: id, action: action)
            XCTAssertNoDiff(flow.id, expectedID, file: file, line: line)
        } catch {
            XCTFail("Expected flow, but got nil instead.", file: file, line: line)
        }
    }
    
    private func expectMobile<T>(
        _ sut: SUT? = nil,
        with id: Flow.ID,
        is expectedType: T.Type,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let flow = try? flow(sut, with: id, action: action)
        guard case let .mobile(mobile) = flow else {
            
            return XCTFail("Expected flow mobile case, but got \(String(describing: flow?.id)) instead.", file: file, line: line)
        }
        
        XCTAssert(mobile is T, "Expected mobile to be of type \(T.self), but got \(type(of: mobile)) instead.", file: file, line: line)
    }
    
    private func expectQR<T>(
        _ sut: SUT? = nil,
        with id: Flow.ID,
        is expectedType: T.Type,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let flow = try? flow(sut, with: id, action: action)
        guard case let .qr(qr) = flow else {
            
            return XCTFail("Expected flow qr case, but got \(String(describing: flow?.id)) instead.", file: file, line: line)
        }
        
        XCTAssert(qr is T, "Expected qr to be of type \(T.self), but got \(type(of: qr)) instead.", file: file, line: line)
    }
    
    private func expectStandard<T>(
        _ sut: SUT? = nil,
        with id: Flow.ID,
        is expectedType: T.Type,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let flow = try? flow(sut, with: id, action: action)
        guard case let .standard(standard) = flow else {
            
            return XCTFail("Expected flow standard case, but got \(String(describing: flow?.id)) instead.", file: file, line: line)
        }
        
        XCTAssert(standard is T, "Expected standard to be of type \(T.self), but got \(type(of: standard)) instead.", file: file, line: line)
    }
    
    private func expectTax<T>(
        _ sut: SUT? = nil,
        with id: Flow.ID,
        is expectedType: T.Type,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let flow = try? flow(sut, with: id, action: action)
        guard case let .taxAndStateServices(taxAndStateServices) = flow else {
            
            return XCTFail("Expected flow taxAndStateServices case, but got \(String(describing: flow?.id)) instead.", file: file, line: line)
        }
        
        XCTAssert(taxAndStateServices is T, "Expected taxAndStateServices to be of type \(T.self), but got \(type(of: taxAndStateServices)) instead.", file: file, line: line)
    }
    
    private func expectTransport<T>(
        _ sut: SUT? = nil,
        with id: Flow.ID,
        is expectedType: T.Type,
        action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let flow = try? flow(sut, with: id, action: action)
        guard case let .transport(transport) = flow else {
            
            return XCTFail("Expected flow transport case, but got \(String(describing: flow?.id)) instead.", file: file, line: line)
        }
        
        XCTAssert(transport is T, "Expected transport to be of type \(T.self), but got \(type(of: transport)) instead.", file: file, line: line)
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
    
    private struct Transport: Equatable {
        
        let value: String
    }
    
    private func makeTransport(
        _ value: String = anyMessage()
    ) -> Transport {
        
        return .init(value: value)
    }
}
