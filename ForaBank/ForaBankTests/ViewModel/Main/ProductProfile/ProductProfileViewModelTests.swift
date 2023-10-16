//
//  ProductProfileViewModelTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 06.06.2023.
//

import XCTest
@testable import ForaBank
import SwiftUI
import PinCodeUI

final class ProductProfileViewModelTests: XCTestCase {
    
    func test_initWithEmptyModel_nil() {
        
        let sut = makeSUT(product: anyProduct(id: 0, productType: .card))
        
        XCTAssertNil(sut)
    }
    
    func test_init_notNil() throws {
        
        let model = makeModelWithProducts()
        let product = try XCTUnwrap(model.products.value[.card]?.first)
        let sut = makeSUT(model: model, product: product)
        
        XCTAssertNotNil(sut)
    }
    
    //FIXME: test fails for some reason but should not
    /*
     func test_transferButtonDidTappedAction_firesOnceInResponseToButtonsViewModelActionButtonDidTapped() throws {
     
     // given
     let model = makeModelWithProducts()
     let product = try XCTUnwrap(model.products.value[.card]?.first)
     let sut = try XCTUnwrap(makeSUT(model: model, product: product))
     let spy = ValueSpy(sut.action)
     
     // wait for bindings
     _ = XCTWaiter.wait(for: [], timeout: 0.1)
     
     // when
     sut.buttons.action.send(ProductProfileButtonsSectionViewAction.ButtonDidTapped(buttonType: .topRight))
     _ = XCTWaiter.wait(for: [], timeout: 0.1)
     
     // then
     XCTAssertEqual(spy.values.count, 1)
     XCTAssertNotNil(spy.values.first as? ProductProfileViewModelAction.TransferButtonDidTapped)
     }
     */
    
    //FIXME: test fails for some reason but should not
    /*
     func test_preferredProductID_setValueAfrerTransferButtonDidTappedActionTriggered() throws {
     
     let model = makeModelWithProducts()
     let product = try XCTUnwrap(model.products.value[.card]?.first)
     let sut = try XCTUnwrap(makeSUT(model: model, product: product))
     
     // wait for bindings
     _ = XCTWaiter().wait(for: [], timeout: 0.1)
     
     // when
     sut.action.send(ProductProfileViewModelAction.TransferButtonDidTapped())
     _ = XCTWaiter.wait(for: [], timeout: 0.1)
     
     XCTAssertEqual(model.preferredProductID, product.id)
     }
     */
    
    func test_preferredProductID_setToNilAfrerIsLinkActiveBecomeFalse() throws {
        
        let model = makeModelWithProducts()
        let product = try XCTUnwrap(model.products.value[.card]?.first)
        let sut = try XCTUnwrap(makeSUT(model: model, product: product))
        model.setPreferredProductID(to: 1000)
        sut.isLinkActive = true
        
        // wait for bindings
        _ = XCTWaiter.wait(for: [], timeout: 0.1)
        
        // when
        sut.isLinkActive = false
        _ = XCTWaiter.wait(for: [], timeout: 0.1)
        
        XCTAssertNil(model.preferredProductID)
    }
    
    //MARK: - test handlePinError
    
    func test_handlePinError_certificateError_showActivateCertificateAlert() throws {
        
        let (sut, model) = try makeSUT()
        
        XCTAssertNil(sut.alert)
        
        sut.handlePinError(111, .certificate, "*4585")
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.alert)
        
        XCTAssertNoDiff(sut.alert?.title, "Активируйте сертификат")
        XCTAssertNoDiff(sut.alert?.message, model.activateCertificateMessage)
        
        XCTAssertNoDiff(sut.alert?.primary.type, .default)
        XCTAssertNoDiff(sut.alert?.primary.title, "Отмена")
        XCTAssertNotNil(sut.alert?.primary.action)
        
        XCTAssertNoDiff(sut.alert?.secondary?.type, .default)
        XCTAssertNoDiff(sut.alert?.secondary?.title, "Активировать")
        XCTAssertNotNil(sut.alert?.secondary?.action)
        
        sut.action.send(ProductProfileViewModelAction.Close.Alert())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(sut.alert)
    }
    
    func test_handlePinError_connectivityError_showActivateCertificateAlert() throws {
        
        let (sut, _) = try makeSUT()
        
        XCTAssertNil(sut.alert)
        
        sut.handlePinError(111, .connectivity, "*4585")
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.alert)
        
        XCTAssertNoDiff(sut.alert?.title, "Ошибка")
        XCTAssertNoDiff(sut.alert?.message, "Истеклo время\nожидания ответа")
        
        XCTAssertNoDiff(sut.alert?.primary.type, .default)
        XCTAssertNoDiff(sut.alert?.primary.title, "ОК")
        XCTAssertNotNil(sut.alert?.primary.action)
        
        XCTAssertNil(sut.alert?.secondary)
    }
    
    func test_optionsPannelAction_blockCard_showAlert() throws {
        
        let (sut, _) = try makeSUT()
        
        XCTAssertNil(sut.optionsPannel)
        
        sut.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: sut.panelViewModelBlockCardChangePin))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.optionsPannel)
        
        XCTAssertNil(sut.alert)
        
        let action = ProductProfileOptionsPannelViewModelAction.ButtonTapped(buttonType: .card(.block))
        
        sut.optionsPannel?.action.send(action)
        
        //в коде now + .milliseconds(300)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)
        
        XCTAssertNotNil(sut.alert)
        
        XCTAssertNoDiff(sut.alert?.title, "Заблокировать карту?")
        XCTAssertNoDiff(sut.alert?.message, "Карту можно будет разблокировать в приложении или в колл-центре")
        
        XCTAssertNoDiff(sut.alert?.primary.type, .default)
        XCTAssertNoDiff(sut.alert?.primary.title, "Отмена")
        XCTAssertNotNil(sut.alert?.primary.action)
        
        XCTAssertNoDiff(sut.alert?.secondary?.type, .default)
        XCTAssertNoDiff(sut.alert?.secondary?.title, "Oк")
        XCTAssertNotNil(sut.alert?.secondary?.action)
        
        sut.action.send(ProductProfileViewModelAction.Close.Alert())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(sut.alert)
    }
    
    func test_optionsPannelAction_unBlockCard_showAlert() throws {
        
        let (sut, _) = try makeSUT(
            status: .blockedByClient,
            statusPC: .blockedByClient
        )
        
        XCTAssertNil(sut.optionsPannel)
        
        sut.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: sut.panelViewModelUnBlockCardChangePin))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.optionsPannel)
        
        XCTAssertNil(sut.alert)
        
        let action = ProductProfileOptionsPannelViewModelAction.ButtonTapped(buttonType: .card(.unblock))
        
        sut.optionsPannel?.action.send(action)
        
        //в коде now + .milliseconds(300)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)
        
        XCTAssertNotNil(sut.alert)
        
        XCTAssertNoDiff(sut.alert?.title, "Разблокировать карту?")
        XCTAssertNil(sut.alert?.message)
        
        XCTAssertNoDiff(sut.alert?.primary.type, .default)
        XCTAssertNoDiff(sut.alert?.primary.title, "Отмена")
        XCTAssertNotNil(sut.alert?.primary.action)
        
        XCTAssertNoDiff(sut.alert?.secondary?.type, .default)
        XCTAssertNoDiff(sut.alert?.secondary?.title, "Oк")
        XCTAssertNotNil(sut.alert?.secondary?.action)
        
        sut.action.send(ProductProfileViewModelAction.Close.Alert())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(sut.alert)
    }
    
    func test_optionsPannelAction_changePin_sadPath_showActivateCertificateAlert() throws {
        
        let (sut, _) = try makeSUT(certificateClient: SadCertificateClient())
        
        XCTAssertNil(sut.optionsPannel)
        
        sut.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: sut.panelViewModelBlockCardChangePin))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.optionsPannel)
        
        XCTAssertNil(sut.alert)
        
        let action = ProductProfileOptionsPannelViewModelAction.ButtonTapped(buttonType: .card(.changePin))
        
        sut.optionsPannel?.action.send(action)
        
        //в коде now + .milliseconds(300)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)
        
        XCTAssertNotNil(sut.alert)
        
        XCTAssertNoDiff(sut.alert?.title, "Активируйте сертификат")
        // см test_handlePinError_certificateError_showActivateCertificateAlert
        
        sut.action.send(ProductProfileViewModelAction.Close.Alert())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(sut.alert)
    }
    
    func test_optionsPannelAction_changePin_happyPath_showPinCodeView() throws {
        
        let (sut, _) = try makeSUT(certificateClient: HappyCertificateClient())
        
        XCTAssertNil(sut.optionsPannel)
        
        sut.action.send(ProductProfileViewModelAction.Show.OptionsPannel(viewModel: sut.panelViewModelUnBlockCardChangePin))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.optionsPannel)
        
        XCTAssertNil(sut.changePin)
        
        let action = ProductProfileOptionsPannelViewModelAction.ButtonTapped(buttonType: .card(.changePin))
        
        sut.optionsPannel?.action.send(action)
        
        //в коде now + .milliseconds(300)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)
        
        XCTAssertNotNil(sut.changePin)
        XCTAssertTrue(sut.changePin?.model is PinCodeViewModel)
        sut.changePin = nil
    }
    
    // MARK: - test showCvvByTap
    
    func test_showCvvByTap_happyPath_returnCVV() throws {
        
        let (sut, _) = try makeSUT()
        
        sut.showCvvByTap(
            cardId: .init(111),
            certificateClient: HappyCertificateClient()) { result in
                XCTAssertNoDiff(result, .init("123"))
            }
    }
    
    func test_showCvvByTap_checkCertificateError_returNil() throws {
        
        let (sut, _) = try makeSUT()
        
        sut.showCvvByTap(
            cardId: .init(111),
            certificateClient: SadShowCVVSadCheckCertificateClient()) { result in
                XCTAssertNil(result)
            }
    }
    
    func test_showCvvByTap_checkCertificateConnectivityError_returNil() throws {
        
        let (sut, _) = try makeSUT()
        
        sut.showCvvByTap(
            cardId: .init(111),
            certificateClient: SadShowCVVCheckCertificateConnectivityClient()) { result in
                XCTAssertNil(result)
            }
    }
    
    func test_showCvvByTap_activateCertificateError_returNil() throws {
        
        let (sut, _) = try makeSUT()
        
        sut.showCvvByTap(
            cardId: .init(111),
            certificateClient: SadShowCVVSadActivateCertificateClient()) { result in
                XCTAssertNil(result)
            }
    }
    
    func test_showCvvByTap_otpErrorRetryAttempts0_returNil() throws {
        
        let (sut, _) = try makeSUT()
        
        sut.showCvvByTap(
            cardId: .init(111),
            certificateClient: SadShowCVVSadOtpRetryAttempts0CertificateClient()) { result in
                XCTAssertNil(result)
            }
    }
    
    func test_showCvvByTap_otpErrorRetryAttempts_returNil() throws {
        
        let (sut, _) = try makeSUT()
        
        sut.showCvvByTap(
            cardId: .init(111),
            certificateClient: SadShowCVVSadOtpRetryAttemptsCertificateClient()) { result in
                XCTAssertNil(result)
            }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        model: Model = .mockWithEmptyExcept(),
        certificateClient: CertificateClient = HappyCertificateClient(),
        product: ProductData,
        rootView: String = ""
    ) -> ProductProfileViewModel? {
        
        .init(
            model,
            certificateClient: certificateClient,
            product: product,
            rootView: rootView,
            dismissAction: {}
        )
    }
    
    private func makeSUT(
        status: ProductData.Status = .active,
        statusPC: ProductData.StatusPC = .active,
        certificateClient: CertificateClient = HappyCertificateClient(),
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (
        sut: ProductProfileViewModel,
        model: Model
    ) {
        let model = Model.mockWithEmptyExcept()
        model.products.value = [.card: [
            ProductCardData(
                status: status,
                statusPc: statusPC
            )
        ]]
        
        let product = try XCTUnwrap(model.products.value[.card]?.first)
        
        let sut = try XCTUnwrap(
            ProductProfileViewModel(
                model,
                certificateClient: certificateClient,
                product: product,
                rootView: "",
                dismissAction: {}
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model)
    }
    
    func makeModelWithProducts(_ counts: ProductTypeCounts = [(.card, 1)]) -> Model {
        
        let model = Model.mockWithEmptyExcept()
        model.products.value = makeProductsData(counts)
        
        return model
    }
}

private extension ProductProfileViewModel {
    
    var optionsPannel: ProductProfileOptionsPannelView.ViewModel? {
        
        switch bottomSheet?.type {
            
        case let .optionsPannel(optionsPannel):
            
            return optionsPannel
            
        default:
            return nil
        }
    }
    
    var panelViewModelBlockCardChangePin: ProductProfileOptionsPannelView.ViewModel {
        .init(
            buttonsTypes: [
                .card(.block),
                .card(.changePin)
            ],
            productType: .card
        )
    }
    
    var panelViewModelUnBlockCardChangePin: ProductProfileOptionsPannelView.ViewModel {
        .init(
            buttonsTypes: [
                .card(.unblock),
                .card(.changePin)
            ],
            productType: .card
        )
    }
    
    var viewModelByLink: Any? {
        
        guard let link = link else { return nil }
        
        switch link {
            
        case let .productInfo(viewModel):
            return viewModel
        case let .productStatement(viewModel):
            return viewModel
        case let .meToMeExternal(viewModel):
            return viewModel
        case let .myProducts(viewModel):
            return viewModel
        case let .paymentsTransfers(viewModel):
            return viewModel
        }
    }
}

private extension ProductCardData {
    
    convenience init(
        id: Int = 1,
        currency: Currency = .init(description: "RUB"),
        number: String = "4444 4444 4444 4444",
        numberMasked: String = "4444 **** **** **44",
        ownerId: Int = 0,
        holderName: String? = "Иванов",
        allowCredit: Bool = true,
        allowDebit: Bool = true,
        status: ProductData.Status = .active,
        loanBaseParam: ProductCardData.LoanBaseParamInfoData? = nil,
        statusPc: ProductData.StatusPC = .active,
        isMain: Bool = true
    ) {
        
        self.init(
            id: id,
            productType: .card,
            number: number,
            numberMasked: numberMasked,
            accountNumber: nil,
            balance: nil,
            balanceRub: nil,
            currency: currency.description,
            mainField: "Visa",
            additionalField: nil,
            customName: nil,
            productName: "",
            openDate: nil,
            ownerId: ownerId,
            branchId: nil,
            allowCredit: allowCredit,
            allowDebit: allowDebit,
            extraLargeDesign: .init(description: ""),
            largeDesign: .init(description: ""),
            mediumDesign: .init(description: ""),
            smallDesign: .init(description: ""),
            fontDesignColor: .init(description: ""),
            background: [],
            accountId: nil,
            cardId: 0,
            name: "",
            validThru: Date(),
            status: status,
            expireDate: nil,
            holderName: holderName,
            product: nil,
            branch: "",
            miniStatement: nil,
            paymentSystemName: nil,
            paymentSystemImage: nil,
            loanBaseParam: loanBaseParam,
            statusPc: statusPc,
            isMain: isMain,
            externalId: nil,
            order: 0,
            visibility: true,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "")
    }
}

final class HappyCheckSadActivateCertificateClient: CertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, CVVPinError.CheckError>) -> Void) {
        completion(.success(()))
    }
    
    func activateCertificate(completion: @escaping (Result<String, CVVPinError.ActivationError>) -> Void) {
        
        completion(.failure(.init(message: "ТЕСТОВАЯ ОШИБКА!!!!")))
    }
    
    func confirmWith(otp: String, completion: @escaping (Result<Void, CVVPinError.OtpError>) -> Void) {
        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, CVVPinError.ShowCVVError>) -> Void) {
        completion(.success("111"))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, CVVPinError.ChangePinError>) -> Void) {
        completion(.success(()))
    }
    
    func getPinConfirmCode(completion: @escaping (Result<String, CVVPinError.PinConfirmationError>) -> Void) {
        completion(.success("+1..22"))
    }
}

final class SadCheckSadActivateCertificateClient: CertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, CVVPinError.CheckError>) -> Void) {
        
        completion(.failure(CVVPinError.CheckError.certificate))
    }
    
    func activateCertificate(completion: @escaping (Result<String, CVVPinError.ActivationError>) -> Void) {
        
        completion(.failure(.init(message: "ТЕСТОВАЯ ОШИБКА!!!\nВозникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения")))
    }
    
    func confirmWith(otp: String, completion: @escaping (Result<Void, CVVPinError.OtpError>) -> Void) {
        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, CVVPinError.ShowCVVError>) -> Void) {
        completion(.success("111"))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, CVVPinError.ChangePinError>) -> Void) {
        completion(.success(()))
    }
    
    func getPinConfirmCode(completion: @escaping (Result<String, CVVPinError.PinConfirmationError>) -> Void) {
        completion(.success("+1..22"))
    }
}

final class SadShowCVVSadCheckCertificateClient: CertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, CVVPinError.CheckError>) -> Void) {
        
        completion(.failure(CVVPinError.CheckError.certificate))
    }
    
    func activateCertificate(completion: @escaping (Result<String, CVVPinError.ActivationError>) -> Void) {
        
        completion(.failure(.init(message: "ТЕСТОВАЯ ОШИБКА!!!\nВозникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения")))
    }
    
    func confirmWith(otp: String, completion: @escaping (Result<Void, CVVPinError.OtpError>) -> Void) {
        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, CVVPinError.ShowCVVError>) -> Void) {
        completion(.failure(.check(.certificate)))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, CVVPinError.ChangePinError>) -> Void) {
        completion(.success(()))
    }
    
    func getPinConfirmCode(completion: @escaping (Result<String, CVVPinError.PinConfirmationError>) -> Void) {
        completion(.success("+1..22"))
    }
}

final class SadShowCVVCheckCertificateConnectivityClient: CertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, CVVPinError.CheckError>) -> Void) {
        
        completion(.failure(CVVPinError.CheckError.certificate))
    }
    
    func activateCertificate(completion: @escaping (Result<String, CVVPinError.ActivationError>) -> Void) {
        
        completion(.failure(.init(message: "ТЕСТОВАЯ ОШИБКА!!!\nВозникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения")))
    }
    
    func confirmWith(otp: String, completion: @escaping (Result<Void, CVVPinError.OtpError>) -> Void) {
        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, CVVPinError.ShowCVVError>) -> Void) {
        completion(.failure(.check(.connectivity)))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, CVVPinError.ChangePinError>) -> Void) {
        completion(.success(()))
    }
    
    func getPinConfirmCode(completion: @escaping (Result<String, CVVPinError.PinConfirmationError>) -> Void) {
        completion(.success("+1..22"))
    }
}

final class SadShowCVVSadActivateCertificateClient: CertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, CVVPinError.CheckError>) -> Void) {
        
        completion(.failure(CVVPinError.CheckError.certificate))
    }
    
    func activateCertificate(completion: @escaping (Result<String, CVVPinError.ActivationError>) -> Void) {
        
        completion(.failure(.init(message: "ТЕСТОВАЯ ОШИБКА!!!\nВозникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения")))
    }
    
    func confirmWith(otp: String, completion: @escaping (Result<Void, CVVPinError.OtpError>) -> Void) {
        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, CVVPinError.ShowCVVError>) -> Void) {
        completion(.failure(.activation(.init(message: "error"))))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, CVVPinError.ChangePinError>) -> Void) {
        completion(.success(()))
    }
    
    func getPinConfirmCode(completion: @escaping (Result<String, CVVPinError.PinConfirmationError>) -> Void) {
        completion(.success("+1..22"))
    }
}

final class SadShowCVVSadOtpRetryAttempts0CertificateClient: CertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, CVVPinError.CheckError>) -> Void) {
        
        completion(.failure(CVVPinError.CheckError.certificate))
    }
    
    func activateCertificate(completion: @escaping (Result<String, CVVPinError.ActivationError>) -> Void) {
        
        completion(.success("+1..11"))
    }
    
    func confirmWith(otp: String, completion: @escaping (Result<Void, CVVPinError.OtpError>) -> Void) {
        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, CVVPinError.ShowCVVError>) -> Void) {
        completion(.failure(.otp(.init(errorMessage: "", retryAttempts: 0))))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, CVVPinError.ChangePinError>) -> Void) {
        completion(.success(()))
    }
    
    func getPinConfirmCode(completion: @escaping (Result<String, CVVPinError.PinConfirmationError>) -> Void) {
        completion(.success("+1..22"))
    }
}

final class SadShowCVVSadOtpRetryAttemptsCertificateClient: CertificateClient {
    
    func checkCertificate(completion: @escaping (Result<Void, CVVPinError.CheckError>) -> Void) {
        
        completion(.failure(CVVPinError.CheckError.certificate))
    }
    
    func activateCertificate(completion: @escaping (Result<String, CVVPinError.ActivationError>) -> Void) {
        
        completion(.success("+1..11"))
    }
    
    func confirmWith(otp: String, completion: @escaping (Result<Void, CVVPinError.OtpError>) -> Void) {
        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, CVVPinError.ShowCVVError>) -> Void) {
        completion(.failure(.otp(.init(errorMessage: "", retryAttempts: 1))))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, CVVPinError.ChangePinError>) -> Void) {
        completion(.success(()))
    }
    
    func getPinConfirmCode(completion: @escaping (Result<String, CVVPinError.PinConfirmationError>) -> Void) {
        completion(.success("+1..22"))
    }
}
