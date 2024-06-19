//
//  DepositCalculateAmountViewModelTests.swift
//  ForaBankTests
//
//  Created by Andrew Kurdin on 18.06.2024.
//

@testable import ForaBank
import XCTest

final class DepositCalculateAmountViewModelTests: XCTestCase {
    
    func test_textFieldIsEmpty_shouldReturnFalseAndUpdateValue() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: "", replacementString: "123")
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.value, 123)
    }
    
    func test_stringIsEmpty_shouldRemoveLastCharacter() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: "1000", replacementString: "")
        
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.value, 100)
    }
    
    func test_filteredStartsWithZeroAndLengthGreaterThanOne_shouldRemoveLeadingZeroAndUpdateValue() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: "1000", replacementString: "01")
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.value, 100001.0)
    }
    
    func test_valueIsWithinBounds_shouldUpdateValue() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: "1000", replacementString: "00")
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.value, 100000)
    }
    
    func test_valueIsOutOfBounds_shouldNotUpdateValue() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: "1000", replacementString: "000000")
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.value, 1000)
    }
    
    func test_filteredIsEmpty_shouldReturnFalse() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: "1000", replacementString: "a")
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.value, 1000)
    }
    
    func test_filteredIsNotEmpty_shouldReturnFalseAndUpdateValue() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: "3334", replacementString: "5")
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.value, 33345.0)
    }
    
    func test_textFieldTextIsEmpty_shouldReturnFalseAndUpdateValue() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: "", replacementString: "5")
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.value, 5.0)
    }
    
    func test_textFieldTextIsNil_shouldReturnTrueAndNotUpdateValue() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: nil, replacementString: "")
        
        XCTAssertTrue(result)
        XCTAssertEqual(viewModel.value, 0.0)
    }
    
    func test_filteredStartsWithZeroAndLengthEqualToOne_shouldReturnFalseAndUpdateValue() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: "01", replacementString: "5")
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.value, 15.0)
    }
    
    func test_filteredStartsWithZeroAndLengthEqualToOne_shouldReturnFalseAndUpdateValueToMinBound() {
        
        let (viewModel, result) = makeDepositAndResult(textFieldText: "1000", replacementString: "0")
        
        XCTAssertFalse(result)
        XCTAssertEqual(viewModel.value, 10000)
    }
    
    // MARK: - Helpers
    
    private func makeDeposit(
        depositTerm: String = "Срок вклада",
        interestRate: String = "Процентная ставка",
        interestRateValue: Double = 5.0,
        depositAmount: String = "Сумма депозита",
        value: Double = 1500000.0,
        isFirstResponder: Bool = false,
        depositValue: String = "1 500 000 ₽",
        minSum: Double = 10000.0,
        isShowBottomSheet: Bool = false,
        bounds: ClosedRange<Double> = 10000...5000000,
        file: StaticString = #file,
        line: UInt = #line
    ) -> DepositCalculateAmountViewModel {
        
        let deposit = DepositCalculateAmountViewModel(
            depositTerm: depositTerm,
            interestRate: interestRate,
            interestRateValue: interestRateValue,
            depositAmount: depositAmount,
            value: value,
            isFirstResponder: isFirstResponder,
            depositValue: depositValue,
            minSum: minSum,
            isShowBottomSheet: isShowBottomSheet,
            bounds: bounds
        )
        
        return deposit
    }
    
    private func makeDepositAndResult(
        textFieldText: String?,
        range: NSRange = NSRange(location: 0, length: 0),
        replacementString: String,
        value: Double = 1000,
        bounds: ClosedRange<Double> = 10000...5000000
    ) -> (DepositCalculateAmountViewModel, Bool) {
        
        let viewModel = makeDeposit(value: value, bounds: bounds)
        let textField = UITextField()
        textField.text = textFieldText
        
        let coordinator = DepositCalculateAmountView.DepositCalculateTextField.Coordinator(viewModel: viewModel)
        let result = coordinator.textField(textField, shouldChangeCharactersIn: range, replacementString: replacementString)
        
        return (viewModel, result)
    }
}
