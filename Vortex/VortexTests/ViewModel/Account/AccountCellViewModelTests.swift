//
//  AccountCellViewModelTests.swift
//  VortexTests
//
//  Created by Дмитрий Савушкин on 09.08.2023.
//

import Foundation

import XCTest
@testable import Vortex

final class AccountCellViewModelTests: XCTestCase {
    
    func test_init_button_setButtonIconNil_styleNormal() {
        
        let sut = makeSUT(
            button: .init(icon: nil, action: {}),
            style: .regular
        )
        
        XCTAssertNoDiff(sut.content, "content")
        XCTAssertNoDiff(sut.style, .regular)
        XCTAssertNoDiff(sut.button.icon, nil)
    }
}

extension AccountCellViewModelTests {
    
    func makeSUT(
        button: AccountCellButtonView.ButtonView.ViewModel,
        style: AccountCellButtonView.ViewModel.Style
    ) -> AccountCellButtonView.ViewModel {
        
        let accountCellViewModel = AccountCellButtonView.ViewModel(
            icon: .ic12ArrowDown,
            content: "content",
            button: .init(
                icon: nil,
                action: {}
            ),
            style: .regular
        )
        
        return accountCellViewModel
    }
}
