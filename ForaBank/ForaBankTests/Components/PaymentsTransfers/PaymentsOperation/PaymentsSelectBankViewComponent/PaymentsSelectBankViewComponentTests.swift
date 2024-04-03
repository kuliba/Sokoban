//
//  PaymentsSelectBankViewComponentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 19.04.2023.
//

import XCTest
@testable import ForaBank

final class PaymentsSelectBankViewComponentTests: XCTestCase {

    func test_init_noSelection() throws {

        let sut = try makeSut()
        
        XCTAssertEqual(sut.value.current, nil)
        XCTAssertFalse(sut.isValid)
        
        guard case let .collapsed(collapsedViewModel) = sut.state else {
            XCTFail("state must be in collapsed state")
            return
        }
        
        XCTAssertEqual(collapsedViewModel.title, .empty(title: "Банк получателя"))
    }
    
    func test_init_selectedOption_bic() throws {

        let sut = try makeSut(selectedOptionId: "0", options: [.sber, .alfa])
        
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        
        guard case let .collapsed(collapsedViewModel) = sut.state else {
            XCTFail("state must be in collapsed state")
            return
        }
        
        XCTAssertEqual(collapsedViewModel.title, .selected(title: "Банк получателя", name: "0445566"))
    }
    
    func test_init_selectedOption_name() throws {

        let sut = try makeSut(selectedOptionId: "0", options: [.sberNoSubTitle, .alfaNoSubtitle])
        
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        
        guard case let .collapsed(collapsedViewModel) = sut.state else {
            XCTFail("state must be in collapsed state")
            return
        }
        
        XCTAssertEqual(collapsedViewModel.title, .selected(title: "Банк получателя", name: "Сбербанк"))
    }
    
    func test_init_noSelection_emptyOptionsList() throws {

        XCTAssertThrowsError(try makeSut(selectedOptionId: nil, options: []))
    }
    
    func test_init_selectedOption_emptyOptionsList() throws {

        XCTAssertThrowsError(try makeSut(selectedOptionId: "0", options: []))
    }
    
    func test_noSelection_toggleList() throws {

        // given
        let sut = try makeSut()
        
        // when
        sut.action.send(PaymentsParameterViewModelAction.SelectBank.List.Toggle())
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(sut.value.current, nil)
        XCTAssertFalse(sut.isValid)
        
        guard case let .expanded(expandedViewModel) = sut.state else {
            XCTFail("state must be in expanded state")
            return
        }
        
        XCTAssertEqual(expandedViewModel.title, "Банк получателя")
        
        guard case let .placeholder(placeholderText) = expandedViewModel.textField.state else {
            XCTFail("textField must be in placeholder state")
            return
        }
        
        XCTAssertEqual(placeholderText, "Выберите банк")
        
        guard case let .filtered(selectAll: selectAllViewModel, banks: banksList) = expandedViewModel.list else {
            XCTFail("list state must be in filtered state")
            return
        }
        
        XCTAssertNil(selectAllViewModel)
        
        XCTAssertEqual(banksList.count, 2)
        
        XCTAssertEqual(banksList[0].id, "0")
        XCTAssertEqual(banksList[0].name, "Сбербанк")
        XCTAssertEqual(banksList[0].subtitle, "0445566")
        XCTAssertEqual(banksList[0].searchValue, "0445566")
        
        XCTAssertEqual(banksList[1].id, "1")
        XCTAssertEqual(banksList[1].name, "Альфа-банк")
        XCTAssertEqual(banksList[1].subtitle, "0447788")
        XCTAssertEqual(banksList[1].searchValue, "0447788")
    }
    
    func test_selected_toggleList() throws {

        // given
        let sut = try makeSut(selectedOptionId: "1")
        
        // when
        sut.action.send(PaymentsParameterViewModelAction.SelectBank.List.Toggle())
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(sut.value.current, "1")
        XCTAssertTrue(sut.isValid)
        
        guard case let .expanded(expandedViewModel) = sut.state else {
            XCTFail("state must be in expanded state")
            return
        }
        
        XCTAssertEqual(expandedViewModel.title, "Банк получателя")
        
        guard case let .placeholder(placeholderText) = expandedViewModel.textField.state else {
            XCTFail("textField must be in placeholder state")
            return
        }
        
        XCTAssertEqual(placeholderText, "0447788")
        
        guard case let .filtered(selectAll: selectAllViewModel, banks: banksList) = expandedViewModel.list else {
            XCTFail("list state must be in filtered state")
            return
        }
        
        XCTAssertNil(selectAllViewModel)
        
        XCTAssertEqual(banksList.count, 2)
        
        XCTAssertEqual(banksList[0].id, "0")
        XCTAssertEqual(banksList[0].name, "Сбербанк")
        XCTAssertEqual(banksList[0].subtitle, "0445566")
        XCTAssertEqual(banksList[0].searchValue, "0445566")
        
        XCTAssertEqual(banksList[1].id, "1")
        XCTAssertEqual(banksList[1].name, "Альфа-банк")
        XCTAssertEqual(banksList[1].subtitle, "0447788")
        XCTAssertEqual(banksList[1].searchValue, "0447788")
    }
    
    func test_selected_toggleList_EditingDisabled() throws {

        // given
        let sut = try makeSut(selectedOptionId: "0")
        sut.updateEditable(update: .value(false))
        
        // when
        sut.action.send(PaymentsParameterViewModelAction.SelectBank.List.Toggle())
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        XCTAssertFalse(sut.isEditable)
        
        guard case let .collapsed(collapsedViewModel) = sut.state else {
            XCTFail("state must be in collapsed state")
            return
        }
        
        XCTAssertEqual(collapsedViewModel.title, .selected(title: "Банк получателя", name: "0445566"))
    }
    
    func test_expanded_toggleList_EditingDisabled() throws {

        // given
        let sut = try makeSut(selectedOptionId: "0")
        // expand
        sut.action.send(PaymentsParameterViewModelAction.SelectBank.List.Toggle())

        // when
        sut.updateEditable(update: .value(false))
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        XCTAssertFalse(sut.isEditable)
        
        guard case let .collapsed(collapsedViewModel) = sut.state else {
            XCTFail("state must be in collapsed state")
            return
        }
        
        XCTAssertEqual(collapsedViewModel.title, .selected(title: "Банк получателя", name: "0445566"))
    }
    
    func test_selectDefaultBank_shouldChangeValue() throws {

        let sut = try makeSut(selectedOptionId: "0")
        sut.selectDefaultBank(.success([.init(
            bankId: "1",
            bankName: "bankName",
            payment: true,
            defaultBank: true
        )]))
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.value.current, "1")
    }
    
    func test_selectNotDefaultBank_shouldChangeValue() throws {

        let sut = try makeSut(selectedOptionId: "0")
        sut.selectDefaultBank(.success([.init(
            bankId: "1",
            bankName: "bankName",
            payment: true,
            defaultBank: false
        )]))
        
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.value.current, "0")
    }
}

private extension PaymentsSelectBankViewComponentTests {
    
    func makeSut(selectedOptionId: String? = nil, options: [Payments.ParameterSelectBank.Option] = .sampleOptionsBic, selectAll: Payments.ParameterSelectBank.SelectAllOption? = nil) throws -> PaymentsSelectBankView.ViewModel {
        
        try PaymentsSelectBankView.ViewModel(
            with: .init(
                .init(id: "bank_param_id", value: selectedOptionId),
                icon: .init(with: .make(withColor: .red))!,
                title: "Банк получателя",
                options: options,
                placeholder: "Выберите банк",
                selectAll: selectAll,
                keyboardType: .normal),
            model: .emptyMock)
    }
}

private extension Payments.ParameterSelectBank.Option {

    static let sber: Self = .init(id: "0", name: "Сбербанк", subtitle: "0445566", icon: nil, isFavorite: false, searchValue: "0445566")
  static let sberNoSubTitle: Self = .init(id: "0", name: "Сбербанк", subtitle: nil, icon: nil, isFavorite: false, searchValue: "0445566")

  static let alfa: Self = .init(id: "1", name: "Альфа-банк", subtitle: "0447788", icon: nil, isFavorite: false, searchValue: "0447788")
  static let alfaNoSubtitle: Self = .init(id: "1", name: "Альфа-банк", subtitle: nil, icon: nil, isFavorite: false, searchValue: "0447788")
}

private extension Array where Element == Payments.ParameterSelectBank.Option {

    static let sampleOptionsBic: Self = [.sber, .alfa]
}
