//
//  RootViewModelFactory+makeOpenNewProductButtonsTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 16.01.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_makeOpenNewProductButtonsTests: RootViewModelFactoryTests {
    
    func test_savingsAccountFlagActive_shouldReturnButtonsWithSavingsAccountButton() {
        
        let sut = makeSUT(
            collateralLoanFlag: .active,
            savingsAccountFlag: .active
        )
        
        XCTAssertNoDiff(
            sut.map(\.id),
            [
                .card, .deposit, .account, .sticker, .loan,
                .savingsAccount,
                .insurance, .mortgage
            ]
        )
    }
    
    func test_savingsAccountFlagInActive_shouldReturnButtonsWithoutSavingsAccountButton() {
        
        let sut = makeSUT(
            collateralLoanFlag: .active,
            savingsAccountFlag: .inactive
        )
        
        XCTAssertNoDiff(
            sut.map(\.id),
            [
                .card, .deposit, .account, .sticker, .loan,
                .insurance, .mortgage
            ]
        )
    }
    
    // MARK: - collateralLoanFlag
    
    func test_collateralLoanFlagActive_shouldReturnActionForLoan() {
        
        let sut = makeSUT(
            collateralLoanFlag: .active,
            savingsAccountFlag: .inactive
        )
        
        assert(sut, openProductType: .loan, type: .action)
    }
    
    func test_collateralLoanFlagInActive_shouldReturnUrlActionForLoan() {
        
        let sut = makeSUT(
            collateralLoanFlag: .inactive,
            savingsAccountFlag: .inactive
        )
        
        assert(sut, openProductType: .loan, type: .url)
    }
    
    // MARK: - savingsAccountFlag
    
    func test_savingsAccountFlagFlagActive_shouldReturnActionForSavingsAccount() {
        
        let sut = makeSUT(
            collateralLoanFlag: .active,
            savingsAccountFlag: .active
        )
        
        assert(sut, openProductType: .savingsAccount, type: .action)
    }
    
    func test_savingsAccountFlagFlagInActive_shouldReturnNilActionForSavingsAccount() {
        
        let sut = makeSUT(
            collateralLoanFlag: .active,
            savingsAccountFlag: .inactive
        )
        
        assert(sut, openProductType: .savingsAccount, type: nil)
    }
    
    // MARK: - Helpers
    
    typealias ViewModel = NewProductButton.ViewModel
    typealias TapAction = ViewModel.TapActionType
    
    private func makeSUT(
        collateralLoanFlag: CollateralLoanLandingFlag,
        savingsAccountFlag: SavingsAccountFlag
    ) -> [ViewModel] {
        
        let (sut, _, _) = makeSUT()
        
        return sut.makeOpenNewProductButtons(
            collateralLoanLandingFlag: collateralLoanFlag,
            savingsAccountFlag: savingsAccountFlag,
            action: { _ in }
        )
    }
    
    private func assert(
        _ buttons: [ViewModel],
        openProductType: OpenProductType,
        type: _TapAction?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let button = buttons.first(where: { $0.id == openProductType.rawValue })
        
        XCTAssertNoDiff(button?.tapActionType.type, type, "Expected \(String(describing: type)), but got \(String(describing: button?.tapActionType.type)) instead.", file: file, line: line)
    }
}

private enum _TapAction {
    
    case action
    case url
}

private extension NewProductButton.ViewModel.TapActionType {
    
    var type: _TapAction {
        
        switch self {
        case .action:   return .action
        case .url:      return .url
        }
    }
}

private extension String {
    
    static let account = OpenProductType.account.rawValue
    static let card = OpenProductType.card.rawValue
    static let deposit = OpenProductType.deposit.rawValue
    static let insurance = OpenProductType.insurance.rawValue
    static let loan = OpenProductType.loan.rawValue
    static let mortgage = OpenProductType.mortgage.rawValue
    static let savingsAccount = OpenProductType.savingsAccount.rawValue
    static let sticker = OpenProductType.sticker.rawValue
}
