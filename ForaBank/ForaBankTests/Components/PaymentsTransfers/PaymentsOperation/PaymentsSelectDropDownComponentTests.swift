//
//  PaymentsSelectDropDownComponentTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 17.04.2023.
//

import XCTest
@testable import ForaBank

final class PaymentsSelectDropDownComponentTests: XCTestCase {

    func test_init_selected_option_nil() throws {
        
        let sut = makeSut(selectedOptionId: nil)
        
        XCTAssertNil(sut)
    }
    
    func test_init_selected_option_not_in_options_list() throws {
        
        let sut = makeSut(selectedOptionId: "-1")
        
        XCTAssertNil(sut)
    }
    
    func test_init_selected_option_valid() throws {
        
        let sut = try XCTUnwrap(makeSut(selectedOptionId: "0"))
        
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
    
    func test_toggle_action_in_selected_state() throws {
        
        // given
        let sut = try XCTUnwrap(makeSut(selectedOptionId: "0"))
        
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
}

//MARK: - Helpers

private extension PaymentsSelectDropDownComponentTests {
    
    func makeSut(selectedOptionId: String?, options: [Payments.ParameterSelectDropDownList.Option] = Payments.ParameterSelectDropDownList.sampleOptions ) -> PaymentSelectDropDownView.ViewModel? {
        
        PaymentSelectDropDownView.ViewModel(
            with: .init(
                .init(id: "some_parameter_id",
                      value: selectedOptionId),
                title: "Тип оплаты",
                options: options))
        }
}

private extension Payments.ParameterSelectDropDownList {
    
    static let sampleOptions: [Payments.ParameterSelectDropDownList.Option] =  [
        .init(id: "0", name: "По номеру телефона", icon: .name("ic24Phone")),
        .init(id: "1", name: "По реквизитам", icon: nil)
     ]
}
