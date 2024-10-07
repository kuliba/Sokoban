//
//  QRNavigationTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.10.2024.
//

import SberQR
@testable import ForaBank
import ForaTools
import XCTest

class QRNavigationTests: XCTestCase {
    
    typealias SUT = QRNavigationComposerMicroServicesComposer
    typealias CreateSberQRPaymentSpy = Spy<SUT.MicroServices.MakeSberPaymentCompletePayload, CreateSberQRPaymentResponse, QRNavigation.ErrorMessage>
    typealias GetSberQRDataSpy = Spy<URL, GetSberQRDataResponse, Error>
    typealias MakeProviderPickerSpy = CallSpy<(MultiElementArray<SegmentedOperatorProvider>, QRCode, QRMapping), SegmentedPaymentProviderPickerFlowModel>
    typealias MakeServicePickerSpy = Spy<PaymentProviderServicePickerPayload, AnywayServicePickerFlowModel, Never>
    
    struct Spies {
        
        let createSberQRPayment: CreateSberQRPaymentSpy
        let getSberQRData: GetSberQRDataSpy
        let makeProviderPicker: MakeProviderPickerSpy
        let makeServicePicker: MakeServicePickerSpy
    }
    
    func eligible(
        file: StaticString = #file,
        line: UInt = #line
    ) -> ProductData {
        
        let product = makeAccountProduct(id: .random(in: 1...100))
        
        XCTAssert(product.allowDebit, file: file, line: line)
        XCTAssert(product.isActive, file: file, line: line)
        XCTAssert(product.isPaymentEligible, file: file, line: line)
        
        return product
    }
    
    func makeErrorMessage(
        title: String = anyMessage(),
        message: String = anyMessage()
    ) -> QRNavigation.ErrorMessage {
        
        return .init(title: title, message: message)
    }
    
    func makeMakeOperatorSearchPayload(
        multiple: MultiElementArray<SegmentedOperatorData>? = nil,
        qrCode: QRCode? = nil,
        qrMapping: QRMapping? = nil,
        chat: @escaping () -> Void = {},
        detailPayment: @escaping () -> Void = {},
        dismiss: @escaping () -> Void = {}
    ) -> QRNavigationComposerMicroServices.MakeOperatorSearchPayload {
        
        return .init(
            multiple: multiple ?? makeMultipleOperators(),
            qrCode: qrCode ?? makeQR(),
            qrMapping: qrMapping ?? makeQRMapping(),
            chat: chat,
            detailPayment: detailPayment,
            dismiss: dismiss
        )
    }
    
    func makeMixed(
    ) -> (mixed: MultiElementArray<SegmentedOperatorProvider>, qrCode: QRCode, qrMapping: QRMapping) {
        
        return (makeMixedOperators(), makeQR(), makeQRMapping())
    }
    
    func makeMixedOperators(
        _ first: SegmentedOperatorProvider? = nil,
        _ second: SegmentedOperatorProvider? = nil,
        _ tail: SegmentedOperatorProvider...
    ) -> MultiElementArray<SegmentedOperatorProvider> {
        
        return .init(first ?? makeSegmentedOperatorProvider(), second ?? makeSegmentedOperatorProvider(), tail)
    }
    
    private func makeSegmentedOperatorProvider(
    ) -> SegmentedOperatorProvider {
        
        return .provider(.init(
            origin: .init(
                id: anyMessage(),
                icon: nil,
                inn: nil,
                title: anyMessage(),
                segment: anyMessage()
            ),
            segment: anyMessage()
        ))
    }
    
    func makeMultipleOperators(
        first: SegmentedOperatorData? = nil,
        second: SegmentedOperatorData? = nil,
        tail: SegmentedOperatorData...
    ) -> MultiElementArray<SegmentedOperatorData> {
        
        return .init(first ?? makeSegmentedOperatorData(), second ?? makeSegmentedOperatorData(), tail)
    }
    
    func makeOperatorGroupDataOperatorData(
        city: String? = nil,
        code: String = anyMessage(),
        isGroup: Bool = false,
        logotypeList: [OperatorGroupData.LogotypeData] = [],
        name: String = anyMessage(),
        parameterList: [ParameterData] = [],
        parentCode: String = anyMessage(),
        region: String? = nil,
        synonymList: [String] = []
    ) -> OperatorGroupData.OperatorData {
        
        return .init(city: city, code: code, isGroup: isGroup, logotypeList: logotypeList, name: name, parameterList: parameterList, parentCode: parentCode, region: region, synonymList: synonymList)
    }
    
    func makePaymentProviderServicePickerPayload(
        provider: SegmentedProvider? = nil,
        qrCode: QRCode? = nil,
        qrMapping: QRMapping? = nil
    ) -> PaymentProviderServicePickerPayload {
        
        return .init(provider: provider ?? makeSegmentedProvider(), qrCode: qrCode ?? makeQR(), qrMapping: qrMapping ?? makeQRMapping())
    }
    
    func makeSegmentedProvider(
        origin: UtilityPaymentProvider? = nil,
        segment: String = anyMessage()
    ) -> SegmentedProvider {
        
        return .init(origin: origin ?? makeUtilityPaymentProvider(), segment: segment)
    }
    
    func makeUtilityPaymentProvider(
        id: String = anyMessage(),
        icon: String? = nil,
        inn: String? = nil,
        title: String = anyMessage(),
        segment: String = anyMessage()
    ) -> UtilityPaymentProvider {
        
        return .init(id: id, icon: icon, inn: inn, title: title, segment: segment)
    }
    
    func makeQR(
        original: String = anyMessage(),
        rawData: [String: String] = [anyMessage(): anyMessage()]
    ) -> QRCode {
        
        return .init(original: original, rawData: rawData)
    }
    
    func makeQRMapping(
        parameters: [QRParameter] = [],
        operators: [QROperator] = []
    ) -> QRMapping {
        
        return .init(parameters: parameters, operators: operators)
    }
    
    func makeSberQRConfirmPaymentState(
    ) -> SberQRConfirmPaymentState {
        
        return .init(confirm: .editableAmount(.preview))
    }
    
    func makeSegmentedOperatorData(
        origin: OperatorGroupData.OperatorData? = nil,
        segment: String = anyMessage()
    ) -> SegmentedOperatorData {
        
        return .init(origin: origin ?? makeOperatorGroupDataOperatorData(), segment: segment)
    }
    
    // MARK: - GetSberQRDataResponse
    
    func responseWithFixedAmount(
        qrcID: String = "04a7ae2bee8f4f13ab151c1e6066d304"
    ) -> GetSberQRDataResponse {
        
        .init(
            qrcID: qrcID,
            parameters: fixedAmountParameters(),
            required: [.debitAccount]
        )
    }
    
    private func amount() -> GetSberQRDataResponse.Parameter {
        
        .info(.init(
            id: .amount,
            value: "220 ₽",
            title: "Сумма",
            icon: .init(
                type: .local,
                value: "ic24IconMessage"
            )
        ))
    }
    
    private func brandName(
        value: String
    ) -> GetSberQRDataResponse.Parameter {
        
        .info(.init(
            id: .brandName,
            value: value,
            title: "Получатель",
            icon: .init(
                type: .remote,
                value: "b6e5b5b8673544184896724799e50384"
            )
        ))
    }
    
    private func buttonPay() -> GetSberQRDataResponse.Parameter {
        
        .button(.init(
            id: .buttonPay,
            value: "Оплатить",
            color: .red,
            action: .pay,
            placement: .bottom
        ))
    }
    
    private func debitAccount() -> GetSberQRDataResponse.Parameter {
        
        .productSelect(.init(
            id: .debit_account,
            value: nil,
            title: "Счет списания",
            filter: .init(
                productTypes: [.card, .account],
                currencies: [.rub],
                additional: false
            )
        ))
    }
    
    private func fixedAmountParameters(
    ) -> [GetSberQRDataResponse.Parameter] {
        
        return [
            header(),
            debitAccount(),
            brandName(value: "сббол енот_QR"),
            amount(),
            recipientBank(),
            buttonPay(),
        ]
    }
    
    private func header() -> GetSberQRDataResponse.Parameter {
        
        .header(.init(
            id: .title,
            value: "Оплата по QR-коду"
        ))
    }
    
    private func recipientBank() -> GetSberQRDataResponse.Parameter {
        
        .info(.init(
            id: .recipientBank,
            value: "Сбербанк",
            title: "Банк получателя",
            icon: .init(
                type: .remote,
                value: "c37971b7264d55c3c467d2127ed600aa"
            )
        ))
    }
}

// MARK: - DSL

extension QRNavigationComposer {
    
    func compose(
        with qrResult: QRModelResult
    ) {
        compose(
            payload: .qrResult(qrResult),
            notify: { _ in },
            completion: { _ in }
        )
    }
    
    func compose(
        url: URL,
        state: SberQRConfirmPaymentState
    ) {
        compose(
            payload: .sberPay(url, state),
            notify: { _ in },
            completion: { _ in }
        )
    }
    
    func compose(
        with qrResult: QRModelResult,
        notify: @escaping Notify
    ) {
        compose(
            payload: .qrResult(qrResult),
            notify: notify,
            completion: { _ in }
        )
    }
    
    func compose(
        with qrResult: QRModelResult,
        notify: @escaping Notify,
        completion: @escaping QRNavigationCompletion
    ) {
        compose(
            payload: .qrResult(qrResult),
            notify: notify,
            completion: completion
        )
    }
}
