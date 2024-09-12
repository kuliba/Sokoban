//
//  SerialFallbackTests.swift
//
//
//  Created by Igor Malyarov on 12.09.2024.
//

public final class SerialFallback<T, Failure: Error> {
    
    private let getSerial: () -> Serial?
    private let primary: LoadWithSerial
    private let secondary: Load
    
    public init(
        getSerial: @escaping () -> Serial?,
        primary: @escaping LoadWithSerial,
        secondary: @escaping Load
    ) {
        self.getSerial = getSerial
        self.primary = primary
        self.secondary = secondary
    }
}

public extension SerialFallback {
    
    typealias Serial = String
    typealias LoadResult = Result<[T], Failure>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias LoadWithSerial = (Serial?, @escaping LoadCompletion) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
}

public extension SerialFallback {
    
    func callAsFunction(
        completion: @escaping LoadCompletion
    ) {
        let serial = getSerial()
        primary(serial) { [weak self] in
            
            if serial == nil {
                completion($0)
            } else {
                switch $0 {
                case .failure:
                    self?.secondary(completion)
                    
                case let .success(success):
                    break
                }
            }
            
//            if $0.serial == serial {
//                self?.fallback(completion)
//            } else {
//                completion($0.value)
//            }
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
            
            primary.complete(with: .success([]))
        }
    }
    
    func test_shouldDeliverOneOnPrimaryOneNilSerial() {
        
        let item = makeItem()
        let (sut, primary, _) = makeSUT(serial: nil)
        
        expect(sut, toDeliver: .success([item])) {
            
            primary.complete(with: .success([item]))
        }
    }
    
    func test_shouldDeliverTwoOnPrimaryTwoNilSerial() {
        
        let (item1, item2) = (makeItem(), makeItem())
        let (sut, primary, _) = makeSUT(serial: nil)
        
        expect(sut, toDeliver: .success([item1, item2])) {
            
            primary.complete(with: .success([item1, item2]))
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

#warning("add tests for instance deallocation")
    
    // MARK: - Helpers
    
    private typealias SUT = SerialFallback<Item, Failure>
    private typealias Primary = Spy<SUT.Serial?, Result<[Item], Failure>>
    private typealias Secondary = Spy<Void, Result<[Item], Failure>>
    
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
    
    private struct Failure: Error, Equatable {
        
        let value: String
    }
    
    private func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
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
