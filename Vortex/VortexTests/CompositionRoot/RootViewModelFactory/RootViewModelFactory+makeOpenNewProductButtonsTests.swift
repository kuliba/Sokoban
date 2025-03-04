//
//  RootViewModelFactory+makeOpenNewProductButtonsTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 16.01.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_makeOpenNewProductButtonsTests: RootViewModelFactoryTests {
    
    func test_makeOpenNewProductButtons_shouldReturnButtonsWithSavingsAccountButton() {
        
        let sut = makeSUT(
            collateralLoanFlag: .active
        )
        
        XCTAssertNoDiff(sut.map(\.type), [
            .card(.landing), .deposit, .account, .sticker, .loan,
            .savingsAccount,
            .insurance, .mortgage
        ])
    }
    
    // MARK: - collateralLoanFlag
    
    func test_collateralLoanFlagActive_shouldReturnActionForLoan() {
        
        let sut = makeSUT(
            collateralLoanFlag: .active
        )
        
        assert(sut, openProductType: .loan, type: .action)
    }
    
    func test_collateralLoanFlagInActive_shouldReturnUrlActionForLoan() {
        
        let sut = makeSUT(
            collateralLoanFlag: .inactive
        )
        
        assert(sut, openProductType: .loan, type: .url)
    }
    
    // MARK: - savingsAccount
    
    func test_openProduct_savingsAccount_shouldReturnActionForSavingsAccount() {
        
        let sut = makeSUT(
            collateralLoanFlag: .active
        )
        
        assert(sut, openProductType: .savingsAccount, type: .action)
    }
        
    // MARK: - Helpers
    
    typealias ViewModel = NewProductButton.ViewModel
    typealias TapAction = ViewModel.TapActionType
    
    private func makeSUT(
        collateralLoanFlag: CollateralLoanLandingFlag
    ) -> [ViewModel] {
        
        let (sut, _, _) = makeSUT()
        
        return sut.makeOpenNewProductButtons(
            collateralLoanLandingFlag: collateralLoanFlag,
            action: { _ in }
        )
    }
        
    private func assert(
        _ buttons: [ViewModel],
        openProductType: OpenProductType,
        type: EquatableTapAction?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let button = buttons.first(where: { $0.type == openProductType })
        
        XCTAssertNoDiff(button?.tapActionType.type, type, "Expected \(String(describing: type)), but got \(String(describing: button?.tapActionType.type)) instead.", file: file, line: line)
    }
}

private enum EquatableTapAction {
    
    case action
    case url
}

private extension NewProductButton.ViewModel.TapActionType {
    
    var type: EquatableTapAction {
        
        switch self {
        case .action:   return .action
        case .url:      return .url
        }
    }
}
