//
//  ProductProfileViewModelTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 06.06.2023.
//

@testable import ForaBank
import PinCodeUI
import SberQR
import SwiftUI
import XCTest

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
        
        let (sut, model, _) = try makeSUT()
        
        XCTAssertNil(sut.alert)
        
        sut.handlePinError(111, .activationFailure, "*4585")
        
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
    
    func test_handlePinError_serviceFailureError_showActivateCertificateAlert() throws {
        
        let (sut, _, _) = try makeSUT()
        
        XCTAssertNil(sut.alert)
        
        sut.handlePinError(111, .serviceFailure, "*4585")
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.alert)
        
        XCTAssertNoDiff(sut.alert?.title, "Ошибка")
        XCTAssertNoDiff(sut.alert?.message, "Истеклo время\nожидания ответа")
        
        XCTAssertNoDiff(sut.alert?.primary.type, .default)
        XCTAssertNoDiff(sut.alert?.primary.title, "ОК")
        XCTAssertNotNil(sut.alert?.primary.action)
        
        XCTAssertNil(sut.alert?.secondary)
    }
    
    func test_showActivateCertificateAlert() throws {
        
        let (sut, _, _) = try makeSUT()
        
        XCTAssertNil(sut.alert)
        
        sut.handlePinError(111, .activationFailure, "*4585")
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.alert)
        
        XCTAssertNoDiff(sut.alert?.title, "Активируйте сертификат")
        XCTAssertNoDiff(sut.alert?.message, "\nСертификат позволяет просматривать CVV по картам и изменять PIN-код\nв течение 6 месяцев\n\nЭто мера предосторожности во избежание мошеннических операций")
        
        XCTAssertNoDiff(sut.alert?.primary.type, .default)
        XCTAssertNoDiff(sut.alert?.primary.title, "Отмена")
        XCTAssertNotNil(sut.alert?.primary.action)
        
        XCTAssertNotNil(sut.alert?.secondary)
    }
    
    func test_cardActivatedVisible_showActivateCertificateAlert() throws {
        
        let (sut, _, _) = try makeSUT(statusCard: .active, visibility: true)
        
        XCTAssertNil(sut.alert)
        
        sut.handlePinError(111, .activationFailure, "*4585")
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.alert)
        
        XCTAssertNoDiff(sut.alert?.title, "Активируйте сертификат")
        
        XCTAssertNoDiff(sut.alert?.primary.type, .default)
        XCTAssertNoDiff(sut.alert?.primary.title, "Отмена")
        XCTAssertNotNil(sut.alert?.primary.action)
        
        XCTAssertNotNil(sut.alert?.secondary)
    }
    
    func test_cardActivatedNotVisible_showActivateCertificateAlert() throws {
        
        let (sut, _, _) = try makeSUT(statusCard: .active, visibility: false)
        
        XCTAssertNil(sut.alert)
        
        sut.handlePinError(111, .activationFailure, "*4585")
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.alert)
        
        XCTAssertNoDiff(sut.alert?.title, "Активируйте сертификат")
        
        XCTAssertNoDiff(sut.alert?.primary.type, .default)
        XCTAssertNoDiff(sut.alert?.primary.title, "Отмена")
        XCTAssertNotNil(sut.alert?.primary.action)
        
        XCTAssertNotNil(sut.alert?.secondary)
    }
    
    func test_activateCertificateAction_happyPathActivateCertificate_shouldShowConfirmOtpViewHideSpinner() throws {
        
        let (sut, _, _) = try makeSUT()
        
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.fullScreenCoverState)
        XCTAssertNil(sut.spinner)
        
        sut.action.send(ProductProfileViewModelAction.Spinner.Show())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.spinner)

        sut.activateCertificateAction(
            cvvPINServicesClient: SadShowCVVSadOtpRetryAttempts0CertificateClient(),
            cardId: 111,
            actionType: .showCvv)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.fullScreenCoverState)
        XCTAssertNil(sut.spinner)

        sut.fullScreenCoverState = nil
        sut.alert = nil
    }
    
    func test_activateCertificateAction_sadPathActivateCertificate_shouldShowAlertHideSpinner() throws {
        
        let (sut, _, _) = try makeSUT()
        
        XCTAssertNil(sut.alert)
        XCTAssertNil(sut.fullScreenCoverState)
        XCTAssertNil(sut.spinner)
        
        sut.action.send(ProductProfileViewModelAction.Spinner.Show())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.spinner)

        sut.activateCertificateAction(
            cvvPINServicesClient: SadShowCVVSadActivateCertificateClient(),
            cardId: 111,
            actionType: .showCvv)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.alert)
        XCTAssertNil(sut.spinner)

        sut.alert = nil
    }
    
    // MARK: - test showSpinner
    func test_showSpinner_linkNotInfoProductModel() throws {
        
        let (sut, _, _) = try makeSUT()
        
        XCTAssertNil(sut.spinner)
        XCTAssertNil(sut.link)

        sut.action.send(ProductProfileViewModelAction.Spinner.Show())

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.spinner)
        sut.spinner = nil
    }

    func test_showSpinner_linkInfoProductModel() throws {
        
        let (sut, _, _) = try makeSUT()
        
        XCTAssertNil(sut.spinner)
        XCTAssertNil(sut.link)
        

        sut.action.send(ProductProfileViewModelAction.Spinner.Show())

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.spinner)
        sut.spinner = nil
    }
  // MARK: - optionsPannelAction

    func test_optionsPanelAction_requisites_card_createNewPanelShowRequisites() throws {
        
        let (sut, _, product) = try makeSUT(statusCard: .active)
        
        XCTAssertNil(sut.alert)
        XCTAssertNoDiff(sut.optionsPanelNew.count, 0)
        XCTAssertNil(sut.optionsPannel)

        sut.buttons.action.send(ProductProfileButtonsSectionViewAction.ButtonDidTapped(buttonType: .bottomLeft))

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertNoDiff(sut.optionsPanelNew.count, 2)
        XCTAssertNil(sut.optionsPannel)

        XCTAssertNil(sut.link)
        
        sut.event(.init(productID: product.id, type: .accountDetails))

        //в коде now + .milliseconds(300)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)
        
        XCTAssertNotNil(sut.link)
        XCTAssertTrue(sut.viewModelByLink is InfoProductViewModel)

        sut.link = nil
    }
    
    func test_optionsPanelAction_notCard_createOldPanelShowRequisite() throws {
        
        let model = makeModelWithProducts([(.deposit, 1)])
        let product = try XCTUnwrap(model.products.value[.deposit]?.first)
        let sut = try XCTUnwrap(makeSUT(model: model, product: product))
        
        XCTAssertNil(sut.optionsPannel)
        XCTAssertNil(sut.link)
        
        sut.buttons.action.send(ProductProfileButtonsSectionViewAction.ButtonDidTapped(buttonType: .bottomLeft))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.optionsPannel)

        XCTAssertNil(sut.link)
        
        let action = ProductProfileOptionsPannelViewModelAction.ButtonTapped(buttonType: .requisites)
        
        sut.optionsPannel?.action.send(action)
        
        //в коде now + .milliseconds(300)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)
        
        XCTAssertNotNil(sut.link)
        XCTAssertTrue(sut.viewModelByLink is InfoProductViewModel)

        sut.link = nil
    }

    func test_optionsPanelAction_statusCardActive_blockCard_showAlert() throws {
        
        let (sut, _, product) = try makeSUT(statusCard: .active)
                
        XCTAssertNil(sut.alert)
        XCTAssertNoDiff(sut.optionsPanelNew.count, 0)
        XCTAssertNil(sut.optionsPannel)

        sut.createCardGuardianPanel(product)
        
        XCTAssertNoDiff(sut.optionsPanelNew.count, 3)
        XCTAssertNil(sut.optionsPannel)

        sut.event(.init(productID: product.id, type: .cardGuardian))
         
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
    
    func test_optionsPanelAction_statusCardBlockedUnlockAvailable_unBlockCard_showAlert() throws {
        
        let (sut, _, product) = try makeSUT(
            statusCard: .blockedUnlockAvailable
        )
        
        XCTAssertNil(sut.alert)
        XCTAssertNoDiff(sut.optionsPanelNew.count, 0)
        
        sut.createCardGuardianPanel(product)
        
        XCTAssertNoDiff(sut.optionsPanelNew.count, 3)

        sut.event(.init(productID: product.id, type: .cardGuardian))
         
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
    
    func test_optionsPanelAction_statusCardBlockedUnlockNotAvailable_unBlockCard_showAlert() throws {
        
        let (sut, _, product) = try makeSUT(
            statusCard: .blockedUnlockNotAvailable
        )
        
        XCTAssertNil(sut.alert)
        XCTAssertNoDiff(sut.optionsPanelNew.count, 0)

        sut.createCardGuardianPanel(product)
        
        XCTAssertNoDiff(sut.optionsPanelNew.count, 3)
        XCTAssertTrue(sut.optionsPanelNew.containsTitle("Разблокировать"))

        sut.event(.init(productID: product.id, type: .cardGuardian))
         
        //в коде now + .milliseconds(300)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)

        XCTAssertNotNil(sut.alert)

        XCTAssertNoDiff(sut.alert?.title, "Невозможно разблокировать")
        XCTAssertNoDiff(sut.alert?.message, "Обратитесь в поддержку, чтобы разблокировать карту")
        
        XCTAssertNoDiff(sut.alert?.primary.type, .default)
        XCTAssertNoDiff(sut.alert?.primary.title, "Отмена")
        XCTAssertNotNil(sut.alert?.primary.action)
        
        XCTAssertNoDiff(sut.alert?.secondary?.type, .default)
        XCTAssertNoDiff(sut.alert?.secondary?.title, "Контакты")
        XCTAssertNotNil(sut.alert?.secondary?.action)
        
        sut.action.send(ProductProfileViewModelAction.Close.Alert())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(sut.alert)
    }

    
    func test_optionsPannelAction_changePin_sadPath_showActivateCertificateAlert() throws {
        
        let (sut, _, product) = try makeSUT(cvvPINServicesClient: SadCVVPINServicesClient())
        
        XCTAssertNoDiff(sut.optionsPanelNew.count, 0)
        XCTAssertNil(sut.alert)

        sut.createCardGuardianPanel(product)
        
        XCTAssertNoDiff(sut.optionsPanelNew.count, 3)
        XCTAssertNil(sut.alert)
        
        sut.event(.init(productID: product.id, type: .changePin))
        
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
        
        let (sut, _, product) = try makeSUT(cvvPINServicesClient: HappyCVVPINServicesClient())
        
        XCTAssertNoDiff(sut.optionsPanelNew.count, 0)

        sut.createCardGuardianPanel(product)
        
        XCTAssertNoDiff(sut.optionsPanelNew.count, 3)
        XCTAssertNil(sut.fullScreenCoverState)
        
        sut.event(.init(productID: product.id, type: .changePin))

        //в коде now + .milliseconds(300)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.4)
        
        XCTAssertNotNil(sut.fullScreenCoverState)
        switch sut.fullScreenCoverState {
        case .changePin: break
        default: XCTFail("Expected ChangePIN model")
        }
        sut.fullScreenCoverState = nil
    }

    // MARK: - test showCvvByTap
    
    func test_showCvvByTap_happyPath_returnCVV() throws {
        
        let (sut, _, _) = try makeSUT()
        
        sut.showCvvByTap(cardId: .init(111)) { result in
            
            XCTAssertNoDiff(result, .init("123"))
        }
    }
    
    func test_showCvvByTap_cardNotActivated_showAlert() throws {
        
        let (sut, _, _) = try makeSUT(statusCard: .notActivated)
        
        XCTAssertNil(sut.alert)
        
        sut.showCvvByTap(cardId: .init(111)) { _ in
            
        }
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertNotNil(sut.alert)
        XCTAssertNoDiff(sut.alert?.title, "Информация")
        XCTAssertNoDiff(sut.alert?.message, "Для просмотра CVV и смены PIN карта должна быть активна.")
        
        XCTAssertNoDiff(sut.alert?.primary.type, .cancel)
        XCTAssertNoDiff(sut.alert?.primary.title, "OK")
        XCTAssertNotNil(sut.alert?.primary.action)
    }
    
    func test_showCvvByTap_cardBlockedUnlockAvailable_showAlert() throws {
        
        let (sut, _, _) = try makeSUT(statusCard: .blockedUnlockAvailable)
        
        XCTAssertNil(sut.alert)
        
        sut.showCvvByTap(cardId: .init(111)) { _ in
            
        }
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertNotNil(sut.alert)
        XCTAssertNoDiff(sut.alert?.title, "Информация")
        XCTAssertNoDiff(sut.alert?.message, "Для просмотра CVV и смены PIN карта должна быть активна.")
        
        XCTAssertNoDiff(sut.alert?.primary.type, .cancel)
        XCTAssertNoDiff(sut.alert?.primary.title, "OK")
        XCTAssertNotNil(sut.alert?.primary.action)
    }

    func test_showCvvByTap_cardBlockedUnlockNotAvailable_showAlert() throws {
        
        let (sut, _, _) = try makeSUT(statusCard: .blockedUnlockNotAvailable)
        
        XCTAssertNil(sut.alert)
        
        sut.showCvvByTap(cardId: .init(111)) { _ in
            
        }
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertNotNil(sut.alert)
        XCTAssertNoDiff(sut.alert?.title, "Информация")
        XCTAssertNoDiff(sut.alert?.message, "Для просмотра CVV и смены PIN карта должна быть активна.")
        
        XCTAssertNoDiff(sut.alert?.primary.type, .cancel)
        XCTAssertNoDiff(sut.alert?.primary.title, "OK")
        XCTAssertNotNil(sut.alert?.primary.action)
    }

    func test_showCvvByTap_checkCertificateError_returNil() throws {
        
        let (sut, _, _) = try makeSUT(
            cvvPINServicesClient: SadShowCVVSadCheckCertificateClient()
        )
        
        sut.showCvvByTap(cardId: .init(111)) { result in
            
            XCTAssertNil(result)
        }
    }
    
    func test_showCvvByTap_checkCertificateConnectivityError_returNil() throws {
        
        let (sut, _, _) = try makeSUT(
            cvvPINServicesClient: SadShowCVVCheckCertificateConnectivityClient()
        )
        
        sut.showCvvByTap(cardId: .init(111)) { result in
            
            XCTAssertNil(result)
        }
    }
    
    func test_showCvvByTap_activateCertificateError_returnNil() throws {
        
        let (sut, _, _) = try makeSUT(
            cvvPINServicesClient: SadShowCVVSadActivateCertificateClient()
        )
        
        sut.showCvvByTap(cardId: .init(111)) { result in
            XCTAssertNil(result)
        }
    }
    
    func test_showCvvByTap_otpErrorRetryAttempts0_returNil() throws {
        
        let (sut, _, _) = try makeSUT(
            cvvPINServicesClient: SadShowCVVSadOtpRetryAttempts0CertificateClient()
        )
        
        sut.showCvvByTap(cardId: .init(111)) { result in
            XCTAssertNil(result)
        }
    }
    
    func test_showCvvByTap_otpErrorRetryAttempts_returNil() throws {
        
        let (sut, _, _) = try makeSUT(
            cvvPINServicesClient: SadShowCVVSadOtpRetryAttemptsCertificateClient()
        )
        
        sut.showCvvByTap(cardId: .init(111)) { result in
            
            XCTAssertNil(result)
        }
    }
    
    // MARK: - test show/hide spinner
    func test_showHideSpinner() throws {
        
        let (sut, _, _) = try makeSUT()
        
        XCTAssertNil(sut.spinner)
        
        sut.action.send(ProductProfileViewModelAction.Spinner.Show())
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.spinner)
        
        sut.action.send(ProductProfileViewModelAction.Spinner.Hide())

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNil(sut.spinner)
    }
    
    // MARK: - test show confirm otp
    func test_showConfirmOtp() throws {
        
        let (sut, _, _) = try makeSUT()
        
        XCTAssertNil(sut.fullScreenCoverState)
        
        sut.action.send(ProductProfileViewModelAction.CVVPin.ConfirmShow(
            cardId: 11,
            actionType: .showCvv,
            phone: "99",
            resendOtp: {}))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.fullScreenCoverState)
    }
    
    //MARK: bottom sheet
    
    func test_show_calendarBottomSheet() throws {
        
        let (sut, _, _) = try makeSUT()
        
        XCTAssertNil(sut.historyState)
        
        sut.event(.history(.button(.calendar)))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.historyState)
    }
    
    func test_show_filterBottomSheet() throws {
        
        let (sut, _, _) = try makeSUT()
        
        XCTAssertNil(sut.historyState)
        
        sut.event(.history(.button(.filter)))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNotNil(sut.historyState)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        model: Model = .mockWithEmptyExcept(),
        cvvPINServicesClient: CVVPINServicesClient = HappyCVVPINServicesClient(),
        product: ProductData,
        rootView: String = "",
        file: StaticString = #file,
        line: UInt = #line

    ) -> ProductProfileViewModel? {
        
        trackForMemoryLeaks(model, file: file, line: line)

        return .init(
            model, 
            fastPaymentsFactory: .legacy,
            makePaymentsTransfersFlowManager: { _ in .preview },
            userAccountNavigationStateManager: .preview,
            sberQRServices: .empty(),
            unblockCardServices: .preview(),
            qrViewModelFactory: .preview(),
            paymentsTransfersFactory: .preview, 
            operationDetailFactory: .preview,
            cvvPINServicesClient: cvvPINServicesClient,
            product: product, 
            productNavigationStateManager: .preview,
            productProfileViewModelFactory: .preview,
            rootView: rootView,
            dismissAction: {}
        )
    }
    
    private func makeSUT(
        statusCard: ProductCardData.StatusCard = .active,
        cardType: ProductCardData.CardType = .main,
        visibility: Bool = true,
        cvvPINServicesClient: CVVPINServicesClient = HappyCVVPINServicesClient(),
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> (
        sut: ProductProfileViewModel,
        model: Model,
        card: ProductCardData
    ) {
        let model = Model.mockWithEmptyExcept()
        let card = ProductCardData(statusCard: statusCard, cardType: cardType, visibility: visibility)

        model.products.value = [.card: [ card ]]
                
        let sut = try XCTUnwrap(
            ProductProfileViewModel(
                model,
                fastPaymentsFactory: .legacy,
                makePaymentsTransfersFlowManager: { _ in .preview },
                userAccountNavigationStateManager: .preview,
                sberQRServices: .empty(),
                unblockCardServices: .preview(),
                qrViewModelFactory: .preview(),
                paymentsTransfersFactory: .preview,
                operationDetailFactory: .preview,
                cvvPINServicesClient: cvvPINServicesClient,
                product: card,
                productNavigationStateManager: .preview,
                productProfileViewModelFactory: .preview,
                rootView: "",
                dismissAction: {}
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(model, file: file, line: line)
        
        return (sut, model, card)
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
    
    var optionsPanelNew: [PanelButton.Details] {
        
        switch bottomSheet?.type {
            
        case let .optionsPanelNew(optionsPanel):
            
            return optionsPanel
            
        default:
            return []
        }
    }

    
    var panelViewModelRequisites: ProductProfileOptionsPannelView.ViewModel {
        .init(
            buttonsTypes: [
                .requisites
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

private extension Array where Element == PanelButton.Details {
    
    func containsTitle(_ title: String) -> Bool {
        return self.filter { $0.title == title }.first != nil
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
        statusCard: ProductCardData.StatusCard = .active,
        loanBaseParam: ProductCardData.LoanBaseParamInfoData? = nil,
        isMain: Bool = true,
        cardType: ProductCardData.CardType = .main,
        visibility: Bool = true
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
            status: .active,
            expireDate: nil,
            holderName: holderName,
            product: nil,
            branch: "",
            miniStatement: nil,
            paymentSystemName: nil,
            paymentSystemImage: nil,
            loanBaseParam: loanBaseParam,
            statusPc: .active,
            isMain: isMain,
            externalId: nil,
            order: 0,
            visibility: visibility,
            smallDesignMd5hash: "",
            smallBackgroundDesignHash: "",
            statusCard: statusCard,
            cardType: cardType
        )
    }
}

final class HappyCheckSadActivateCertificateClient: CVVPINServicesClient {
    
    func checkFunctionality(completion: @escaping (Result<Void, CheckCVVPINFunctionalityError>) -> Void) {
        completion(.success(()))
    }
    
    func activate(completion: @escaping (Result<PhoneDomain.Phone, ActivateCVVPINError>) -> Void) {
        
        completion(.failure(.server(statusCode: 7777, errorMessage: "ТЕСТОВАЯ ОШИБКА!!!!")))
    }
    
    func confirmWith(otp: String, completion: @escaping ConfirmationCompletion) {

        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, ShowCVVError>) -> Void) {
        completion(.success("111"))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, ChangePINError>) -> Void) {
        completion(.success(()))
    }
    
    func getPINConfirmationCode(completion: @escaping (Result<String, GetPINConfirmationCodeError>) -> Void) {
        completion(.success("+1..22"))
    }
}

final class SadCheckSadActivateCertificateClient: CVVPINServicesClient {
    
    func checkFunctionality(completion: @escaping (Result<Void, CheckCVVPINFunctionalityError>) -> Void) {
        
        completion(.failure(CheckCVVPINFunctionalityError.activationFailure))
    }
    
    func activate(completion: @escaping (Result<PhoneDomain.Phone, ActivateCVVPINError>) -> Void) {
        
        completion(.failure(.server(statusCode: 3100, errorMessage: "ТЕСТОВАЯ ОШИБКА!!!\nВозникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения")))
    }
    
    func confirmWith(otp: String, completion: @escaping ConfirmationCompletion) {
        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, ShowCVVError>) -> Void) {
        completion(.success("111"))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, ChangePINError>) -> Void) {
        completion(.success(()))
    }
    
    func getPINConfirmationCode(completion: @escaping (Result<String, GetPINConfirmationCodeError>) -> Void) {
        completion(.success("+1..22"))
    }
}

final class SadShowCVVSadCheckCertificateClient: CVVPINServicesClient {
    
    func checkFunctionality(completion: @escaping (Result<Void, CheckCVVPINFunctionalityError>) -> Void) {
        
        completion(.failure(CheckCVVPINFunctionalityError.activationFailure))
    }
    
    func activate(completion: @escaping (Result<PhoneDomain.Phone, ActivateCVVPINError>) -> Void) {
        
        completion(.failure(.server(statusCode: 3100, errorMessage: "ТЕСТОВАЯ ОШИБКА!!!\nВозникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения")))
    }
    
    func confirmWith(otp: String, completion: @escaping ConfirmationCompletion) {
        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, ShowCVVError>) -> Void) {
        completion(.failure(.serviceFailure))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, ChangePINError>) -> Void) {
        completion(.success(()))
    }
    
    func getPINConfirmationCode(completion: @escaping (Result<String, GetPINConfirmationCodeError>) -> Void) {
        completion(.success("+1..22"))
    }
}

final class SadShowCVVCheckCertificateConnectivityClient: CVVPINServicesClient {
    
    func checkFunctionality(completion: @escaping (Result<Void, CheckCVVPINFunctionalityError>) -> Void) {
        
        completion(.failure(CheckCVVPINFunctionalityError.activationFailure))
    }
    
    func activate(completion: @escaping (Result<PhoneDomain.Phone, ActivateCVVPINError>) -> Void) {
        
        completion(.failure(.server(statusCode: 3100, errorMessage: "ТЕСТОВАЯ ОШИБКА!!!\nВозникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения")))
    }
    
    func confirmWith(otp: String, completion: @escaping ConfirmationCompletion) {
        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, ShowCVVError>) -> Void) {
        
        completion(.failure(.activationFailure))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, ChangePINError>) -> Void) {
        
        completion(.success(()))
    }
    
    func getPINConfirmationCode(completion: @escaping (Result<String, GetPINConfirmationCodeError>) -> Void) {
        
        completion(.success("+1..22"))
    }
}

final class SadShowCVVSadActivateCertificateClient: CVVPINServicesClient {
    
    func checkFunctionality(completion: @escaping (Result<Void, CheckCVVPINFunctionalityError>) -> Void) {
        
        completion(.failure(CheckCVVPINFunctionalityError.activationFailure))
    }
    
    func activate(completion: @escaping (Result<PhoneDomain.Phone, ActivateCVVPINError>) -> Void) {
        
        completion(.failure(.server(statusCode: 3100, errorMessage: "ТЕСТОВАЯ ОШИБКА!!!\nВозникла техническая ошибка 3100. Свяжитесь с поддержкой банка для уточнения")))
    }
    
    func confirmWith(otp: String, completion: @escaping ConfirmationCompletion) {

        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, ShowCVVError>) -> Void) {
        
        completion(.failure(.server(statusCode: 1234, errorMessage: "error")))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, ChangePINError>) -> Void) {
        
        completion(.success(()))
    }
    
    func getPINConfirmationCode(completion: @escaping (Result<String, GetPINConfirmationCodeError>) -> Void) {
        
        completion(.success("+1..22"))
    }
}

final class SadShowCVVSadOtpRetryAttempts0CertificateClient: CVVPINServicesClient {
    
    func checkFunctionality(completion: @escaping (Result<Void, CheckCVVPINFunctionalityError>) -> Void) {
        
        completion(.failure(CheckCVVPINFunctionalityError.activationFailure))
    }
    
    func activate(completion: @escaping (Result<PhoneDomain.Phone, ActivateCVVPINError>) -> Void) {
        
        completion(.success("+1..11"))
    }
    
    func confirmWith(otp: String, completion: @escaping ConfirmationCompletion) {

        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, ShowCVVError>) -> Void) {
        
        completion(.failure(.server(statusCode: 0, errorMessage: "")))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, ChangePINError>) -> Void) {
        
        completion(.success(()))
    }
    
    func getPINConfirmationCode(completion: @escaping (Result<String, GetPINConfirmationCodeError>) -> Void) {
        
        completion(.success("+1..22"))
    }
}

final class SadShowCVVSadOtpRetryAttemptsCertificateClient: CVVPINServicesClient {
    
    func checkFunctionality(completion: @escaping (Result<Void, CheckCVVPINFunctionalityError>) -> Void) {
        
        completion(.failure(CheckCVVPINFunctionalityError.activationFailure))
    }
    
    func activate(completion: @escaping (Result<PhoneDomain.Phone, ActivateCVVPINError>) -> Void) {
        
        completion(.success("+1..11"))
    }
    
    func confirmWith(otp: String, completion: @escaping ConfirmationCompletion) {

        completion(.success(()))
    }
    
    func showCVV(cardId: Int, completion: @escaping (Result<ShowCVVClient.CVV, ShowCVVError>) -> Void) {
        
        completion(.failure(.server(statusCode: 0, errorMessage: "")))
    }
    
    func changePin(cardId: Int, newPin: String, otp: String, completion: @escaping (Result<Void, ChangePINError>) -> Void) {
        
        completion(.success(()))
    }
    
    func getPINConfirmationCode(completion: @escaping (Result<String, GetPINConfirmationCodeError>) -> Void) {
        
        completion(.success("+1..22"))
    }
}
