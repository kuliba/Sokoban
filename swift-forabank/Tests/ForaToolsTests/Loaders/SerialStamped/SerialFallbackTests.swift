//
//  SerialFallbackTests.swift
//
//
//  Created by Igor Malyarov on 12.09.2024.
//

import ForaTools
import XCTest

final class SerialFallbackTests: XCTestCase {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, primary, secondary) = makeSUT()
        
        XCTAssertEqual(primary.callCount, 0)
        XCTAssertEqual(secondary.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - nil serial - deliver primary result without calling secondary
    
    func test_shouldDeliverFailureOnPrimaryFailureNilSerial() {
        
        let primaryFailure = makeFailure()
        let (sut, primary, _) = makeSUT(serial: nil)
        
        expect(sut, toDeliver: .none) {
            
            primary.complete(with: .failure(primaryFailure))
        }
    }
    
    func test_shouldDeliverEmptyOnPrimaryEmptyNilSerial() {
        
        let (sut, primary, _) = makeSUT(serial: nil)
        
        expect(sut, toDeliver: []) {
            
            primary.complete(with: makeSuccess([]))
        }
    }
    
    func test_shouldDeliverOneOnPrimaryOneNilSerial() {
        
        let item = makeItem()
        let (sut, primary, _) = makeSUT(serial: nil)
        
        expect(sut, toDeliver: [item]) {
            
            primary.complete(with: makeSuccess([item]))
        }
    }
    
    func test_shouldDeliverTwoOnPrimaryTwoNilSerial() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, primary, _) = makeSUT(serial: nil)
        
        expect(sut, toDeliver: [item1, item2]) {
            
            primary.complete(with: makeSuccess([item1, item2]))
        }
    }
    
    // MARK: - non-nil serial, primary failure - deliver secondary result
    
    func test_shouldDeliverSecondaryFailureOnPrimaryFailureSecondaryFailure() {
        
        let (primaryFailure, secondaryFailure) = (makeFailure(), makeFailure())
        let (sut, primary, secondary) = makeSUT(serial: anyMessage())
        
        expect(sut, toDeliver: .none) {
            
            primary.complete(with: .failure(primaryFailure))
            secondary.complete(with: .none)
        }
    }
    
    func test_shouldDeliverEmptyOnPrimaryFailureSecondaryEmpty() {
        
        let primaryFailure = makeFailure()
        let (sut, primary, secondary) = makeSUT(serial: anyMessage())
        
        expect(sut, toDeliver: []) {
            
            primary.complete(with: .failure(primaryFailure))
            secondary.complete(with: [])
        }
    }
    
    func test_shouldDeliverOneOnPrimaryFailureSecondaryOne() {
        
        let primaryFailure = makeFailure()
        let item = makeItem()
        let (sut, primary, secondary) = makeSUT(serial: anyMessage())
        
        expect(sut, toDeliver: [item]) {
            
            primary.complete(with: .failure(primaryFailure))
            secondary.complete(with: [item])
        }
    }
    
    func test_shouldDeliverTwoOnPrimaryFailureSecondaryTwo() {
        
        let primaryFailure = makeFailure()
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, primary, secondary) = makeSUT(serial: anyMessage())
        
        expect(sut, toDeliver: [item1, item2]) {
            
            primary.complete(with: .failure(primaryFailure))
            secondary.complete(with: [item1, item2])
        }
    }
    
    // MARK: - different serial - deliver primary success without calling secondary
    
    func test_shouldDeliverEmptyOnPrimaryEmptyDifferentSerial() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let (sut, primary, _) = makeSUT(serial: oldSerial)
        
        expect(sut, toDeliver: []) {
            
            primary.complete(with: makeSuccess([], newSerial))
        }
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_shouldDeliverOneOnPrimaryOneDifferentSerial() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let item = makeItem()
        let (sut, primary, _) = makeSUT(serial: oldSerial)
        
        expect(sut, toDeliver: [item]) {
            
            primary.complete(with: makeSuccess([item], newSerial))
        }
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_shouldDeliverTwoOnPrimaryTwoDifferentSerial() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, primary, _) = makeSUT(serial: oldSerial)
        
        expect(sut, toDeliver: [item1, item2]) {
            
            primary.complete(with: makeSuccess([item1, item2], newSerial))
        }
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    // MARK: - same serial: ignore primary result
    
    func test_shouldDeliverFailureOnSecondaryFailureSameSerial() {
        
        let serial = anyMessage()
        let failure = makeFailure()
        let (sut, primary, secondary) = makeSUT(serial: serial)
        
        expect(sut, toDeliver: .none) {
            
            primary.complete(with: makeSuccess(makeItems(count: 100), serial))
            secondary.complete(with: .none)
        }
    }
    
    func test_shouldDeliverEmptyOnSecondaryEmptySameSerial() {
        
        let serial = anyMessage()
        let (sut, primary, secondary) = makeSUT(serial: serial)
        
        expect(sut, toDeliver: []) {
            
            primary.complete(with: makeSuccess(makeItems(count: 100), serial))
            secondary.complete(with: [])
        }
    }
    
    func test_shouldDeliverOneOnSecondaryOneSameSerial() {
        
        let serial = anyMessage()
        let item = makeItem()
        let (sut, primary, secondary) = makeSUT(serial: serial)
        
        expect(sut, toDeliver: [item]) {
            
            primary.complete(with: makeSuccess(makeItems(count: 100), serial))
            secondary.complete(with: [item])
        }
    }
    
    func test_shouldDeliverTwoOnSecondaryTwoSameSerial() {
        
        let serial = anyMessage()
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, primary, secondary) = makeSUT(serial: serial)
        
        expect(sut, toDeliver: [item1, item2]) {
            
            primary.complete(with: makeSuccess(makeItems(count: 100), serial))
            secondary.complete(with: [item1, item2])
        }
    }
    
    func test_shouldNotDeliverResultOnInstanceDeallocation() {
        
        var sut: SUT?
        let primary: Primary
        (sut, primary, _) = makeSUT()
        let exp = expectation(description: "completion should not complete")
        exp.isInverted = true
        
        sut? { _ in exp.fulfill() }
        sut = nil
        primary.complete(with: makeSuccess(makeItems(count: 100)))
        
        wait(for: [exp], timeout: 0.5)
    }
    
    // MARK: - Helpers
    
    private typealias Serial = String
    private typealias SUT = SerialFallback<Serial, Item, Failure>
    private typealias Primary = Spy<Serial?, SUT.PrimaryResult>
    private typealias Secondary = Spy<Void, [Item]?>
    
    private func makeSUT(
        serial: Serial? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        primary: Primary,
        secondary: Secondary
    ) {
        let primary = Primary()
        let secondary = Secondary()
        let sut = SUT(
            getSerial: { serial },
            primary: primary.process(_:completion:),
            secondary: secondary.process(completion:)
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primary, file: file, line: line)
        trackForMemoryLeaks(secondary, file: file, line: line)
        
        return (sut, primary, secondary)
    }
    
    private struct Item: Equatable {
        
        let value: String
    }
    
    private func makeItem(
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(value: value)
    }
    
    private func makeItems(
        count: Int
    ) -> [Item] {
        
        (0..<count).map { _ in makeItem() }
    }
    
    private struct Failure: Error, Equatable {
        
        let value: String
    }
    
    private func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
    }
    
    private func makeSuccess(
        _ items: [Item],
        _ serial: Serial = anyMessage()
    ) -> SUT.PrimaryResult {
        
        return .success(.init(value: items, serial: serial))
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResult: [Item]?,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut {
            XCTAssertNoDiff($0, expectedResult, "Expected \(String(describing: expectedResult)), but got \(String(describing: $0)) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
