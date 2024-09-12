//
//  SerialFallbackTests.swift
//
//
//  Created by Igor Malyarov on 12.09.2024.
//

public final class SerialFallback<T, Failure: Error> {
    
    private let getSerial: () -> Serial?
    private let primary: Primary
    private let secondary: Secondary
    
    public init(
        getSerial: @escaping () -> Serial?,
        primary: @escaping Primary,
        secondary: @escaping Secondary
    ) {
        self.getSerial = getSerial
        self.primary = primary
        self.secondary = secondary
    }
}

public extension SerialFallback {
    
    typealias Serial = String
    
    typealias PrimaryResult = Result<SerialStamped<[T]>, Failure>
    typealias PrimaryCompletion = (PrimaryResult) -> Void
    typealias Primary = (Serial?, @escaping PrimaryCompletion) -> Void
    
    typealias SecondaryResult = Result<[T], Failure>
    typealias SecondaryCompletion = (SecondaryResult) -> Void
    typealias Secondary = (@escaping SecondaryCompletion) -> Void
}

public extension SerialFallback {
    
    func callAsFunction(
        completion: @escaping SecondaryCompletion
    ) {
        let serial = getSerial()
        primary(serial) { [weak self] in
            
            guard let self else { return }
            
            if serial == nil {
                completion($0.map(\.value))
            } else {
                switch $0 {
                case .failure:
                    self.secondary(completion)
                    
                case let .success(success):
                    if success.serial == serial {
                        self.secondary(completion)
                    } else {
                        completion(.success(success.value))
                    }
                }
            }
        }
    }
}

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
        
        expect(sut, toDeliver: .failure(primaryFailure)) {
            
            primary.complete(with: .failure(primaryFailure))
        }
    }
    
    func test_shouldDeliverEmptyOnPrimaryEmptyNilSerial() {
        
        let (sut, primary, _) = makeSUT(serial: nil)
        
        expect(sut, toDeliver: .success([])) {
            
            primary.complete(with: makeSuccess([]))
        }
    }
    
    func test_shouldDeliverOneOnPrimaryOneNilSerial() {
        
        let item = makeItem()
        let (sut, primary, _) = makeSUT(serial: nil)
        
        expect(sut, toDeliver: .success([item])) {
            
            primary.complete(with: makeSuccess([item]))
        }
    }
    
    func test_shouldDeliverTwoOnPrimaryTwoNilSerial() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, primary, _) = makeSUT(serial: nil)
        
        expect(sut, toDeliver: .success([item1, item2])) {
            
            primary.complete(with: makeSuccess([item1, item2]))
        }
    }
    
    // MARK: - non-nil serial, primary failure - deliver secondary result
    
    func test_shouldDeliverSecondaryFailureOnPrimaryFailureSecondaryFailure() {
        
        let (primaryFailure, secondaryFailure) = (makeFailure(), makeFailure())
        let (sut, primary, secondary) = makeSUT(serial: anyMessage())
        
        expect(sut, toDeliver: .failure(secondaryFailure)) {
            
            primary.complete(with: .failure(primaryFailure))
            secondary.complete(with: .failure(secondaryFailure))
        }
    }
    
    func test_shouldDeliverEmptyOnPrimaryFailureSecondaryEmpty() {
        
        let primaryFailure = makeFailure()
        let (sut, primary, secondary) = makeSUT(serial: anyMessage())
        
        expect(sut, toDeliver: .success([])) {
            
            primary.complete(with: .failure(primaryFailure))
            secondary.complete(with: .success([]))
        }
    }
    
    func test_shouldDeliverOneOnPrimaryFailureSecondaryOne() {
        
        let primaryFailure = makeFailure()
        let item = makeItem()
        let (sut, primary, secondary) = makeSUT(serial: anyMessage())
        
        expect(sut, toDeliver: .success([item])) {
            
            primary.complete(with: .failure(primaryFailure))
            secondary.complete(with: .success([item]))
        }
    }
    
    func test_shouldDeliverTwoOnPrimaryFailureSecondaryTwo() {
        
        let primaryFailure = makeFailure()
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, primary, secondary) = makeSUT(serial: anyMessage())
        
        expect(sut, toDeliver: .success([item1, item2])) {
            
            primary.complete(with: .failure(primaryFailure))
            secondary.complete(with: .success([item1, item2]))
        }
    }
    
    // MARK: - different serial - deliver primary success without calling secondary
    
    func test_shouldDeliverEmptyOnPrimaryEmptyDifferentSerial() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let (sut, primary, _) = makeSUT(serial: oldSerial)
        
        expect(sut, toDeliver: .success([])) {
            
            primary.complete(with: makeSuccess([], newSerial))
        }
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_shouldDeliverOneOnPrimaryOneDifferentSerial() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let item = makeItem()
        let (sut, primary, _) = makeSUT(serial: oldSerial)
        
        expect(sut, toDeliver: .success([item])) {
            
            primary.complete(with: makeSuccess([item], newSerial))
        }
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    func test_shouldDeliverTwoOnPrimaryTwoDifferentSerial() {
        
        let (oldSerial, newSerial) = (anyMessage(), anyMessage())
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, primary, _) = makeSUT(serial: oldSerial)
        
        expect(sut, toDeliver: .success([item1, item2])) {
            
            primary.complete(with: makeSuccess([item1, item2], newSerial))
        }
        XCTAssertNotEqual(oldSerial, newSerial)
    }
    
    // MARK: - same serial: ignore primary result
    
    func test_shouldDeliverFailureOnSecondaryFailureSameSerial() {
        
        let serial = anyMessage()
        let failure = makeFailure()
        let (sut, primary, secondary) = makeSUT(serial: serial)
        
        expect(sut, toDeliver: .failure(failure)) {
            
            primary.complete(with: makeSuccess(makeItems(count: 100), serial))
            secondary.complete(with: .failure(failure))
        }
    }
    
    func test_shouldDeliverEmptyOnSecondaryEmptySameSerial() {
        
        let serial = anyMessage()
        let (sut, primary, secondary) = makeSUT(serial: serial)
        
        expect(sut, toDeliver: .success([])) {
            
            primary.complete(with: makeSuccess(makeItems(count: 100), serial))
            secondary.complete(with: .success([]))
        }
    }
    
    func test_shouldDeliverOneOnSecondaryOneSameSerial() {
        
        let serial = anyMessage()
        let item = makeItem()
        let (sut, primary, secondary) = makeSUT(serial: serial)
        
        expect(sut, toDeliver: .success([item])) {
            
            primary.complete(with: makeSuccess(makeItems(count: 100), serial))
            secondary.complete(with: .success([item]))
        }
    }
    
    func test_shouldDeliverTwoOnSecondaryTwoSameSerial() {
        
        let serial = anyMessage()
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, primary, secondary) = makeSUT(serial: serial)
        
        expect(sut, toDeliver: .success([item1, item2])) {
            
            primary.complete(with: makeSuccess(makeItems(count: 100), serial))
            secondary.complete(with: .success([item1, item2]))
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
        
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = SerialFallback<Item, Failure>
    private typealias Primary = Spy<SUT.Serial?, SUT.PrimaryResult>
    private typealias Secondary = Spy<Void, SUT.SecondaryResult>
    
    private func makeSUT(
        serial: SUT.Serial? = nil,
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
        _ serial: SUT.Serial = anyMessage()
    ) -> SUT.PrimaryResult {
        
        return .success(.init(value: items, serial: serial))
    }
    
    private func expect(
        _ sut: SUT,
        toDeliver expectedResult: Result<[Item], Failure>,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut {
            XCTAssertNoDiff($0, expectedResult, "Expected \(expectedResult), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
