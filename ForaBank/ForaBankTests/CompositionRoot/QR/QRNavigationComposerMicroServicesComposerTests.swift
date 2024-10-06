//
//  QRNavigationComposerMicroServicesComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 05.10.2024.
//

@testable import ForaBank
import ForaTools
import SberQR
import XCTest

final class QRNavigationComposerMicroServicesComposerTests: QRNavigationTests {
    
    // MARK: - init
    
    func test_init_shouldNotCallCollaborators() {
        
        let (sut, spies) = makeSUT()
        
        XCTAssertEqual(spies.createSberQRPayment.callCount, 0)
        XCTAssertEqual(spies.getSberQRData.callCount, 0)
        XCTAssertEqual(spies.makeProviderPicker.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - makeInternetTV
    
    func test_composed_makeInternetTV_shouldCompleteAndSetQRData() {
        
        let payload = makeMakeInternetTVPayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makeInternetTV(payload) {
                
                XCTAssertNoDiff($0.qrData, payload.0.rawData)
                completion()
            }
        }
    }
    
    // MARK: - makeOperatorSearch
    
    func test_composed_makeOperatorSearch_shouldComplete() {
        
        let payload = makeMakeOperatorSearchPayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makeOperatorSearch(payload) { _ in completion() }
        }
    }
    
    // TODO: - improve tests for makeOperatorSearch
    
    // MARK: - makePayments
    
    func test_composed_makePayments_shouldCompleteWithOperationSource() {
        
        let payload = makeMakePaymentsOperationSourcePayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    func test_composed_makePayments_shouldCompleteWithQRCode() {
        
        let payload = makeMakePaymentsQRCodePayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    func test_composed_makePayments_shouldCompleteWithC2BSource() {
        
        let payload = makeMakePaymentsC2BSourcePayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    func test_composed_makePayments_shouldCompleteWithC2BSubscribeSource() {
        
        let payload = makeMakePaymentsC2BSubscribeSourcePayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makePayments(payload) { _ in completion() }
        }
    }
    
    // MARK: - makeProviderPicker
    
    func test_composed_makeProviderPicker_shouldCallMakeProviderPickerWithPayload() {
        
        let payload = makeMakeProviderPickerPayload()
        let (sut, spies) = makeSUT()
        
        sut.compose().makeProviderPicker(payload) { _ in }
        
        XCTAssertNoDiff(spies.makeProviderPicker.payloads.map(\.0), [payload.mixed])
        XCTAssertNoDiff(spies.makeProviderPicker.payloads.map(\.1), [payload.qrCode])
        XCTAssertNoDiff(spies.makeProviderPicker.payloads.map(\.2), [payload.qrMapping])
    }
    
    func test_composed_makeProviderPicker_shouldComplete() {
        
        let payload = makeMakeProviderPickerPayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makeProviderPicker(payload) { _ in completion() }
        }
    }
    
    // MARK: - makeQRFailure
    
    func test_composed_makeQRFailure_shouldComplete() {
        
        let payload = makeMakeQRFailurePayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makeQRFailure(payload) { _ in completion() }
        }
    }
    
    // MARK: - makeQRFailureWithQR
    
    func test_composed_makeQRFailureWithQR_shouldComplete() {
        
        let payload = makeMakeQRFailureWithQRPayload()
        let composed = makeSUT().sut.compose()
        
        expect { completion in
            
            composed.makeQRFailureWithQR(payload) { _ in completion() }
        }
    }
    
    // MARK: - makeSberPaymentComplete
    
    func test_composed_makePaymentComplete_shouldCallCreateSberQRPaymentWithPayload() {
        
        let payload = makeMakePaymentCompletePayload()
        let (sut, spies) = makeSUT()
        
        sut.compose().makeSberPaymentComplete(payload) { _ in }
        
        XCTAssertNoDiff(spies.createSberQRPayment.payloads.map(\.0), [payload.0])
        XCTAssertNoDiff(spies.createSberQRPayment.payloads.map(\.1), [payload.1])
    }
    
    func test_composed_makePaymentComplete_shouldDeliverFailureOnCreateSberQRPaymentFailure() {
        
        let (payload, failure) = (makeMakePaymentCompletePayload(), makeErrorMessage())
        let (sut, spies) = makeSUT()
        
        expect(
            toComplete: { completion in
                
                sut.compose().makeSberPaymentComplete(payload) {
                    
                    switch $0 {
                    case let .failure(receivedFailure):
                        XCTAssertNoDiff(receivedFailure, failure)
                        
                    default:
                        XCTFail("Expected failure \(failure), got \($0) instead.")
                    }
                    completion()
                }
            },
            on: { spies.createSberQRPayment.complete(with: failure) }
        )
    }
    
    func test_composed_makePaymentComplete_shouldPaymentCompleteOnCreateSberQRPaymentSuccess() {
        
        let payload = makeMakePaymentCompletePayload()
        let (sut, spies) = makeSUT()
        
        expect(
            toComplete: { completion in
                
                sut.compose().makeSberPaymentComplete(payload) {
                    
                    switch $0 {
                    case .success:
                        break
                        
                    default:
                        XCTFail("Expected success , got \($0) instead.")
                    }
                    completion()
                }
            },
            on: {
                
                spies.createSberQRPayment.complete(with: makeCreateSberQRPaymentResponse())
            }
        )
    }
    
    // MARK: - makeSberQR
    
    func test_composed_makeSberQR_shouldCallGetSberQRDataWithURL() {
        
        let url = anyURL()
        let (sut, spies) = makeSUT()
        
        sut.compose().makeSberQR((url, { _ in })) { _ in }
        
        XCTAssertNoDiff(spies.getSberQRData.payloads, [url])
    }
    
    func test_composed_makeSberQR_shouldDeliverFailureOnGetSberQRDataFailure() {
        
        let (sut, spies) = makeSUT()
        expect(
            toComplete: { completion in
                
                sut.compose().makeSberQR((anyURL(), { _ in })) {
                    
                    switch $0 {
                    case .failure:
                        break
                        
                    default:
                        XCTFail("Expected failure, got \($0) instead.")
                    }
                    
                    completion()
                }
            },
            on: { spies.getSberQRData.complete(with: anyError()) }
        )
    }
    
    func test_composed_makeSberQR_shouldDeliverFailureOnMissingProductGetSberQRDataSuccess() {
        
        let (sut, spies) = makeSUT()
        
        expect(
            toComplete: { completion in
                
                sut.compose().makeSberQR((anyURL(), { _ in })) {
                    
                    switch $0 {
                    case .failure:
                        break
                        
                    default:
                        XCTFail("Expected failure, got \($0) instead.")
                    }
                    
                    completion()
                }
            },
            on: { spies.getSberQRData.complete(with: .empty()) }
        )
    }
    
    func test_composed_makeSberQR_shouldDeliverSuccessOnProductAndGetSberQRDataSuccess() {
        
        let (sut, spies) = makeSUT(product: eligible())
        
        expect(
            toComplete: { completion in
                
                sut.compose().makeSberQR((anyURL(), { _ in })) {
                    
                    switch $0 {
                    case .success:
                        break
                        
                    default:
                        XCTFail("Expected success, got \($0) instead.")
                    }
                    
                    completion()
                }
            },
            on: { spies.getSberQRData.complete(with: responseWithFixedAmount()) }
        )
    }
    
    // MARK: - makeServicePicker
    
    func test_composed_makeServicePicker_shouldCallMakeServicePickerWithPayload() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let (sut, spies) = makeSUT()
        
        sut.compose().makeServicePicker(payload) { _ in }
        
        XCTAssertNoDiff(spies.makeServicePicker.payloads, [payload])
    }
    
    func test_composed_makeServicePicker_shouldCompleteWithFlowModel() {
        
        let payload = makePaymentProviderServicePickerPayload()
        let flowModel = makeAnywayServicePickerFlowModel()
        let (sut, spies) = makeSUT()
        
        expect(
            toComplete: { completion in
                
                sut.compose().makeServicePicker(payload) {
                    
                    XCTAssert($0 === flowModel)
                    completion()
                }
            },
            on: { spies.makeServicePicker.complete(with: flowModel) }
        )
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRNavigationComposerMicroServicesComposer
    private typealias CreateSberQRPaymentSpy = Spy<SUT.MicroServices.MakeSberPaymentCompletePayload, CreateSberQRPaymentResponse, QRNavigation.ErrorMessage>
    private typealias GetSberQRDataSpy = Spy<URL, GetSberQRDataResponse, Error>
    private typealias MakeProviderPickerSpy = CallSpy<(MultiElementArray<SegmentedOperatorProvider>, QRCode, QRMapping), SegmentedPaymentProviderPickerFlowModel>
    private typealias MakeServicePickerSpy = Spy<PaymentProviderServicePickerPayload, AnywayServicePickerFlowModel, Never>
    
    private struct Spies {
        
        let createSberQRPayment: CreateSberQRPaymentSpy
        let getSberQRData: GetSberQRDataSpy
        let makeProviderPicker: MakeProviderPickerSpy
        let makeServicePicker: MakeServicePickerSpy
    }
    
    private func makeSUT(
        product: ProductData? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spies: Spies
    ) {
        let model: Model = .mockWithEmptyExcept()
        if let product {
            
            model.products.value.append(element: product, toValueOfKey: product.productType)
        }
        let spies = Spies(
            createSberQRPayment: .init(),
            getSberQRData: .init(),
            makeProviderPicker: .init(stubs: [.preview(mix: makeMixedOperators(), qrCode: makeQR(), qrMapping: makeQRMapping())]),
            makeServicePicker: .init()
        )
        
        let sut = SUT(
            logger: LoggerSpy(),
            model: model,
            createSberQRPayment: spies.createSberQRPayment.process(_:completion:),
            getSberQRData: spies.getSberQRData.process(_:completion:),
            makeSegmented: spies.makeProviderPicker.call, 
            makeServicePicker: spies.makeServicePicker.process(_:completion:),
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spies.createSberQRPayment, file: file, line: line)
        trackForMemoryLeaks(spies.getSberQRData, file: file, line: line)
        trackForMemoryLeaks(spies.makeProviderPicker, file: file, line: line)
        trackForMemoryLeaks(spies.makeServicePicker, file: file, line: line)
        
        return (sut, spies)
    }
    
    private func eligible(
        file: StaticString = #file,
        line: UInt = #line
    ) -> ProductData {
        
        let product = makeAccountProduct(id: .random(in: 1...100))
        
        XCTAssert(product.allowDebit, file: file, line: line)
        XCTAssert(product.isActive, file: file, line: line)
        XCTAssert(product.isPaymentEligible, file: file, line: line)
        
        return product
    }
    
    private func makeCreateSberQRPaymentResponse(
        parameters: [CreateSberQRPaymentResponse.Parameter] = [.dataLong(.init(id: .paymentOperationDetailId, value: .random(in: 1...100)))]
    ) -> CreateSberQRPaymentResponse {
        
        return .init(parameters: parameters)
    }
    
    private func makeMakeInternetTVPayload(
        qrCode: QRCode? = nil,
        qrMapping: QRMapping? = nil
    ) -> SUT.MicroServices.MakeInternetTVPayload {
        
        return (qrCode ?? makeQR(), qrMapping ?? makeQRMapping())
    }
    
    private func makeMakePaymentsOperationSourcePayload(
    ) -> SUT.MicroServices.MakePaymentsPayload {
        
        return .operationSource(.avtodor)
    }
    
    private func makeMakePaymentsQRCodePayload(
        qrCode: QRCode? = nil
    ) -> SUT.MicroServices.MakePaymentsPayload {
        
        return .qrCode(qrCode ?? makeQR())
    }
    
    private func makeMakePaymentsC2BSourcePayload(
        url: URL = anyURL()
    ) -> SUT.MicroServices.MakePaymentsPayload {
        
        return .source(.c2b(url))
    }
    
    private func makeMakePaymentsC2BSubscribeSourcePayload(
        url: URL = anyURL()
    ) -> SUT.MicroServices.MakePaymentsPayload {
        
        return .source(.c2b(url))
    }
    
    private func makeMakePaymentCompletePayload(
        url: URL = anyURL(),
        state: SberQRConfirmPaymentState? = nil
    ) -> SUT.MicroServices.MakeSberPaymentCompletePayload {
        
        return (url, state ?? makeSberQRConfirmPaymentState())
    }
    
    private func makeMakeProviderPickerPayload(
        mixed: MultiElementArray<SegmentedOperatorProvider>? = nil,
        qrCode: QRCode? = nil,
        qrMapping: QRMapping? = nil
    ) -> SUT.MicroServices.MakeProviderPickerPayload {
        
        return .init(
            mixed: mixed ?? makeMixedOperators(),
            qrCode: qrCode ?? makeQR(),
            qrMapping: qrMapping ?? makeQRMapping()
        )
    }
    
    private func makeMakeQRFailurePayload(
        chat: @escaping () -> Void = {},
        detailPayment: @escaping () -> Void = {}
    ) -> SUT.MicroServices.MakeQRFailurePayload {
        
        return .init(chat: chat, detailPayment: detailPayment)
    }
    
    private func makeMakeQRFailureWithQRPayload(
        qrCode: QRCode? = nil,
        chat: @escaping () -> Void = {},
        detailPayment: @escaping (QRCode) -> Void = { _ in }
    ) -> SUT.MicroServices.MakeQRFailureWithQRPayload {
        
        return .init(qrCode: qrCode ?? makeQR(), chat: chat, detailPayment: detailPayment)
    }
    
    private func makeAnywayServicePickerFlowModel(
    ) -> AnywayServicePickerFlowModel {
        
        
        return .preview(payload: makePaymentProviderServicePickerPayload())
    }
    
    private func expect(
        toComplete function: @escaping (@escaping () -> Void) -> Void,
        on action: () -> Void = {},
        timeout: TimeInterval = 1
    ) {
        let exp = expectation(description: "wait for completion")
        
        function { exp.fulfill() }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
    
    // MARK: - GetSberQRDataResponse
    
    private func responseWithFixedAmount(
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
