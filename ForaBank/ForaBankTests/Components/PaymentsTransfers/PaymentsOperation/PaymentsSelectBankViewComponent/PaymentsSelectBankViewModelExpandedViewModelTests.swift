//
//  PaymentsSelectBankViewModelExpandedViewModelTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 31.05.2023.
//

@testable import ForaBank
@testable import TextFieldComponent
@testable import TextFieldModel
import XCTest

private typealias ViewModel = PaymentsSelectBankView.ViewModel.ExpandedViewModel

final class PaymentsSelectBankViewModelExpandedViewModelTests: XCTestCase {
    
    func test_init_nilValue_isEditableTrue() {
        
        let (sut, scheduler, spy) = makeSUT(with: nil, isEditable: true)
        
        XCTAssertEqual(sut.title, "Банк получателя")
        XCTAssertNoDiff(spy.values, [
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"])
        ])
        
        scheduler.advance()
        
        XCTAssertEqual(sut.title, "Банк получателя")
        XCTAssertNoDiff(spy.values, [
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"]),
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"]),
        ])
    }
    
    func test_init_nonNilValue_isEditableTrue() {
        
        let (sut, scheduler, spy) = makeSUT(with: "0", isEditable: true)
        
        XCTAssertEqual(sut.title, "Банк получателя")
        XCTAssertNoDiff(spy.values, [
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"])
        ])
        
        scheduler.advance()
        
        XCTAssertEqual(sut.title, "Банк получателя")
        XCTAssertNoDiff(spy.values, [
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"]),
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"]),
        ])
    }
    
    func test_textField_shouldFilterList_onPartialBic() throws {
        
        let (sut, scheduler, spy) = makeSUT(options: .searchBic)
        
        try sut.textField.startEditing(on: scheduler)
        
        XCTAssertNoDiff(sut.textField.text, "")
        
        var expected: [ViewModel.ListState.Simplified] = [
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"]),
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"]),
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"]),
        ]
        XCTAssertNoDiff(spy.values, expected)
        
        try sut.textField.appendText("0", on: scheduler)
        
        XCTAssertNoDiff(sut.textField.text, "0")
        assert(
            spy.values, equals: &expected,
            appending: .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"])
        )
        
        try sut.textField.appendText("445", on: scheduler)
        
        XCTAssertNoDiff(sut.textField.text, "0445")
        assert(
            spy.values, equals: &expected,
            appending: .filtered(selectAllTitle: nil, bankNames: ["Сбербанк"])
        )
        
        try sut.textField.removeLast(2, on: scheduler)
        
        XCTAssertNoDiff(sut.textField.text, "04")
        assert(
            spy.values, equals: &expected,
            appending: .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"])
        )
    }
    
    func test_textField_shouldFilterList_onPartialName() throws {
        
        let (sut, scheduler, spy) = makeSUT(options: .searchName)
        
        try sut.textField.startEditing(on: scheduler)
        
        XCTAssertNoDiff(sut.textField.text, "")
        
        var expected: [ViewModel.ListState.Simplified] = [
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"]),
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"]),
            .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"]),
        ]
        XCTAssertNoDiff(spy.values, expected)
        
        try sut.textField.appendText("С", on: scheduler)
        
        XCTAssertNoDiff(sut.textField.text, "С")
        assert(
            spy.values, equals: &expected,
            appending: .filtered(selectAllTitle: nil, bankNames: ["Сбербанк"])
        )
        
        try sut.textField.appendText("бе", on: scheduler)
        
        XCTAssertNoDiff(sut.textField.text, "Сбе")
        assert(
            spy.values, equals: &expected,
            appending: .filtered(selectAllTitle: nil, bankNames: ["Сбербанк"])
        )
        
        try sut.textField.removeLast(2, on: scheduler)
        
        XCTAssertNoDiff(sut.textField.text, "С")
        assert(
            spy.values, equals: &expected,
            appending: .filtered(selectAllTitle: nil, bankNames: ["Сбербанк"])
        )
        
        try sut.textField.removeLast(1, on: scheduler)
        
        XCTAssertNoDiff(sut.textField.text, "")
        assert(
            spy.values, equals: &expected,
            appending: .filtered(selectAllTitle: nil, bankNames: ["Сбербанк", "Альфа-банк"])
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        with value: Payments.Parameter.Value = nil,
        options: [Payments.ParameterSelectBank.Option] = .searchName,
        selectAll: Payments.ParameterSelectBank.SelectAllOption? = nil,
        isEditable: Bool = true,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: ViewModel,
        scheduler: TestSchedulerOfDispatchQueue,
        spy: ValueSpy<ViewModel.ListState.Simplified>
    ) {
        let parameter: Payments.ParameterSelectBank = .make(
            with: value,
            options: options,
            selectAll: selectAll,
            isEditable: isEditable
        )
        let scheduler = DispatchQueue.test
        let sut = ViewModel(
            with: value,
            parameter: parameter,
            defaultIcon: .ic24Bank,
            scheduler: scheduler.eraseToAnyScheduler(),
            allBanks: []
        )
        let spy = ValueSpy(sut.$list.map(\.simplified))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, scheduler, spy)
    }
}

// MARK: - DSL

extension ReducerTextFieldViewModel {
    
    func appendText(
        _ text: String,
        on scheduler: TestSchedulerOfDispatchQueue,
        by duration: DispatchQueue.SchedulerTimeType.Stride = .zero
    ) throws {
        
        try append(text)
        scheduler.advance(by: duration)
    }
    
    func removeLast(
        _ k: Int,
        on scheduler: TestSchedulerOfDispatchQueue,
        by duration: DispatchQueue.SchedulerTimeType.Stride = .zero
    ) throws {
        
        try removeLast(k)
        scheduler.advance(by: duration)
    }
    
    func startEditing(
        on scheduler: TestSchedulerOfDispatchQueue,
        by duration: DispatchQueue.SchedulerTimeType.Stride = .zero
    ) {
        startEditing()
        scheduler.advance(by: duration)
    }
}

// MARK: - Helpers

private extension ViewModel.ListState {
    
    var simplified: Simplified {
        
        switch self {
        case let .filtered(selectAll: selectAll, banks: banks):
            return .filtered(
                selectAllTitle: selectAll?.name,
                bankNames: banks.map(\.name)
            )
            
        case .empty:
            return .empty
        }
    }
    
    enum Simplified: Equatable {
        
        case filtered(selectAllTitle: String?, bankNames: [String])
        case empty
    }
}

private extension Payments.ParameterSelectBank {
    
    static func make(
        with value: Payments.Parameter.Value,
        options: [Payments.ParameterSelectBank.Option] = .searchBic,
        selectAll: Payments.ParameterSelectBank.SelectAllOption? = nil,
        isEditable: Bool = true
    ) -> Self {
        
        .init(
            .init(id: "bank_param_id", value: value),
            icon: .init(with: .make(withColor: .red))!,
            title: "Банк получателя",
            options: options,
            placeholder: "Выберите банк",
            selectAll: selectAll,
            keyboardType: .normal,
            isEditable: isEditable,
            group: nil
        )
    }
}

private extension Payments.ParameterSelectBank.Option {
    
    static let sberSearchName: Self = .make(
        id: "0",
        name: "Сбербанк",
        searchValue: "Сбербанк"
    )
    static let sberSearchBic: Self = .make(
        id: "0",
        name: "Сбербанк",
        searchValue: "0445566"
    )
    
    static let alfaSearchName: Self = .make(
        id: "1",
        name: "Альфа-банк",
        searchValue: "Альфа-банк"
    )
    static let alfaSearchBic: Self = .make(
        id: "1",
        name: "Альфа-банк",
        searchValue: "0447788"
    )
    
    private static func make(
        id: String,
        name: String,
        subtitle: String? = nil,
        icon: ImageData? = nil,
        searchValue: String
    ) -> Self {
        
        .init(id: id, name: name, subtitle: subtitle, icon: icon, isFavorite: false, searchValue: searchValue)
    }
}

private extension Array where Element == Payments.ParameterSelectBank.Option {
    
    static let searchName: Self = [.sberSearchName, .alfaSearchName]
    static let searchBic: Self = [.sberSearchBic, .alfaSearchBic]
}
