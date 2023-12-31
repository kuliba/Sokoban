//
//  BanksTests.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import XCTest

final class BanksTests: XCTestCase {
    
    func test_selectedBanks_shouldListSelectedFirst() {
        
        let banks: Banks = .stub(
            all: [.a, .b, .c, .d],
            selected: [.b, .d]
        )
        
        XCTAssertNoDiff(banks.withSelection, [
            .init(bank: .b, isSelected: true),
            .init(bank: .d, isSelected: true),
            .init(bank: .a, isSelected: false),
            .init(bank: .c, isSelected: false),
        ])
    }
    
    func test_selectedBanks_shouldSort() {
        
        let banks: Banks = .stub(
            all: [.d, .b, .a, .c],
            selected: [.b, .d]
        )
        
        XCTAssertNoDiff(banks.withSelection, [
            .init(bank: .b, isSelected: true),
            .init(bank: .d, isSelected: true),
            .init(bank: .a, isSelected: false),
            .init(bank: .c, isSelected: false),
        ])
    }
}

private extension Banks {
    
    static func stub(
        all allBanks: [Bank],
        selected: [Bank]
    ) -> Self {
        
        .init(
            allBanks: allBanks,
            selected: .init(selected.map(\.id))
        )
    }
}

private extension Bank {
    
    static let a: Self = .init(id: "a", name: "A")
    static let b: Self = .init(id: "b", name: "B")
    static let c: Self = .init(id: "c", name: "C")
    static let d: Self = .init(id: "d", name: "D")
}
