//
//  ContactsBanksSectionViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 29.04.2023.
//

@testable import ForaBank
import TextFieldComponent
import XCTest

final class ContactsBanksSectionViewModelTests: XCTestCase {

    // MARK: - init
    
    func test_init_fastPayment_banks_phoneNil() {
        
        let sut = makeSUT(phone: nil, .fastPayment, .banks)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, nil)
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_select_banks_phoneNil() {
        
        let sut = makeSUT(phone: nil, .select, .banks)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, nil)
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_fastPayment_banksFullInfo_phoneNil() {
        
        let sut = makeSUT(phone: nil, .fastPayment, .banksFullInfo)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, nil)
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_select_banksFullInfo_phoneNil() {
        
        let sut = makeSUT(phone: nil, .select, .banksFullInfo)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, nil)
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_fastPayment_banks_phoneEmpty() {
        
        let sut = makeSUT(phone: "", .fastPayment, .banks)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_select_banks_phoneEmpty() {
        
        let sut = makeSUT(phone: "", .select, .banks)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_fastPayment_banksFullInfo_phoneEmpty() {
        
        let sut = makeSUT(phone: "", .fastPayment, .banksFullInfo)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_select_banksFullInfo_phoneEmpty() {
        
        let sut = makeSUT(phone: "", .select, .banksFullInfo)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_fastPayment_banks_phoneNonEmpty() {
        
        let sut = makeSUT(phone: "123", .fastPayment, .banks)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "123")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_select_banks_phoneNonEmpty() {
        
        let sut = makeSUT(phone: "123", .select, .banks)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "123")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_fastPayment_banksFullInfo_phoneNonEmpty() {
        
        let sut = makeSUT(phone: "123", .fastPayment, .banksFullInfo)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "123")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_select_banksFullInfo_phoneNonEmpty() {
        
        let sut = makeSUT(phone: "123", .select, .banksFullInfo)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "123")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_fastPayment_banks_phoneLetters() {
        
        let sut = makeSUT(phone: "ABC", .fastPayment, .banks)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "ABC")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_select_banks_phoneLetters() {
        
        let sut = makeSUT(phone: "ABC", .select, .banks)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "ABC")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_fastPayment_banksFullInfo_phoneLetters() {
        
        let sut = makeSUT(phone: "ABC", .fastPayment, .banksFullInfo)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "ABC")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    func test_init_select_banksFullInfo_phoneLetters() {
        
        let sut = makeSUT(phone: "ABC", .select, .banksFullInfo)
        
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.type, .banks)
        XCTAssertNil(sut.searchTextField)
        XCTAssertNotNil(sut.options)
        XCTAssertNotNil(sut.visible)
        XCTAssertEqual(sut.filter.value, nil)
        XCTAssertEqual(sut.phone.value, "ABC")
        XCTAssertNil(sut.searchPlaceholder)
    }
    
    // MARK: - searchTextField

    func test_shouldFlipSearchBarToNonNil_onSearchDidTapped_searchTextField_fastPayment_banks() {
        
        let sut = makeSUT(phone: nil, .fastPayment, .banks)
        
        XCTAssertNil(sut.searchTextField)
        
        sut.searchDidTappedAndWait()
        
        XCTAssertNotNil(sut.searchTextField)
        XCTAssertNotNil(sut)
    }
        
    func test_shouldFlipSearchBarToNonNil_onSearchDidTapped_searchTextField_select_banks() {
        
        let sut = makeSUT(phone: nil, .select, .banks)
        
        XCTAssertNil(sut.searchTextField)
        
        sut.searchDidTappedAndWait()
        
        XCTAssertNotNil(sut.searchTextField)
    }
        
    func test_shouldFlipSearchBarToNonNil_onSearchDidTapped_searchTextField_fastPayment_banksFullInfo() {
        
        let sut = makeSUT(phone: nil, .fastPayment, .banksFullInfo)
        
        XCTAssertNil(sut.searchTextField)
        
        sut.searchDidTappedAndWait()
        
        XCTAssertNotNil(sut.searchTextField)
    }
        
    func test_shouldFlipSearchBarToNonNil_onSearchDidTapped_searchTextField_select_banksFullInfo() {
        
        let sut = makeSUT(phone: nil, .select, .banksFullInfo)
        
        XCTAssertNil(sut.searchTextField)
        
        sut.searchDidTappedAndWait()
        
        XCTAssertNotNil(sut.searchTextField)
    }
        
    func test_shouldFlipSearchBarToNil_onCancelSearch_searchTextField_fastPayment_banks() throws {
        
        let sut = makeSUT(phone: nil, .fastPayment, .banks)
        
        XCTAssertNil(sut.searchTextField)
        
        sut.searchDidTappedAndWait()
        
        XCTAssertNotNil(sut.searchTextField)
        
        try sut.dismissSearchAndWait()
        
        XCTAssertNil(sut.searchTextField)
    }
        
    func test_shouldFlipSearchBarToNil_onCancelSearch_searchTextField_select_banks() throws {
        
        let sut = makeSUT(phone: nil, .select, .banks)
        
        XCTAssertNil(sut.searchTextField)
        
        sut.searchDidTappedAndWait()
        
        XCTAssertNotNil(sut.searchTextField)
        
        try sut.dismissSearchAndWait()
        
        XCTAssertNil(sut.searchTextField)
    }
        
    func test_shouldFlipSearchBarToNil_onCancelSearch_searchTextField_fastPayment_banksFullInfo() throws {
        
        let sut = makeSUT(phone: nil, .fastPayment, .banksFullInfo)
        
        XCTAssertNil(sut.searchTextField)
        
        sut.searchDidTappedAndWait()
        
        XCTAssertNotNil(sut.searchTextField)
        
        try sut.dismissSearchAndWait()
        
        XCTAssertNil(sut.searchTextField)
    }
        
    func test_shouldFlipSearchBarToNil_onCancelSearch_searchTextField_select_banksFullInfo() throws {
        
        let sut = makeSUT(phone: nil, .select, .banksFullInfo)
        
        XCTAssertNil(sut.searchTextField)
        
        sut.searchDidTappedAndWait()
        
        XCTAssertNotNil(sut.searchTextField)
        
        try sut.dismissSearchAndWait()
        
        XCTAssertNil(sut.searchTextField)
    }
        
    func test_shouldUpdateFilter_onSearchTextChange_fastPayment_banks() throws {
        
        let sut = makeSUT(phone: nil, .fastPayment, .banks)
        let spy = ValueSpy(sut.filter)
        sut.searchDidTappedAndWait()

        XCTAssertEqual(spy.values, [nil, nil])
        
        try sut.typeAndWait("A")
        
        XCTAssertEqual(spy.values, [nil, nil, "A"])
        
        try sut.typeAndWait("")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil])
        
        try sut.typeAndWait("B")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B"])
        
        try sut.typeAndWait("1")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B", "1"])
        
        try sut.typeAndWait(nil)
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B", "1", nil])
    }
        
    func test_shouldUpdateFilter_onSearchTextChange_select_banks() throws {
        
        let sut = makeSUT(phone: nil, .select, .banks)
        let spy = ValueSpy(sut.filter)
        sut.searchDidTappedAndWait()

        XCTAssertEqual(spy.values, [nil, nil])
        
        try sut.typeAndWait("A")
        
        XCTAssertEqual(spy.values, [nil, nil, "A"])
        
        try sut.typeAndWait("")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil])
        
        try sut.typeAndWait("B")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B"])
        
        try sut.typeAndWait("1")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B", "1"])
        
        try sut.typeAndWait(nil)
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B", "1", nil])
    }
        
    func test_shouldUpdateFilter_onSearchTextTextChange_fastPayment_banksFullInfo() throws {
        
        let sut = makeSUT(phone: nil, .fastPayment, .banksFullInfo)
        let spy = ValueSpy(sut.filter)
        sut.searchDidTappedAndWait()

        XCTAssertEqual(spy.values, [nil, nil])
        
        try sut.typeAndWait("A")
        
        XCTAssertEqual(spy.values, [nil, nil, "A"])
        
        try sut.typeAndWait("")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil])
        
        try sut.typeAndWait("B")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B"])
        
        try sut.typeAndWait("1")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B", "1"])
        
        try sut.typeAndWait(nil)
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B", "1", nil])
    }
        
    func test_shouldUpdateFilter_onSearchTextChange_select_banksFullInfo() throws {
        
        let sut = makeSUT(phone: nil, .select, .banksFullInfo)
        let spy = ValueSpy(sut.filter)
        sut.searchDidTappedAndWait()

        XCTAssertEqual(spy.values, [nil, nil])
        
        try sut.typeAndWait("A")
        
        XCTAssertEqual(spy.values, [nil, nil, "A"])
        
        try sut.typeAndWait("")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil])
        
        try sut.typeAndWait("B")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B"])
        
        try sut.typeAndWait("1")
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B", "1"])
        
        try sut.typeAndWait(nil)
        
        XCTAssertEqual(spy.values, [nil, nil, "A", nil, "B", "1", nil])
    }
        
    func test_bankID_shouldReturnIDsList() {
        
        let model = Model.emptyMock
        model.paymentsByPhone.value.append(
            element: .init(
                bankId: "1",
                bankName: "bankName",
                payment: true,
                defaultBank: true
            ),
            toValueOfKey: "1"
        )
        let sut = makeSUT(model: model, phone: "1", .select, .banks)
        
        XCTAssertEqual(sut.banksID, ["1"])
    }
    
    func test_bankID_shouldReturnEmptyIDsList() {
        
        let model = Model.emptyMock
        model.paymentsByPhone.value = [:]
        let sut = makeSUT(model: model, phone: "1", .select, .banks)
        
        XCTAssertEqual(sut.banksID, [])
    }
    
    // TODO: add tests for other ContactsBanksSectionViewModel behaviour

    // MARK: - Helpers
    
    private func makeSUT(
        model: Model = .emptyMock,
        phone: String?,
        _ mode: ContactsBanksSectionViewModel.Mode,
        _ bankDictionary: ContactsBanksSectionViewModel.BankDictionary,
        searchTextField: RegularFieldViewModel = .bank(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> ContactsBanksSectionViewModel {
     
        let sut = ContactsBanksSectionViewModel(
            model,
            mode: mode,
            phone: phone,
            bankDictionary: bankDictionary,
            searchTextFieldFactory: { searchTextField }
        )

        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}

// MARK: - DLS

extension ContactsSectionCollapsableViewModel {
    
    func searchDidTappedAndWait() {
        
        header.action.send(ContactsSectionViewModelAction.Collapsable.SearchDidTapped())
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
}

extension ContactsBanksSectionViewModel {
    
    func dismissSearchAndWait(
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        cancelSearch()
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
    
    func typeAndWait(
        _ text: String?,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let searchTextField = try XCTUnwrap(searchTextField, file: file, line: line)
        searchTextField.setText(to: text)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
}
