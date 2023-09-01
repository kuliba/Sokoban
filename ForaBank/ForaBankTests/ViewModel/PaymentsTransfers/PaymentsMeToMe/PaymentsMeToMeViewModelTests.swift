//
//  PaymentsMeToMeViewModelTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 21.06.2023.
//

@testable import ForaBank
import XCTest

final class PaymentsMeToMeViewModelTests: XCTestCase {
    
    let templateId = 1
    let oldName = "oldName"
    
    func test_paymentMeToMe_bindRename_shouldSetTitle() throws {
        
        let model = modelWithNecessaryData()
        let newName = "newName"
        
        let sut = makeSUT(model: model)
        
        let renameViewModel = TemplatesListViewModel.RenameTemplateItemViewModel(
            oldName: oldName, templateID: templateId)
        sut?.bindRename(rename: renameViewModel)
        
        renameViewModel.action.send(TemplatesListViewModelAction.RenameSheetAction.SaveNewName(
            newName: newName,
            itemId: 1
        ))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.05)
        
        XCTAssertEqual(sut?.title, newName)
        XCTAssertNil(sut?.bottomSheet)
    }
    
    func test_paymentMeToMe_renameBottomSheet_shouldSetBottomSheet() throws {
        
        let model = modelWithNecessaryData()
        
        let sut = makeSUT(model: model)
        
        let title = try XCTUnwrap(sut?.title)
        
        sut?.renameBottomSheet(
            oldName: title,
            templateId: templateId
        )
        
        XCTAssertNotNil(sut?.bottomSheet)
    }
    
    // MARK: - test updatePaymentInfo
    
    func test_updatePaymentInfo_rubToRub_shouldCallSetDefaultInfoButton() {
        
        var setDefaultInfoButtonCalls = 0
            
        updatePaymentInfo(
            currencyFrom: .rub,
            currencyTo: .rub,
            setDefaultInfoButton: { setDefaultInfoButtonCalls += 1 }
        )
        
        XCTAssertNoDiff(setDefaultInfoButtonCalls, 1)
    }
        
    func test_updatePaymentInfo_rubToNotRub_rateNil_shouldCallSetDefaultInfoButton() {
        
        var setDefaultInfoButtonCalls = 0
        
        updatePaymentInfo(
            currencyFrom: .rub,
            currencyTo: .usd,
            rateTo: nil,
            rateFrom: nil,
            setDefaultInfoButton: { setDefaultInfoButtonCalls += 1 }
        )
        
        XCTAssertNoDiff(setDefaultInfoButtonCalls, 1)
    }
    
    func test_updatePaymentInfo_notRubToRub_rateNil_shouldCallSetDefaultInfoButton() {
        
        var setDefaultInfoButtonCalls = 0
        
        updatePaymentInfo(
            currencyFrom: .eur,
            currencyTo: .rub,
            rateTo: nil,
            rateFrom: nil,
            setDefaultInfoButton: { setDefaultInfoButtonCalls += 1 }
        )

        XCTAssertNoDiff(setDefaultInfoButtonCalls, 1)
    }
    
    func test_updatePaymentInfo_rubToNotRub_rateToNotNil_amount0_shouldCallSetText() {
        
        var text = ""

        updatePaymentInfo(
            currencyFrom: .rub,
            currencyTo: .eur,
            rateTo: .defaultValueEur,
            amount: 0,
            setText: { text = $0 }
        )
        
        XCTAssertNoDiff(text, "1 currencySymbolTo  -  87,30 currencySymbolFrom")
    }
    
    func test_updatePaymentInfo_rubToNotRub_rateToNotNil_amountMore0_shouldCallSetText() {
        
        var text = ""
        
        updatePaymentInfo(
            currencyFrom: .rub,
            currencyTo: .eur,
            rateTo: .defaultValueEur,
            amount: 10,
            setText: { text = $0 }
        )

        XCTAssertNoDiff(text, "0,11 currencySymbolTo   |   1 currencySymbolTo  -  87,30 currencySymbolFrom")
    }
    
    func test_updatePaymentInfo_notRubToRub_rateFromNotNil_amount0_shouldCallSetText() {
        
        var text = ""
        
        updatePaymentInfo(
            currencyFrom: .eur,
            currencyTo: .rub,
            amount: 0,
            rateFrom: .defaultValueEur,
            setText: { text = $0 }
        )
        
        XCTAssertNoDiff(text, "1 currencySymbolFrom  -  85,90 currencySymbolTo")
    }
    
    func test_updatePaymentInfo_notRubToRub_rateFromNotNil_amountMore0_shouldCallSetText() {
        
        var text = ""
        
        updatePaymentInfo(
            currencyFrom: .eur,
            currencyTo: .rub,
            amount: 10,
            rateFrom: .defaultValueEur,
            setText: { text = $0 }
        )

        XCTAssertNoDiff(text, "859,00 currencySymbolTo   |   1 currencySymbolFrom  -  85,90 currencySymbolTo")
    }
    
    func test_updatePaymentInfo_notRubToNotRub_rateNotNil_amount0_shouldCallSetText() {
        
        var text = ""
        
        updatePaymentInfo(
            currencyFrom: .eur,
            currencyTo: .usd,
            rateTo: .defaultValueEur,
            amount: 0,
            rateFrom: .defaultValueUsd,
            setText: { text = $0 }
        )

        XCTAssertNoDiff(text, "1 currencySymbolTo  -  1,06 currencySymbolFrom")
    }
    
    func test_updatePaymentInfo_notRubToNotRub_rateNotNil_amountMore0_shouldCallSetText() {
        
        var text = ""
        
        updatePaymentInfo(
            currencyFrom: .eur,
            currencyTo: .usd,
            rateTo: .defaultValueEur,
            amount: 10,
            rateFrom: .defaultValueUsd,
            setText: { text = $0 }
        )
        
        XCTAssertNoDiff(text, "9,42 currencySymbolTo   |   1 currencySymbolTo  -  1,06 currencySymbolFrom")
    }
    
    // MARK: - Helpers
    
    private func updatePaymentInfo(
        currencyFrom: Currency = .rub,
        currencyTo: Currency = .rub,
        rateTo: ExchangeRateData? = nil,
        amount: Double = 0,
        rateFrom: ExchangeRateData? = nil,
        setDefaultInfoButton: @escaping () -> Void = { },
        setText: @escaping (String) -> Void = { _ in }
    ) {
        PaymentsMeToMeViewModel.updatePaymentInfo(
            currencyFrom: currencyFrom,
            currencyTo: currencyTo,
            rateDataTo: rateTo,
            currencySymbolFrom: "currencySymbolFrom",
            currencySymbolTo: "currencySymbolTo",
            amount: amount,
            rateDataFrom: rateFrom,
            setDefaultInfoButton: setDefaultInfoButton,
            setText: setText
        )
    }
}

extension PaymentsMeToMeViewModelTests {
    
    func modelWithNecessaryData() -> Model {
        
        let model = Model.mockWithEmptyExcept()
        model.paymentTemplates.value.append(.templateStub(
            paymentTemplateId: templateId,
            type: .betweenTheir,
            parameterList: TransferGeneralData.generalStub())
        )
        
        model.products.value = [.card: [ProductData.stub(productId: 1)]]
        
        return model
    }
    
    func makeSUT(
        model: Model,
        templateId: PaymentTemplateData.ID = 1
    ) -> PaymentsMeToMeViewModel? {
        
        let name = model.paymentTemplates.value.first(where: { $0.id == templateId })?.name
        let sut = PaymentsMeToMeViewModel(
            model,
            mode: .templatePayment(templateId, name ?? "Между своими")
        )
        
        return sut
    }
}

extension ProductData {
    
    //TODO: remove stub after merge DBSNEW-8883
    static func stub(
        productId: Int = UUID().hashValue,
        currency: String = "RUB",
        balance: Double? = nil,
        balanceRub: Double? = nil
    ) -> ProductData {
        
        return .init(
            id: productId,
            productType: .card,
            number: "1",
            numberMasked: nil,
            accountNumber: nil,
            balance: balance,
            balanceRub: balanceRub,
            currency: currency,
            mainField: "",
            additionalField: nil,
            customName: nil,
            productName: "productName",
            openDate: nil,
            ownerId: 1,
            branchId: nil,
            allowCredit: true,
            allowDebit: true,
            extraLargeDesign: SVGImageData.test,
            largeDesign: SVGImageData.test,
            mediumDesign: SVGImageData.test,
            smallDesign: SVGImageData.test,
            fontDesignColor: .init(description: ""),
            background: [.init(description: "")],
            order: 1,
            isVisible: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: ""
        )
    }
}

private extension Date {
    
    static let defaultDate = Date.dateUTC(with: 1648512000000)
}

private extension ExchangeRateData {
    
    static let defaultValueEur = ExchangeRateData.init(
        currency: .eur,
        currencyCode: "978",
        currencyId: 90001299,
        currencyName: "Евро",
        rateBuy: 85.9,
        rateBuyDate: .defaultDate,
        rateSell: 87.3,
        rateSellDate: .defaultDate,
        rateType: "КурсДБОФЛ",
        rateTypeId: 10000000002
    )
    
    static let defaultValueUsd = ExchangeRateData.init(
        currency: .usd,
        currencyCode: "978",
        currencyId: 90001299,
        currencyName: "$",
        rateBuy: 80.9,
        rateBuyDate: .defaultDate,
        rateSell: 81.3,
        rateSellDate: .defaultDate,
        rateType: "КурсДБОФЛ",
        rateTypeId: 10000000002
    )
}
