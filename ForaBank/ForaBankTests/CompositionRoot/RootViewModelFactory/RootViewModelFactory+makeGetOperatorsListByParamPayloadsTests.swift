//
//  RootViewModelFactory+makeGetOperatorsListByParamPayloadsTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.10.2024.
//

@testable import ForaBank
import XCTest

final class RootViewModelFactory_makeGetOperatorsListByParamPayloadsTests: RootViewModelFactoryTests {
    
    func test_makePayloads_shouldDeliverEmptyOnEmpty() {
        
        assert([], from: [])
    }
    
    func test_makePayloads_shouldDeliverEmptyOnMobileFlowCategory() {
        
        assert([], from: [makeServiceCategory(flow: .mobile)])
    }
    
    func test_makePayloads_shouldDeliverEmptyOnQRFlowCategory() {
        
        assert([], from: [makeServiceCategory(flow: .qr)])
    }
    
    func test_makePayloads_shouldDeliverEmptyOnTaxFlowCategory() {
        
        assert([], from: [makeServiceCategory(flow: .taxAndStateServices)])
    }
    
    func test_makePayloads_shouldDeliverEmptyOnTransportFlowCategory() {
        
        assert([], from: [makeServiceCategory(flow: .transport)])
    }
    
    func test_makePayloads_shouldDeliverEmptyOnNonStandardFlowCategories() {
        
        assert([], from: nonStandardFlowCategories())
    }
    
    func test_makePayloads_shouldDeliverOneOnOneWithNilSerial() {
        
        let category = makeServiceCategory(flow: .standard)
        
        assert([.init(serial: nil, category: category)], from: [category])
    }
    
    func test_makePayloads_shouldDeliverTwoOnTwoWithNilSerial() {
        
        let category1 = makeServiceCategory(flow: .standard)
        let category2 = makeServiceCategory(flow: .standard)
        
        assert([
            .init(serial: nil, category: category1),
            .init(serial: nil, category: category2),
        ], from: [category1, category2]
        )
    }
    
    func test_makePayloads_shouldDeliverStandartOnMixedWithNilSerial() {
        
        let standard = makeServiceCategory(flow: .standard)
        let categories = (nonStandardFlowCategories() + [standard]).shuffled()
        
        assert([.init(serial: nil, category: standard)], from: categories)
    }
    
    func test_makePayloads_shouldDeliverOneOnOneWithNonNilSerial() {
        
        let serial = anyMessage()
        let category = makeServiceCategory(flow: .standard)
        
        assert(
            sut: makeSUT(serial: serial),
            [.init(serial: serial, category: category)],
            from: [category]
        )
    }
    
    func test_makePayloads_shouldDeliverTwoOnTwoWithNonNilSerial() {
        
        let serial = anyMessage()
        let category1 = makeServiceCategory(flow: .standard)
        let category2 = makeServiceCategory(flow: .standard)
        
        assert(
            sut: makeSUT(serial: serial),
            [.init(serial: serial, category: category1),
             .init(serial: serial, category: category2),],
            from: [category1, category2]
        )
    }
    
    func test_makePayloads_shouldDeliverTwoOnMixedWithNonNilSerial() {
        
        let serial = anyMessage()
        let mobile = makeServiceCategory(flow: .mobile)
        let qr = makeServiceCategory(flow: .qr)
        let transport = makeServiceCategory(flow: .transport)
        let category1 = makeServiceCategory(flow: .standard)
        let category2 = makeServiceCategory(flow: .standard)
        
        assert(
            sut: makeSUT(serial: serial),
            [.init(serial: serial, category: category1),
             .init(serial: serial, category: category2),],
            from: [qr, category1, mobile, category2, transport]
        )
    }
    
    func test_makePayloads_shouldRemoveDuplicates() {
        
        let serial = anyMessage()
        let mobile = makeServiceCategory(flow: .mobile)
        let qr = makeServiceCategory(flow: .qr)
        let transport = makeServiceCategory(flow: .transport)
        let category1 = makeServiceCategory(flow: .standard)
        let category2 = makeServiceCategory(flow: .standard)
        
        assert(
            sut: makeSUT(serial: serial),
            [.init(serial: serial, category: category1),
             .init(serial: serial, category: category2),],
            from: [qr, category1, mobile, qr, category1, mobile, category2, transport, category2, transport]
        )
    }
    
    // MARK: - Helpers
    
    private typealias Payload = RequestFactory.GetOperatorsListByParamPayload
    
    func makeSUT(
        serial: String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let model: Model = .mockWithEmptyExcept(
            localAgent: LocalAgentSpy(
                loadStub: [CodableServiceCategory](),
                storeStub: .success(()),
                serialStub: serial
            )
        )
        
        return makeSUT(model: model, file: file, line: line).sut
    }
    
    private func makePayloads(
        sut: SUT? = nil,
        from categories: [ServiceCategory],
        file: StaticString = #file,
        line: UInt = #line
    ) -> [Payload] {
        
        let sut = sut ?? makeSUT(file: file, line: line).sut
        
        return sut.makeGetOperatorsListByParamPayloads(from: categories)
    }
    
    private func assert(
        sut: SUT? = nil,
        _ expectedPayloads: [Payload],
        from categories: [ServiceCategory],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let receivedPayloads = makePayloads(sut: sut, from: categories, file: file, line: line)
        
        XCTAssertNoDiff(expectedPayloads, receivedPayloads, "Expected to have \(expectedPayloads), but got \(receivedPayloads) instead.", file: file, line: line)
    }
    
    private func nonStandardFlowCategories(
        file: StaticString = #file,
        line: UInt = #line
    ) -> [ServiceCategory] {
        
        var flows = nonStandardFlows()
        flows.shuffle()
        
        return flows.map { makeServiceCategory(flow: $0) }
    }
    
    private func nonStandardFlows(
        file: StaticString = #file,
        line: UInt = #line
    ) -> [ServiceCategory.PaymentFlow] {
        
        let flows = ServiceCategory.PaymentFlow.allCases.filter { $0 != .standard }
        XCTAssertFalse(flows.contains(.standard), "Expected non-standard flows.", file: file, line: line)
        
        return flows
    }
}
