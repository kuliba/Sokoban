//
//  DataSelectorTests.swift
//  
//
//  Created by Igor Malyarov on 30.06.2023.
//

import XCTest

struct DataSelector<ID: Hashable, Value> {

    private let data: [ID: Wrapped]
    
    init(data: [Wrapped]) {
        
        self.data = .init(
            uniqueKeysWithValues: zip(
                data.map(\.id),
                data
            )
        )
    }
    
    func select(ids: [ID]) -> [Value] {
        
        return ids.compactMap { data[$0]?.value }
    }
    
    struct Wrapped {
        
        let id: ID
        let value: Value
    }
}

extension DataSelector where Value: Identifiable, ID == Value.ID {
    
    init(values: [Value]) {
        
        self.init(data: values.map { .init(id: $0.id, value: $0) })
    }
}

final class DataSelectorTests: XCTestCase {
    
    func test_select_shouldReturnEmptyOnEmptyIDsEmptyData() {
        
        let ids: [String] = []
        let data: [Wrapped] = []
        let selector = makeSUT(data: data)
        
        let selected = selector.select(ids: ids)
        
        XCTAssertTrue(selected.isEmpty)
        XCTAssertTrue(ids.isEmpty)
        XCTAssertTrue(data.isEmpty)
    }
    
    func test_select_shouldReturnEmptyOnEmptyIDsNonEmptyData() {
        
        let ids: [String] = []
        let data: [Wrapped] = [
            .init(id: "a", value: .init(name: "A"))
        ]
        let selector = makeSUT(data: data)
        
        let selected = selector.select(ids: ids)
        
        XCTAssertTrue(selected.isEmpty)
        XCTAssertTrue(ids.isEmpty)
        XCTAssertFalse(data.isEmpty)
    }
    
    func test_select_shouldReturnEmptyOnNonEmptyIDsEmptyData() {
        
        let ids: [String] = ["a"]
        let data: [Wrapped] = []
        let selector = makeSUT(data: data)
        
        let selected = selector.select(ids: ids)
        
        XCTAssertTrue(selected.isEmpty)
        XCTAssertFalse(ids.isEmpty)
        XCTAssertTrue(data.isEmpty)
    }
    
    func test_select_shouldReturnEmptyOnNonMatchingIDsNonEmptyData() {
        
        let ids: [String] = ["b"]
        let data: [Wrapped] = [
            .init(id: "a", value: .init(name: "A"))
        ]
        let selector = makeSUT(data: data)
        
        let selected = selector.select(ids: ids)
        
        XCTAssertTrue(selected.isEmpty)
        XCTAssertFalse(ids.isEmpty)
        XCTAssertFalse(data.isEmpty)
        
        let matching = Set(data.map(\.id)).intersection(.init(ids))
        XCTAssertTrue(matching.isEmpty)
    }
    
    func test_select_shouldReturnMatchingOnMatchingIDsNonEmptyData() {
        
        let ids: [String] = ["b"]
        let data: [Wrapped] = [
            .init(id: "a", value: .init(name: "A")),
            .init(id: "b", value: .init(name: "B")),
        ]
        let selector = makeSUT(data: data)
        
        let selected = selector.select(ids: ids)
        
        XCTAssertNoDiff(selected, [.init(name: "B")])
        XCTAssertFalse(ids.isEmpty)
        XCTAssertFalse(data.isEmpty)
        
        let matching = Set(data.map(\.id)).intersection(.init(ids))
        XCTAssertNoDiff(matching, ["b"])
    }
    
    func test_select_shouldReturnMatchingOrderedByIDs() {
        
        let ids: [String] = ["c", "b"]
        let data: [Wrapped] = [
            .init(id: "a", value: .init(name: "A")),
            .init(id: "b", value: .init(name: "B")),
            .init(id: "c", value: .init(name: "C")),
        ]
        let selector = makeSUT(data: data)
        
        let selected = selector.select(ids: ids)
        
        XCTAssertNoDiff(selected, [
            .init(name: "C"),
            .init(name: "B"),
        ])
        XCTAssertFalse(ids.isEmpty)
        XCTAssertFalse(data.isEmpty)
        
        let matching = Set(data.map(\.id)).intersection(.init(ids))
        XCTAssertNoDiff(matching, ["b", "c"])
    }
    
    // MARK: - Helpers
    
    typealias TestSelector = DataSelector<String, TestItem>
    typealias Wrapped = TestSelector.Wrapped
    
    private func makeSUT(data: [Wrapped]) -> TestSelector {
        
        .init(data: data)
    }
}

enum DetailID {
    
    case payeeFullName
    case payeeAccountNumber
    case payeeINN
    case payeeKPP
    case payeeBankBIC
    case amount
    case payerFee
    case payerID // `payerCardId` or `payerAccountId`
    case comment
    case dateForDetail
}

extension Array where Element == DetailID {
    
    // Физ.лицу
    static let person: Self = [
        .payeeFullName,
        .payeeAccountNumber,
        .payeeBankBIC,
        .amount,
        .payerFee,
        .payerID,
        .comment,
        .dateForDetail,
    ]
    
    // ИП
    static let indi: Self = [
        .payeeFullName,
        .payeeAccountNumber,
        .payeeINN,
        .payeeBankBIC,
        .amount,
        .payerFee,
        .payerID,
        .comment,
        .dateForDetail,
    ]
    
    // Юр.лицу
    static let company: Self = [
        .payeeFullName,
        .payeeAccountNumber,
        .payeeINN,
        .payeeKPP,
        .payeeBankBIC,
        .amount,
        .payerFee,
        .payerID,
        .comment,
        .dateForDetail,
    ]
}
