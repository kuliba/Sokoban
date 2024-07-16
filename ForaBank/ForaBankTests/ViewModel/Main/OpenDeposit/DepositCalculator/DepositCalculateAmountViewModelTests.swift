//
//  DepositCalculateAmountViewModelTests.swift
//  ForaBankTests
//
//  Created by Andrew Kurdin on 18.06.2024.
//

@testable import ForaBank
import XCTest

final class DepositCalculateAmountViewModelTests: XCTestCase {
    
    func test_shouldChangeCharactersIn_whenTextFieldIsEmpty_shouldReturnFalseAndUpdateValue() {
        
        let initialValue = 0.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue, "Initial value should be \(initialValue)")
        
        let shouldChange = updateViewModel(viewModel, textFieldText: "", replacementString: "123")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, 123)
    }
    
    func test_shouldChangeCharactersIn_whenReplacementStringIsEmpty_shouldRemoveLastCharacterAndReturnTrue() {
        
        let initialValue = 1000.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue, "Initial value should be \(initialValue)")
        
        let shouldChange = updateViewModel(viewModel, textFieldText: "1000", replacementString: "")
        
        XCTAssertTrue(shouldChange)
        XCTAssertEqual(viewModel.value, 100)
    }
    
    func test_shouldChangeCharactersIn_whenFilteredStartsWithZero_shouldRemoveLeadingZeroAndUpdateValue() {
        
        let initialValue = 1000.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue)
        
        let shouldChange = updateViewModel(viewModel, textFieldText: "1000", replacementString: "01")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, 100001)
    }
    
    func test_shouldChangeCharactersIn_whenValueIsWithinBounds_shouldUpdateValue() {
        
        let initialValue = 1000.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue)
        
        let shouldChange = updateViewModel(viewModel, textFieldText: "1000", replacementString: "00")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, 100000)
    }
    
    func test_shouldChangeCharactersIn_whenValueIsOutOfBounds_shouldNotUpdateValue() {
        
        let initialValue = 1000.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue)
        
        let shouldChange = updateViewModel(viewModel, textFieldText: "1000", replacementString: "000000")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, initialValue)
    }
    
    func test_shouldChangeCharactersIn_whenFilteredIsEmpty_shouldReturnFalse() {
        
        let initialValue = 1000.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue)
        
        let shouldChange = updateViewModel(viewModel, textFieldText: "1000", replacementString: "a")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, initialValue)
    }
    
    func test_shouldChangeCharactersIn_whenFilteredIsNotEmpty_shouldReturnFalseAndUpdateValue() {
        
        let initialValue = 3334.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue)
        
        let shouldChange = updateViewModel(viewModel, textFieldText: "3334", replacementString: "5")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, 33345)
    }
    
    func test_shouldChangeCharactersIn_whenTextFieldTextIsEmpty_shouldReturnFalseAndUpdateValue() {
        
        let initialValue = 0.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue)
        
        let shouldChange = updateViewModel(viewModel, textFieldText: "", replacementString: "5")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, 5)
    }
    
    func test_shouldChangeCharactersIn_whenTextFieldTextIsNil_shouldReturnTrue() {
        
        let initialValue = 0.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue)
        
        let shouldChange = updateViewModel(viewModel, textFieldText: nil, replacementString: "")
        
        XCTAssertTrue(shouldChange)
        XCTAssertEqual(viewModel.value, initialValue)
    }
    
    func test_shouldChangeCharactersIn_whenFilteredStartsWithZeroAndLengthEqualToOne_shouldReturnFalseAndUpdateValue() {
        
        let initialValue = 1.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue)
        
        let shouldChange = updateViewModel(viewModel, textFieldText: "01", replacementString: "5")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, 15)
    }
    
    func test_shouldChangeCharactersIn_whenStartsWithZeroAndLengthEqualToOne_shouldReturnFalseAndUpdateValueToMinBound() {
        
        let initialValue = 1000.0
        let viewModel = makeSUT(initialValue: initialValue)
        
        XCTAssertEqual(viewModel.value, initialValue)
        
        let shouldChange = updateViewModel(viewModel, textFieldText: "1000", replacementString: "0")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, 10000)
    }
    
    func test_shouldChangeCharactersIn_whenInputStartsWithZero_shouldRemoveLeadingZero() {
        
        let viewModel = makeSUT(initialValue: 0)
        let shouldChange = updateViewModel(viewModel, textFieldText: "0", replacementString: "100")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, 100)
    }

    func test_shouldChangeCharactersIn_whenInputHasMultipleLeadingZeros_shouldRemoveAllLeadingZeros() {
        
        let viewModel = makeSUT(initialValue: 0)
        let shouldChange = updateViewModel(viewModel, textFieldText: "0", replacementString: "00100")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, 100)
    }

    func test_shouldChangeCharactersIn_whenInputIsOnlyZero_shouldKeepZero() {
        
        let viewModel = makeSUT(initialValue: 0)
        let shouldChange = updateViewModel(viewModel, textFieldText: "", replacementString: "0")
        
        XCTAssertFalse(shouldChange)
        XCTAssertEqual(viewModel.value, 0)
    }
    
    // MARK: Tests for TF DidEndEditing
    
    func test_textFieldDidEndEditing_whenValueIsLessThanLowerBound_shouldSetValueToLowerBound() {
        
        let (sut, textField) = makeSUTAndTextField(textFieldText: "5500")
        sut.textFieldDidEndEditing(textField)
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.value, 10000.0)
    }

    func test_textFieldDidEndEditing_whenValueIsWithinBounds_shouldSetValueToGivenValue() {
        
        let (sut, textField) = makeSUTAndTextField(textFieldText: "25000")
        sut.textFieldDidEndEditing(textField)
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.value, 25000.0)
    }

    func test_textFieldDidEndEditing_whenValueIsGreaterThanUpperBound_shouldSetValueToUpperBound() {
        
        let (sut, textField) = makeSUTAndTextField(textFieldText: "6000000")
        sut.textFieldDidEndEditing(textField)
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.value, 5000000.0)
    }

    func test_textFieldDidEndEditing_whenTFContainsInvalidValue_shouldSetTFTextToFormattedValueWithTrailingSpace() {
        
        let (sut, textField) = makeSUTAndTextField(textFieldText: "invalid")
        sut.textFieldDidEndEditing(textField)
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(textField.text, "1 500 000 ")
    }

    func test_textFieldDidEndEditing_whenTFContainsInvalidValue_shouldSetTFTextToFormattedValueFromViewModel() {
        
        let (sut, textField) = makeSUTAndTextField(textFieldText: "invalid")
        sut.textFieldDidEndEditing(textField)
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(textField.text, sut.valueCurrency)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        depositTerm: String = "Срок вклада",
        interestRate: String = "Процентная ставка",
        interestRateValue: Double = 5.0,
        depositAmount: String = "Сумма депозита",
        initialValue: Double = 1500000.0,
        isFirstResponder: Bool = false,
        depositValue: String = "1 500 000 ₽",
        minSum: Double = 10000.0,
        isShowBottomSheet: Bool = false,
        bounds: ClosedRange<Double> = 10000...5000000,
        file: StaticString = #file,
        line: UInt = #line
    ) -> DepositCalculateAmountViewModel {
        
        .init(
            depositTerm: depositTerm,
            interestRate: interestRate,
            interestRateValue: interestRateValue,
            depositAmount: depositAmount,
            value: initialValue,
            isFirstResponder: isFirstResponder,
            depositValue: depositValue,
            minSum: minSum,
            isShowBottomSheet: isShowBottomSheet,
            bounds: bounds
        )
    }
    
    private func makeSUTAndTextField(
        depositTerm: String = "Срок вклада",
        interestRate: String = "Процентная ставка",
        interestRateValue: Double = 5.0,
        depositAmount: String = "Сумма депозита",
        initialValue: Double = 1500000.0,
        isFirstResponder: Bool = false,
        depositValue: String = "1 500 000 ₽",
        minSum: Double = 10000.0,
        isShowBottomSheet: Bool = false,
        bounds: ClosedRange<Double> = 10000...5000000,
        textFieldText: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: DepositCalculateAmountViewModel, textField: UITextField) {
        
        let sut = DepositCalculateAmountViewModel(
            depositTerm: depositTerm,
            interestRate: interestRate,
            interestRateValue: interestRateValue,
            depositAmount: depositAmount,
            value: initialValue,
            isFirstResponder: isFirstResponder,
            depositValue: depositValue,
            minSum: minSum,
            isShowBottomSheet: isShowBottomSheet,
            bounds: bounds
        )
        let textField = UITextField()
        textField.text = textFieldText
        
        return (sut, textField)
    }
    
    private func updateViewModel(
        _ viewModel: DepositCalculateAmountViewModel,
        textFieldText: String?,
        range: NSRange = NSRange(location: 0, length: 0),
        replacementString: String
    ) -> Bool {
        
        let textField = UITextField()
        textField.text = textFieldText
        let coordinator = DepositCalculateAmountView.DepositCalculateTextField.Coordinator(viewModel: viewModel)
        
        return coordinator.textField(textField, shouldChangeCharactersIn: range, replacementString: replacementString)
    }
}
