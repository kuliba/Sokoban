//
//  PaymentsSelectDropDownComponentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 17.04.2023.
//

import XCTest
@testable import ForaBank

final class PaymentsSelectDropDownComponentTests: XCTestCase {

    func test_init_optionNotSelected_optionsListNotEmpty() throws {
        
        XCTAssertThrowsError(try makeSut(selectedOptionId: nil, options: [.phone, .requisites]))
    }
    
    func test_init_selectedOption_notInOptionslist() throws {
        
        XCTAssertThrowsError(try makeSut(selectedOptionId: "-1", options: [.phone, .requisites]))
    }
    
    func test_init_selectedOptionNil_optionsListEmpty() throws {
        
        XCTAssertThrowsError(try makeSut(selectedOptionId: nil, options: []))
    }
    
    func test_init_selectedOptionValid_optionsListNotEmpty() throws {
        
        let sut = try makeSut(selectedOptionId: "0", options: [.phone, .requisites])
        
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        
        guard case let .selected(selectedOptionViewModel) = sut.state else {
            XCTFail("state must be in selected case")
            return
        }
        
        guard case .image(_) = selectedOptionViewModel.icon else {
            XCTFail("icon must be .image")
            return
        }
        XCTAssertEqual(selectedOptionViewModel.title, "Тип оплаты")
        XCTAssertEqual(selectedOptionViewModel.name, "По номеру телефона")
    }
    
    func test_toggleAction_inSelectedState() throws {
        
        // given
        let sut = try makeSut(selectedOptionId: "0")
        
        // when
        sut.action.send(PaymentsParameterViewModelAction.DropDown.Toggle())
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        
        guard case let .list(optionsListViewModel) = sut.state else {
            XCTFail("state must be in list case")
            return
        }
        
        guard case .image(_) = optionsListViewModel.icon else {
            XCTFail("icon must be .image")
            return
        }
        XCTAssertEqual(optionsListViewModel.title, "Тип оплаты")
        XCTAssertEqual(optionsListViewModel.name, "По номеру телефона")
        
        // options
        XCTAssertEqual(optionsListViewModel.options.count, 2)
        XCTAssertEqual(optionsListViewModel.options[0].id, "0")
        XCTAssertEqual(optionsListViewModel.options[0].name, "По номеру телефона")
        XCTAssertEqual(optionsListViewModel.options[1].id, "1")
        XCTAssertEqual(optionsListViewModel.options[1].name, "По реквизитам")
        
        XCTAssertEqual(optionsListViewModel.selected, "0")
    }
    
    func test_toggleAction_inSelectedState_withOneOption() throws {
        
        // given
        let sut = try makeSut(selectedOptionId: "0", options: [.phone])
        
        // when
        sut.action.send(PaymentsParameterViewModelAction.DropDown.Toggle())
        _ = XCTWaiter.wait(for: [.init()], timeout: 0.1)
        
        // then
        XCTAssertEqual(sut.value.current, "0")
        XCTAssertTrue(sut.isValid)
        
        guard case let .selected(selectedOptionViewModel) = sut.state else {
            XCTFail("state must be in selected case")
            return
        }
        
        guard case .image(_) = selectedOptionViewModel.icon else {
            XCTFail("icon must be .image")
            return
        }
        XCTAssertEqual(selectedOptionViewModel.title, "Тип оплаты")
        XCTAssertEqual(selectedOptionViewModel.name, "По номеру телефона")
    }
}

//MARK: - Helpers

private extension PaymentsSelectDropDownComponentTests {
    
    func makeSut(selectedOptionId: String?, options: [Payments.ParameterSelectDropDownList.Option] = Payments.ParameterSelectDropDownList.sampleOptions) throws -> PaymentSelectDropDownView.ViewModel {
        
        try PaymentSelectDropDownView.ViewModel(
            with: .init(
                .init(id: "some_parameter_id",
                      value: selectedOptionId),
                title: "Тип оплаты",
                options: options))
        }
}

private extension Payments.ParameterSelectDropDownList.Option {
    
    static let phone: Self = .init(id: "0", name: "По номеру телефона", icon: .name("ic24Phone"))
    static let requisites: Self = .init(id: "1", name: "По реквизитам", icon: nil)
}

private extension Payments.ParameterSelectDropDownList {
    
    static let sampleOptions: [Payments.ParameterSelectDropDownList.Option] = [.phone, .requisites ]
}
