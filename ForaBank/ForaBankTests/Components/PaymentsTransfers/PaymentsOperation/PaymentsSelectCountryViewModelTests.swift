//
//  PaymentsSelectCountryViewModelTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 01.06.2023.
//

@testable import ForaBank
@testable import TextFieldComponent
@testable import TextFieldModel
import XCTest

private typealias ViewModel = PaymentsSelectCountryView.ViewModel

final class PaymentsSelectCountryViewModelTests: XCTestCase {
    
    func test_init_shouldSetListToNil_onNonEmptyListOfCountriesWithService() throws {
        
        let (sut, scheduler, model) = try makeSUT(countriesWithService: .test)
        
        scheduler.advance()
        
        XCTAssertNil(sut.list)
        XCTAssertNoDiff(model.countriesListWithSevice.value, .test)
        XCTAssertNotNil(model)
    }
    
    func test_init_shouldSetWarningToNil() throws {
        
        let (sut, scheduler, _) = try makeSUT()
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.warning, nil)
    }
    
    func test_init_shouldSetSelectedItemTextFieldStateToPlaceholder_onNilValue() throws {
        
        let (sut, scheduler, _) = try makeSUT(value: nil)
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.selectedItem.textField.state, .placeholder("Select Country"))
    }
    
    func test_init_shouldSetSelectedItemTextFieldStateToNoFocusCountryName_onCountryCodeInList() throws {
        
        let value = "AM"
        let (sut, scheduler, model) = try makeSUT(value: value, countriesWithService: .test)
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.selectedItem.textField.state, .noFocus("Армения"))
        XCTAssertNoDiff(model.countriesListWithSevice.value, .test)
        XCTAssertTrue(model.countriesListWithSevice.value.map(\.code).contains(value))
    }
    
    func test_init_shouldSetSelectedItemTextFieldStateToPlaceholder_onEmptyList() throws {
        
        let value = "AZ"
        let (sut, scheduler, model) = try makeSUT(value: value, countriesWithService: [])
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.selectedItem.textField.state, .placeholder("Select Country"))
        XCTAssertNoDiff(model.countriesListWithSevice.value, [])
    }
    
    func test_init_shouldSetSelectedItemTextFieldStateToPlaceholder_onCountryCodeNotInList() throws {
        
        let value = "AZ"
        let (sut, scheduler, model) = try makeSUT(value: value, countriesWithService: .test)
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.selectedItem.textField.state, .placeholder("Select Country"))
        XCTAssertNoDiff(model.countriesListWithSevice.value, .test)
        XCTAssertFalse(model.countriesListWithSevice.value.map(\.code).contains(value))
    }
    
    func test_init_shouldSetCountryListToNil() throws {
        
        let (sut, scheduler, _) = try makeSUT()
        
        scheduler.advance()
                
        XCTAssertNil(sut.list)
    }
    
    func test_shouldFlipCountryListToVisible_onActionShowCountriesList() throws {
        
        let (sut, scheduler, _) = try makeSUT()
        
        sut.action.send(PaymentsSelectCountryViewModelAction.ShowCountriesList())
        
        scheduler.advance()
        
        XCTAssertNotNil(sut.list)
    }
    
    func test_shouldSetFilteredCountriesToAll_onEmptyTextFieldText() throws {
        
        let (sut, scheduler, _) = try makeSUT()
        
        sut.action.send(PaymentsSelectCountryViewModelAction.ShowCountriesList())
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.list?.items.map(\.name), [
            "См. все",
            "Армения",
            "Израиль",
        ])
        XCTAssertNoDiff(sut.list?.filteredItems.map(\.name), [
            "См. все",
            "Армения",
            "Израиль",
        ])
        XCTAssertNoDiff(sut.selectedItem.textField.state, .placeholder("Select Country"))
    }
    
    func test_shouldChangeFilteredCountries_onTextFieldTextEditing() throws {
        
        let (sut, scheduler, _) = try makeSUT()
        
        sut.action.send(PaymentsSelectCountryViewModelAction.ShowCountriesList())
        
        scheduler.advance()
        
        XCTAssertNoDiff(sut.selectedItem.textField.state, .placeholder("Select Country"))
        XCTAssertNoDiff(sut.list?.items.map(\.name), [
            "См. все", "Армения", "Израиль",
        ])
        XCTAssertNoDiff(sut.list?.filteredItems.map(\.name), [
            "См. все", "Армения", "Израиль",
        ])
        
        sut.selectedItem.textField.startEditing(on: scheduler)
        XCTAssertNoDiff(sut.selectedItem.textField.state, .editing(.empty))
        
        try sut.selectedItem.textField.appendText("Ар", on: scheduler)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 1)
        
        XCTAssertNoDiff(sut.selectedItem.textField.state, .editing(.init("Ар", cursorAt: 2)))
        XCTAssertNoDiff(sut.list?.items.map(\.name), [
            "См. все", "Армения", "Израиль",
        ])
        XCTAssertNoDiff(sut.list?.filteredItems.map(\.name), [
            "Армения",
        ])
    }
    
    func test_shouldFlipCountryListToVisible______onActionShowCountriesList() throws {
        
        let value = "AM"
        let (sut, scheduler, model) = try makeSUT(value: value, countriesWithService: .test)
        
        sut.action.send(PaymentsSelectCountryViewModelAction.ShowCountriesList())
        
        scheduler.advance()
        
        model.updateCountryList(with: .success(["IL"]))

        scheduler.advance()
                
        XCTAssertNoDiff(sut.selectedItem.textField.state, .noFocus("Армения"))
        XCTAssertNotNil(sut.list)
        XCTAssertNoDiff(model.countriesListWithSevice.value, .test)
        XCTAssertTrue(model.countriesListWithSevice.value.map(\.code).contains(value))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        value: Payments.Parameter.Value = nil,
        options: [Payments.ParameterSelectCountry.Option] = .test,
        countriesWithService: [CountryWithServiceData] = .test,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (
        sut: ViewModel,
        scheduler: TestSchedulerOfDispatchQueue,
        model: Model
    ) {
        let parameterSelect: Payments.ParameterSelectCountry = .make(
            with: value,
            options: options
        )
        
        let model: Model = .mockWithEmptyExcept()
        try model.replaceCountriesWithService(with: countriesWithService)
        
        let scheduler = DispatchQueue.test
        
        let sut = try ViewModel(
            with: parameterSelect,
            model: model,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        // trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, scheduler, model)
    }
}

// MARK: - DSL

private extension Model {
    
    func replaceCountriesWithService(
        with list: [CountryWithServiceData]
    ) throws {
        
        countriesListWithSevice.value = list
        
        if countriesListWithSevice.value != list {
            
            throw NSError(domain: "CountriesListWithService was not updated", code: 0)
        }
    }
    
    func updateCountryList(with result: Result<[String], Error>) {
        
        typealias ResultData = (id: String, imageData: ImageData)
        
        let result: Result<[ResultData], Error> = result.map { ids in
            ids.map { ($0, .tiny()) }
        }
        
        typealias Payload = ModelAction.Dictionary.DownloadImages.Response
        
        action.send(Payload(result: result))
    }
}

private extension ViewModel {
    
    func appendText(
        _ text: String,
        on scheduler: TestSchedulerOfDispatchQueue,
        by duration: DispatchQueue.SchedulerTimeType.Stride = .zero
    ) throws {
        
        try selectedItem.textField.append(text)
        scheduler.advance(by: duration)
    }
    
    func removeLast(
        _ k: Int,
        on scheduler: TestSchedulerOfDispatchQueue,
        by duration: DispatchQueue.SchedulerTimeType.Stride = .zero
    ) throws {
        
        try selectedItem.textField.removeLast(k)
        scheduler.advance(by: duration)
    }
    
    func startEditing(
        on scheduler: TestSchedulerOfDispatchQueue,
        by duration: DispatchQueue.SchedulerTimeType.Stride = .zero
    ) {
        selectedItem.textField.startEditing()
        scheduler.advance(by: duration)
    }
}

// MARK: - Helpers

private extension Payments.ParameterSelectCountry {
    
    static func make(
        with value: Payments.Parameter.Value,
        options: [Payments.ParameterSelectCountry.Option]
    ) -> Self {
        
        .init(
            .init(id: "country_param_id", value: value),
            icon: .init(with: .make(withColor: .red))!,
            title: "Select Country",
            options: options,
            validator: .anyValue,
            limitator: nil
        )
    }
}

private extension Payments.ParameterSelectCountry.Option {
    
    static let armenia: Self = .make(id: "AM", name: "Армения")
    static let israel: Self = .make(id: "IL", name: "Израиль")
    
    static func make(
        id: String,
        name: String,
        subtitle: String? = nil
    ) -> Self {
        
        .init(id: id, name: name, subtitle: subtitle, icon: .tiny())
    }
}

private extension Array where Element == Payments.ParameterSelectCountry.Option {
    
    static let test: Self = [.armenia, .israel]
}

private extension CountryWithServiceData {
    
    static func make(
        from option: Payments.ParameterSelectCountry.Option
    ) -> Self {
        
        .init(
            code: option.id,
            contactCode: nil,
            name: option.name,
            sendCurr: "RUB",
            md5hash: nil,
            servicesList: [
                .init(code: .direct,         isDefault: true),
                .init(code: .directCard,     isDefault: false),
                .init(code: .contact,        isDefault: false),
                .init(code: .contactCash,    isDefault: false),
                .init(code: .contactAccount, isDefault: false),
            ]
        )
    }
}

private extension Array where Element == CountryWithServiceData {
    
    static let test: Self = [Payments.ParameterSelectCountry.Option].test.map(CountryWithServiceData.make(from:))
}

extension ImageData {
    
    static func tiny(withColor color: UIColor = .red) -> Self {
        
        .init(with: .make(withColor: color))!
    }
}
