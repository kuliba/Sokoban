//
//  Model+QRHelpersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 23.07.2024.
//

@testable import ForaBank
import XCTest

final class Model_QRHelpersTests: XCTestCase {
    
    func test_loadCached_shouldDeliverEmptyOnNonMatchingINN() {
        
        let (qrCode, qrMapping) = makeQR(inn: anyMessage())
        let sut = makeSUT(operators: [makeCachingOperator(inn: anyMessage())])
        
        let loaded = sut.loadCached(matching: qrCode, mapping: qrMapping)
        
        XCTAssertEqual(loaded, [])
    }
    
    func test_loadCached_shouldDeliverMatchingByINNOperator() {
        
        let inn = anyMessage()
        let (qrCode, qrMapping) = makeQR(inn: inn)
        let sut = makeSUT(operators: [makeCachingOperator(inn: inn)])
        
        let loaded = sut.loadCached(matching: qrCode, mapping: qrMapping)
        
        XCTAssertEqual(loaded?.count, 1)
        XCTAssertEqual(loaded?.first?.inn, inn)
    }
    
    func test_loadCached_shouldDeliverMatchingOperators() {
        
        let inn = anyMessage()
        let (qrCode, qrMapping) = makeQR(inn: inn)
        let sut = makeSUT(operators: [
            makeCachingOperator(inn: inn),
            makeCachingOperator(inn: inn),
        ])
        
        let loaded = sut.loadCached(matching: qrCode, mapping: qrMapping)
        
        XCTAssertEqual(loaded?.count, 2)
        XCTAssertEqual(loaded?.first?.inn, inn)
        XCTAssertEqual(loaded?.last?.inn, inn)
    }
    
    func test_segmentedPaymentProviders_shouldDeliverMatchingOperators() {
        
        let inn = anyMessage()
        let (qrCode, qrMapping) = makeQR(inn: inn)
        let sut = makeSUT(operators: [
            makeCachingOperator(inn: inn),
            makeCachingOperator(inn: inn),
        ])
        
        let loaded = sut.segmentedPaymentProviders(matching: qrCode, mapping: qrMapping)
        
        XCTAssertEqual(loaded?.count, 2)
        XCTAssertEqual(loaded?.first?.inn, inn)
        XCTAssertEqual(loaded?.last?.inn, inn)
    }
    
    func test_segmentedPaymentProviders_shouldDeliverMatchingOperators_() {
        
        let inn = anyMessage()
        let qrCode = makeQRCode(inn: inn)
        let (_, qrMapping) = makeQR(inn: inn)
        let sut = makeSUT(operators: [
            makeCachingOperator(inn: inn),
            makeCachingOperator(inn: inn),
        ])
        
        let loaded = sut.segmentedPaymentProviders(matching: qrCode, mapping: qrMapping)
        
        XCTAssertEqual(loaded?.count, 2)
        XCTAssertEqual(loaded?.first?.inn, inn)
        XCTAssertEqual(loaded?.last?.inn, inn)
    }
    
    private func makeQR(
        inn: String
    ) -> (QRCode, QRMapping) {
        
        let qrCode = QRCode(original: "", rawData: ["payeeinn": inn])
        let qrMapping = QRMapping(
            parameters: [
                .init(parameter: .general(.inn), keys: ["payeeinn"], type: .string)
            ],
            operators: []
        )
        
        return (qrCode, qrMapping)
    }
    
    // MARK: - helpers tests
    
    func test_load_shouldDeliverNilOnEmptyStub() {
        
        let sut = makeSUT(operators: nil)
        
        XCTAssertNil(load(sut))
    }
    
    func test_load_shouldDeliverEmptyOnEmptyStub() {
        
        let sut = makeSUT(operators: [])
        
        XCTAssertEqual(load(sut), [])
    }
    
    func test_load_shouldDeliverStub() {
        
        let sut = makeSUT(operators: makeCachingOperators(count: 13))
        
        XCTAssertEqual(load(sut)?.count, 13)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = Model
    private typealias CachingOperator = CachingSberOperator
    
    private func makeSUT(
        operators: [CachingOperator]?,
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let localAgent = try! LocalAgentStub(with: operators)
        let sut = SUT.mockWithEmptyExcept(localAgent: localAgent)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(localAgent, file: file, line: line)
        
        return sut
    }
    
    private func makeCachingOperator(
        id: String = anyMessage(),
        inn: String = anyMessage(),
        md5Hash: String? = anyMessage(),
        title: String = anyMessage(),
        sortedOrder: Int = 0
    ) -> CachingOperator {
        
        return .init(id: id, inn: inn, md5Hash: md5Hash, title: title, sortedOrder: sortedOrder)
    }
    
    private func makeCachingOperators(
        count: Int
    ) -> [CachingOperator] {
        
        let operators = (0..<count).enumerated().map { order, _ in
            
            return makeCachingOperator(sortedOrder: order)
        }
        
        precondition(operators.count == count)
        return operators
    }
    
    private func makeQRCode(
        inn: String = "5037008735"
    ) -> QRCode {
        
        return .init(string: "ST00011|Name=Счет по сбору платежей за ЖКУ района Зеленоград|PersonalAcc=40911810100180000361|BankName=Филиал \"Центральный\" Банка ВТБ (ПАО)|BIC=044525411|CorrespAcc=30101810145250000411|PayeeINN=\(inn)|ServiceName=44822770069|PersAcc=123456|PaymPeriod=112021|Amount=738961|Sum=738961|TechCode=02")!
    }
    
    // MARK: - DSL
    
    private func load(_ sut: SUT) -> [CachingOperator]? {
        
        return sut.localAgent.load(type: [CachingOperator].self)
    }
}
