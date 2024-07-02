//
//  PaymentsSelectViewComponentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 15.04.2023.
//

import XCTest
@testable import ForaBank

final class PaymentsSelectViewComponentTests: XCTestCase {
    
    func test_init_selectedOption() throws {
        
        let sut = makeSut(selectedOptionId: "0")
        
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        
        guard case let .selected(selectedOptionViewModel) = sut.state else {
            XCTFail("state must be in selected case")
            return
        }
        
        guard case .image24(_) = selectedOptionViewModel.icon else {
            XCTFail("icon must be .image24")
            return
        }
        XCTAssertEqual(selectedOptionViewModel.title, "Тип оплаты")
        XCTAssertEqual(selectedOptionViewModel.name, "Оплата наличными")
    }
    
    func test_init_no_selectedOption() throws {
        
        let sut = makeSut(selectedOptionId: nil)
        
        XCTAssertEqual(sut.value.current, nil)
        XCTAssertFalse(sut.isValid)
        
        guard case let .list(optionsListViewModel) = sut.state else {
            XCTFail("state must be in list case")
            return
        }
        
        guard case .image24(_) = optionsListViewModel.icon else {
            XCTFail("icon must be .image24")
            return
        }
        XCTAssertEqual(optionsListViewModel.title, "Тип оплаты")
        
        guard case let .placeholder(placeholderText) = optionsListViewModel.textField.state else {
            XCTFail("textfield state must be a placeholder")
            return
        }
        XCTAssertEqual(placeholderText, "Выберете тип")
        
        XCTAssertEqual(optionsListViewModel.filtered, listOptions)
        XCTAssertNil(optionsListViewModel.selected)
    }
    
    func test_select_option() throws {
        
        // given
        let sut = makeSut(selectedOptionId: nil)
        
        // when
        sut.action.send(PaymentsParameterViewModelAction.Select.OptionsList.OptionSelected(optionId: "0"))
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        
        guard case let .selected(selectedOptionViewModel) = sut.state else {
            XCTFail("state must be in selected case")
            return
        }
        
        guard case .image24(_) = selectedOptionViewModel.icon else {
            XCTFail("icon must be .image24")
            return
        }
        XCTAssertEqual(selectedOptionViewModel.title, "Тип оплаты")
        XCTAssertEqual(selectedOptionViewModel.name, "Оплата наличными")
    }
    
    func test_init_show_list_option_selected() throws {
        
        // given
        let sut = makeSut(selectedOptionId: "0")
        
        // when
        sut.action.send(PaymentsParameterViewModelAction.Select.ToggleList())
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        
        guard case let .list(optionsListViewModel) = sut.state else {
            XCTFail("state must be in list case")
            return
        }
        
        guard case .image24(_) = optionsListViewModel.icon else {
            XCTFail("icon must be .image24")
            return
        }
        XCTAssertEqual(optionsListViewModel.title, "Тип оплаты")
        
        guard case let .placeholder(placeholderText) = optionsListViewModel.textField.state else {
            XCTFail("textfield state must be a placeholder")
            return
        }
        XCTAssertEqual(placeholderText, "Оплата наличными")
        
        XCTAssertEqual(optionsListViewModel.filtered, listOptions)
        XCTAssertEqual(optionsListViewModel.selected, "0")
    }
    
    func test_collapsed_EditingDisabled() throws {
        
        // given
        let sut = makeSut(selectedOptionId: "0")
        sut.updateEditable(update: .value(false))
        
        // when
        sut.action.send(PaymentsParameterViewModelAction.Select.ToggleList())
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        XCTAssertFalse(sut.isEditable)
        
        guard case let .selected(selectedOptionViewModel) = sut.state else {
            XCTFail("state must be in selected case")
            return
        }
        
        guard case .image24(_) = selectedOptionViewModel.icon else {
            XCTFail("icon must be .image24")
            return
        }
        XCTAssertEqual(selectedOptionViewModel.title, "Тип оплаты")
        XCTAssertEqual(selectedOptionViewModel.name, "Оплата наличными")
    }
    
    func test_expanded_EditingDisabled() throws {
        
        // given
        let sut = makeSut(selectedOptionId: "0")
        sut.action.send(PaymentsParameterViewModelAction.Select.ToggleList())
        
        // when
        sut.updateEditable(update: .value(false))
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        XCTAssertFalse(sut.isEditable)
        
        guard case let .selected(selectedOptionViewModel) = sut.state else {
            XCTFail("state must be in selected case")
            return
        }
        
        guard case .image24(_) = selectedOptionViewModel.icon else {
            XCTFail("icon must be .image24")
            return
        }
        XCTAssertEqual(selectedOptionViewModel.title, "Тип оплаты")
        XCTAssertEqual(selectedOptionViewModel.name, "Оплата наличными")
    }
    
    // Convinience init
    
    func test_getPlaceholder_withSelectedOption() {
        
        let parameterSelect = makeParameterSelect(id: Payments.Parameter.Identifier.requisitsKpp.rawValue, selectedOptionId: "0")
        let selectedOption = parameterSelect.options.first
        let placeholder = OptionsListVM.getPlaceholder(parameterSelect: parameterSelect, selectedOption: selectedOption)
        
        XCTAssertEqual(placeholder, "Оплата наличными")
    }
    
    func test_getPlaceholder_withoutSelectedOption() {
        
        let parameterSelect = makeParameterSelect(id: Payments.Parameter.Identifier.requisitsKpp.rawValue, selectedOptionId: nil)
        let placeholder = OptionsListVM.getPlaceholder(parameterSelect: parameterSelect, selectedOption: nil)
        
        XCTAssertEqual(placeholder, "Выберите из")
    }
    
    func test_getKeyboardType_requisitsKpp() {
        
        let parameterSelect = makeParameterSelect(id: Payments.Parameter.Identifier.requisitsKpp.rawValue, selectedOptionId: "0")
        let keyboardType = OptionsListVM.getKeyboardType(parameterSelect: parameterSelect)
        
        XCTAssertEqual(keyboardType, .number)
    }
    
    func test_getKeyboardType_default() {
        
        let parameterSelect = makeParameterSelect(id: "someOtherId", selectedOptionId: "0")
        let keyboardType = OptionsListVM.getKeyboardType(parameterSelect: parameterSelect)
        
        XCTAssertEqual(keyboardType, .default)
    }
    
    func test_getLimit_requisitsKpp() {
        
        let parameterSelect = makeParameterSelect(id: Payments.Parameter.Identifier.requisitsKpp.rawValue, selectedOptionId: "0")
        let limit = OptionsListVM.getLimit(parameterSelect: parameterSelect)
        
        XCTAssertEqual(limit, 9)
    }
    
    func test_getLimit_default() {
        
        let parameterSelect = makeParameterSelect(id: "someOtherId", selectedOptionId: "0")
        let limit = OptionsListVM.getLimit(parameterSelect: parameterSelect)
        
        XCTAssertNil(limit)
    }
    
    // MARK: - Is Disabled TextField
   
    func test_isDisabledTF_withKppTitle_shouldReturnTrue() {
        
        let sut = makeSut(selectedOptionId: nil, title: "КПП получателя")
        if case let .list(optionsListViewModel) = sut.state {
            
            XCTAssertTrue(optionsListViewModel.isDisabledTF(optionsListViewModel.title))
        }
    }
    
    func test_isDisabledTF_withNonKppTitle_shouldReturnFalse() {
        
        let sut = makeSut(selectedOptionId: nil, title: "Тип оплаты")
        if case let .list(optionsListViewModel) = sut.state {
            
            XCTAssertFalse(optionsListViewModel.isDisabledTF(optionsListViewModel.title))
        }
    }
    
    func test_isDisabledTF_withEmptyString_shouldReturnFalse() {
        
        let sut = makeSut(selectedOptionId: nil, title: "")
        if case let .list(optionsListViewModel) = sut.state {
            
            XCTAssertFalse(optionsListViewModel.isDisabledTF(optionsListViewModel.title))
        }
    }
}

//MARK: - Helpers

private extension PaymentsSelectViewComponentTests {
    
    typealias OptionsListVM = PaymentsSelectView.ViewModel.OptionsListViewModel
    
    func makeSut(
        selectedOptionId: String?,
        title: String = "Тип оплаты",
        options: [Payments.ParameterSelect.Option] = Payments.ParameterSelect.sampleOptions) -> PaymentsSelectView.ViewModel {
        
        PaymentsSelectView.ViewModel(
            with: .init(
                .init(
                    id: UUID().uuidString,
                    value: selectedOptionId),
                icon: .name("ic24Bank"),
                title: title,
                placeholder: "Выберете тип",
                options: options))
    }
    
    private func makeParameterSelect(id: String, selectedOptionId: String?) -> Payments.ParameterSelect {
        
        return Payments.ParameterSelect(
            .init(
                id: id,
                value: id
            ),
            title: "Выберете тип",
            placeholder: "Выберите из",
            options: [
                Payments.ParameterSelect.Option(id: "0", name: "Оплата наличными"),
                Payments.ParameterSelect.Option(id: "1", name: "Оплата переводом")
            ]
        )
    }
    
    var listOptions: [PaymentsSelectView.ViewModel.OptionViewModel] {
        
        [
            .init(id: "0", icon: .circle, name: "Оплата наличными"),
            .init(id: "1", icon: .circle, name: "Оплата переводом")
        ]
    }
}

private extension Payments.ParameterSelect {
    
    static let sampleOptions: [Payments.ParameterSelect.Option] =  [
        .init(id: "0", name: "Оплата наличными"),
        .init(id: "1", name: "Оплата переводом")
    ]
}

private struct EmptyReducer<State, Event>: Reducer {
    
    func reduce(_ state: State, _ event: Event, _ completion: @escaping (State) -> Void) {
        completion(state)
    }
}
