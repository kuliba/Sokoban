//
//  CurrencyWalletViewModelComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.09.2024.
//

final class CurrencyWalletViewModelComposer {
    
    private let model: Model
    
    init(model: Model) {
        
        self.model = model
    }
}

extension CurrencyWalletViewModelComposer {
    
    func compose(
        dismiss: @escaping () -> Void,
        currencyOperation: CurrencyOperation = .buy
    ) -> CurrencyWalletViewModel? {
        
        guard let currency = model.currencyWalletList.value.first
        else { return nil }
        
        return .init(
            currency: .init(description: currency.code),
            currencyOperation: currencyOperation,
            model: model,
            dismissAction: dismiss
        )
    }
}

@testable import ForaBank
import XCTest

final class CurrencyWalletViewModelComposerTests: XCTestCase {

    func test_compose_shouldFailOnEmptyCurrencyList() {
        
        let (sut, model) = makeSUT()
        
        XCTAssertNil(sut.compose(dismiss: {}))
        XCTAssertTrue(model.isCurrencyListEmpty)
    }
    
    func test_compose_shouldFailOnEmptyCurrencyWalletList() {
        
        let (sut, model) = makeSUT()
        
        XCTAssertNil(sut.compose(dismiss: {}))
        XCTAssertTrue(model.isCurrencyWalletListEmpty)
    }

    func test_compose_shouldFailOnNonMatchingCurrencies() {
        
        let (sut, model) = makeSUT()
        model.addCurrency(makeCurrencyData())
        model.addWalletCurrency(makeWalletCurrencyData())
        
        XCTAssertNil(sut.compose(dismiss: {}))
        XCTAssertFalse(model.isCurrencyListEmpty)
        XCTAssertFalse(model.isCurrencyWalletListEmpty)
    }

    func test_compose_shouldDeliverCurrencyWalletViewModelOnCurrencyMatch() {
        
        let currency = anyMessage()
        let (sut, model) = makeSUT()
        model.addCurrency(makeCurrencyData(code: currency, cssCode: "\\20BD"))
        model.addWalletCurrency(makeWalletCurrencyData(code: currency))
        
        XCTAssertNotNil(sut.compose(dismiss: {}))
        XCTAssertFalse(model.isCurrencyListEmpty)
        XCTAssertFalse(model.isCurrencyWalletListEmpty)
    }

    func test_compose_shouldSetCurrencyOperation() {
        
        let currency = anyMessage()
        let (sut, model) = makeSUT()
        model.addCurrency(makeCurrencyData(code: currency, cssCode: "\\20BD"))
        model.addWalletCurrency(makeWalletCurrencyData(code: currency))
        
        let wallet = sut.compose(dismiss: {}, currencyOperation: .sell)
        
        XCTAssertNoDiff(wallet?.currencyOperation, .sell)
    }

    // MARK: - Helpers
    
    private typealias SUT = CurrencyWalletViewModelComposer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        model: Model
    ) {
        let model: Model = .mockWithEmptyExcept()
        let sut = SUT(model: model)
        
        trackForMemoryLeaks(model, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, model)
    }
    
    private func makeCurrencyData(
        code: String = anyMessage(),
        codeISO: Int = .random(in: 1...100),
        codeNumeric: Int = .random(in: 1...100),
        cssCode: String? = nil,
        htmlCode: String? = nil,
        id: String = anyMessage(),
        name: String = anyMessage(),
        shortName: String? = nil,
        unicode: String? = nil
    ) -> CurrencyData {
        
        return .init(
            code: code,
            codeISO: codeISO,
            codeNumeric: codeNumeric,
            cssCode: cssCode,
            htmlCode: htmlCode,
            id: id,
            name: name,
            shortName: shortName,
            unicode: unicode
        )
    }
    
    private func makeWalletCurrencyData(
        code: String = "RUB",
        rateBuy: Double = .random(in: 1...100),
        rateBuyDelta: Double? = nil,
        rateSell: Double = .random(in: 1...100),
        rateSellDelta: Double? = nil,
        md5hash: String = anyMessage(),
        currAmount: Int = .random(in: 1...100),
        nameCw: String = anyMessage()
    ) -> CurrencyWalletData {
    
        return .init(
            code: code,
            rateBuy: rateBuy,
            rateBuyDelta: rateBuyDelta,
            rateSell: rateSell,
            rateSellDelta: rateSellDelta,
            md5hash: md5hash,
            currAmount: currAmount,
            nameCw: nameCw
        )
    }
}

// MARK: - DSL

extension Model {
    
    var isCurrencyListEmpty: Bool {
        
        currencyList.value.isEmpty
    }
    
    var isCurrencyWalletListEmpty: Bool {
        
        currencyWalletList.value.isEmpty
    }
    
    func addCurrency(_ currency: CurrencyData) {
        
        var value = currencyList.value
        value.append(currency)
        currencyList.value = value
    }
    
    func addWalletCurrency(_ currency: CurrencyWalletData) {
        
        var value = currencyWalletList.value
        value.append(currency)
        currencyWalletList.value = value
    }
}
