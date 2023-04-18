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
        
        XCTAssertEqual(optionsListViewModel.filterred, listOptions)
        XCTAssertNil(optionsListViewModel.selected)
    }
    
    func test_select_option() throws {
        
        // given
        let sut = makeSut(selectedOptionId: nil)

        guard case let .list(optionsListViewModel) = sut.state else {
            XCTFail("state must be in list case")
            return
        }
        
        // when
        optionsListViewModel.action.send(PaymentsParameterViewModelAction.Select.OptionsList.OptionSelected(optionId: "0"))
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
        
        XCTAssertEqual(optionsListViewModel.filterred, listOptions)
        XCTAssertEqual(optionsListViewModel.selected, "0")
    }
}

//MARK: - Helpers

private extension PaymentsSelectViewComponentTests {
    
    func makeSut(selectedOptionId: String?, options: [Payments.ParameterSelect.Option] = Payments.ParameterSelect.sampleOptions) -> PaymentsSelectView.ViewModel {
        
        PaymentsSelectView.ViewModel(
            with: .init(
                .init(
                    id: UUID().uuidString,
                    value: selectedOptionId),
                icon: .name("ic24Bank"),
                title: "Тип оплаты",
                placeholder: "Выберете тип",
                options: options))
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
