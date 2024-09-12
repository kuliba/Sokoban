//
//  Identifiable+updatedTests.swift
//
//
//  Created by Igor Malyarov on 12.09.2024.
//

import ForaTools
import XCTest

final class Identifiable_updatedTests: XCTestCase {
    
    // MARK: - at least one is empty
    
    func test_shouldDeliverEmptyWithFalseOnBothEmpty() {
        
        let source = [Item]()
        let update = [Item]()
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, [])
        XCTAssertNoDiff(updated.didUpdate, false)
    }
    
    func test_shouldDeliverSourceOfOneWithFalseOnEmptyUpdate() {
        
        let source = [makeItem(1)]
        let update = [Item]()
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, source)
        XCTAssertNoDiff(updated.didUpdate, false)
    }
    
    func test_shouldDeliverSourceOfTwoWithFalseOnEmptyUpdate() {
        
        let source = [makeItem(1), makeItem(2)]
        let update = [Item]()
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, source)
        XCTAssertNoDiff(updated.didUpdate, false)
    }
    
    func test_shouldDeliverUpdateOfOneWithTrueOnEmptySource() {
        
        let source = [Item]()
        let update = [makeItem(1)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, update)
        XCTAssertNoDiff(updated.didUpdate, true)
    }
    
    func test_shouldDeliverUpdateOfTwoWithTrueOnEmptySource() {
        
        let source = [Item]()
        let update = [makeItem(1), makeItem(2)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, update)
        XCTAssertNoDiff(updated.didUpdate, true)
    }
    
    // MARK: - both of one
    
    func test_shouldDeliverAppendedWithTrueOnBothOfOneDifferentIDs() {
        
        let source = [makeItem(1)]
        let update = [makeItem(2)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, source + update)
        XCTAssertNoDiff(updated.didUpdate, true)
    }
    
    func test_shouldDeliverUpdateWithTrueOnBothOfOneSameID() {
        
        let source = [makeItem(1)]
        let update = [makeItem(1)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, update)
        XCTAssertNoDiff(updated.didUpdate, true)
        XCTAssertNotEqual(source, update)
    }
    
    // MARK: - one and two
    
    func test_shouldDeliverAppendedWithTrueOnSourceOfOneUpdateOfTwoDifferentIDs() {
        
        let source = [makeItem(1)]
        let update = [makeItem(2), makeItem(3)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, source + update)
        XCTAssertNoDiff(updated.didUpdate, true)
    }
    
    func test_shouldDeliverUpdatedWithTrueOnSourceOfOneUpdateOfTwoSameFirstID() {
        
        let source = [makeItem(1)]
        let update = [makeItem(1), makeItem(2)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, update)
        XCTAssertNoDiff(updated.didUpdate, true)
        XCTAssertNotEqual(source[0], update[0])
    }
    
    func test_shouldDeliverUpdatedWithTrueOnSourceOfOneUpdateOfTwoSameSecondID() {
        
        let source = [makeItem(1)]
        let update = [makeItem(2), makeItem(1)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, update)
        XCTAssertNoDiff(updated.didUpdate, true)
        XCTAssertNotEqual(source[0], update[1])
    }
    
    // MARK: - two and one
    
    func test_shouldDeliverAppendedWithTrueOnSourceOfTwoUpdateOfOneDifferentIDs() {
        
        let source = [makeItem(1), makeItem(2)]
        let update = [makeItem(3)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, source + update)
        XCTAssertNoDiff(updated.didUpdate, true)
    }
    
    func test_shouldDeliverReplacedFirstWithTrueOnSourceOfTwoUpdateOfOneSameFirstID() {
        
        let source = [makeItem(1), makeItem(2)]
        let update = [makeItem(1)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, [source[1], update[0]])
        XCTAssertNoDiff(updated.didUpdate, true)
        XCTAssertNotEqual(source[0], update[0])
    }
    
    func test_shouldDeliverReplacedSecondWithTrueOnSourceOfTwoUpdateOfOneSameSecondID() {
        
        let source = [makeItem(1), makeItem(2)]
        let update = [makeItem(2)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, [source[0], update[0]])
        XCTAssertNoDiff(updated.didUpdate, true)
        XCTAssertNotEqual(source[1], update[0])
    }
    
    // MARK: - two and two
    
    func test_shouldDeliverAppendedWithTrueOnSourceOfTwoUpdateOfTwoDifferentIDs() {
        
        let source = [makeItem(1), makeItem(2)]
        let update = [makeItem(3), makeItem(4)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, source + update)
        XCTAssertNoDiff(updated.didUpdate, true)
    }
    
    func test_shouldDeliverReplacedFirstWithTrueOnSourceOfTwoUpdateOfTwoFirstIDSameFirst() {
        
        let source = [makeItem(1), makeItem(2)]
        let update = [makeItem(1), makeItem(3)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, [source[1], update[0], update[1]])
        XCTAssertNoDiff(updated.didUpdate, true)
        XCTAssertNotEqual(source[0], update[0])
    }
    
    func test_shouldDeliverReplacedSecondWithTrueOnSourceOfTwoUpdateOfTwoFirstIDSameSecond() {
        
        let source = [makeItem(1), makeItem(2)]
        let update = [makeItem(3), makeItem(1)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, [source[1], update[0], update[1]])
        XCTAssertNoDiff(updated.didUpdate, true)
        XCTAssertNotEqual(source[0], update[1])
    }
    
    func test_shouldDeliverReplacedFirstWithTrueOnSourceOfTwoUpdateOfTwoSecondIDSameFirst() {
        
        let source = [makeItem(1), makeItem(2)]
        let update = [makeItem(2), makeItem(3)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, [source[0], update[0], update[1]])
        XCTAssertNoDiff(updated.didUpdate, true)
        XCTAssertNotEqual(source[1], update[0])
    }
    
    func test_shouldDeliverReplacedSecondWithTrueOnSourceOfTwoUpdateOfTwoSecondIDSameSecond() {
        
        let source = [makeItem(1), makeItem(2)]
        let update = [makeItem(3), makeItem(2)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, [source[0], update[0], update[1]])
        XCTAssertNoDiff(updated.didUpdate, true)
        XCTAssertNotEqual(source[1], update[1])
    }
    
    func test_shouldDeliverUpdateWithTrueOnSourceOfTwoUpdateOfTwoBothSameIDs() {
        
        let source = [makeItem(1), makeItem(2)]
        let update = [makeItem(1), makeItem(2)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, update)
        XCTAssertNoDiff(updated.didUpdate, true)
        XCTAssertNotEqual(source, update)
    }
    
    // MARK: - non-contiguous IDs
    
    func test_shouldDeliverAppendedWithTrueOnNonContiguousIDs() {
        
        let source = [makeItem(1), makeItem(100)]
        let update = [makeItem(50), makeItem(101)]
        
        let updated = source.updated(with: update)
        
        XCTAssertNoDiff(updated.updated, source + update)
        XCTAssertNoDiff(updated.didUpdate, true)
    }
    
    // MARK: - Helpers
    
    private struct Item: Equatable, Identifiable {
        
        let id: Int
        let value: String
    }
    
    private func makeItem(
        _ id: Int,
        _ value: String = anyMessage()
    ) -> Item {
        
        return .init(id: id, value: value)
    }
}
