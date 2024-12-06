//
//  OrderProductViewComponentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 27.04.2023.
//

@testable import ForaBank
import XCTest

final class OrderProductViewComponentTests: XCTestCase {
    
    // MARK: - init

    func test_init_shouldSetInitialValues() {
        
        let sut = makeSUT()
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.isUserInteractionEnabled, true)
        XCTAssertEqual(sut.isOrderCompletion, false)
        XCTAssertEqual(sut.isValidPhoneNumber, false)
        XCTAssertEqual(sut.isSmsCode, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        
        XCTAssertNotNil(sut.nameTextField)
        XCTAssertNotNil(sut.phoneNumber)
        XCTAssertNotNil(sut.smsCode)
        XCTAssertNotNil(sut.agreeData)
        XCTAssertNotNil(sut.sendButton)
        
        XCTAssertEqual(sut.notify, .init())
        XCTAssertEqual(sut.title, "Заполните информацию")
        XCTAssertEqual(sut.detailTitle, "В ближайшее время Вам позвонит\nсотрудник банка для\nподтверждения данных")

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.isUserInteractionEnabled, true)
        XCTAssertEqual(sut.isOrderCompletion, false)
        XCTAssertEqual(sut.isValidPhoneNumber, false)
        XCTAssertEqual(sut.isSmsCode, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        
        XCTAssertNotNil(sut.nameTextField)
        XCTAssertNotNil(sut.phoneNumber)
        XCTAssertNotNil(sut.smsCode)
        XCTAssertNotNil(sut.agreeData)
        XCTAssertNotNil(sut.sendButton)
        
        XCTAssertEqual(sut.notify, .init())
        XCTAssertEqual(sut.title, "Заполните информацию")
        XCTAssertEqual(sut.detailTitle, "В ближайшее время Вам позвонит\nсотрудник банка для\nподтверждения данных")
    }
    
    func test_init_shouldSetInitialValues_nameTextField() {
        
        let sut = makeSUT()
        
        XCTAssertEqual(sut.nameTextField.text, "")
        XCTAssertEqual(sut.nameTextField.isEditing, false)
        XCTAssertEqual(sut.nameTextField.isResend, false)
        XCTAssertEqual(sut.nameTextField.isError, false)
        XCTAssertEqual(sut.nameTextField.isUserInteractionEnabled, true)
        XCTAssertNil(sut.nameTextField.timer)
        XCTAssertEqual(sut.nameTextField.kind, .name)
        XCTAssertEqual(sut.nameTextField.isActive, false)

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertEqual(sut.nameTextField.text, "")
        XCTAssertEqual(sut.nameTextField.isEditing, false)
        XCTAssertEqual(sut.nameTextField.isResend, false)
        XCTAssertEqual(sut.nameTextField.isError, false)
        XCTAssertEqual(sut.nameTextField.isUserInteractionEnabled, true)
        XCTAssertNil(sut.nameTextField.timer)
        XCTAssertEqual(sut.nameTextField.kind, .name)
        XCTAssertEqual(sut.nameTextField.isActive, false)
    }
    
    func test_init_shouldSetInitialValues_phoneNumber() {
        
        let sut = makeSUT()
        
        XCTAssertEqual(sut.phoneNumber.state, .placeholder("Мобильный телефон"))
        XCTAssertEqual(sut.phoneNumber.text, nil)
        XCTAssertEqual(sut.phoneNumber.isActive, false)
        XCTAssertEqual(sut.phoneNumber.state.isEditing, false)
        XCTAssertEqual(sut.phoneNumber.hasValue, false)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.phoneNumber.state, .placeholder("Мобильный телефон"))
        XCTAssertEqual(sut.phoneNumber.text, nil)
        XCTAssertEqual(sut.phoneNumber.isActive, false)
        XCTAssertEqual(sut.phoneNumber.state.isEditing, false)
        XCTAssertEqual(sut.phoneNumber.hasValue, false)
    }
    
    func test_init_shouldSetInitialValues_smsCode() {
        
        let sut = makeSUT()
        
        XCTAssertNotNil(sut.smsCode)
        XCTAssertEqual(sut.smsCode.width, 55)
        XCTAssertEqual(sut.smsCode.text, "")
        XCTAssertEqual(sut.smsCode.isEditing, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.smsCode.isError, false)
        XCTAssertEqual(sut.smsCode.isUserInteractionEnabled, true)
        XCTAssertNil(sut.smsCode.timer)
        XCTAssertEqual(sut.smsCode.kind, .smsCode)
        XCTAssertEqual(sut.smsCode.isActive, false)

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertNotNil(sut.smsCode)
        XCTAssertEqual(sut.smsCode.width, 55)
        XCTAssertEqual(sut.smsCode.text, "")
        XCTAssertEqual(sut.smsCode.isEditing, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.smsCode.isError, false)
        XCTAssertEqual(sut.smsCode.isUserInteractionEnabled, true)
        XCTAssertNil(sut.smsCode.timer)
        XCTAssertEqual(sut.smsCode.kind, .smsCode)
        XCTAssertEqual(sut.smsCode.isActive, false)
    }
    
    func test_init_shouldSetInitialValues_agreeData() {
        
        let sut = makeSUT()
        
        XCTAssertNotNil(sut.agreeData)
        XCTAssertEqual(sut.agreeData.isChecked, true)
        XCTAssertEqual(sut.agreeData.iTitle, "Я")
        XCTAssertEqual(sut.agreeData.agreeTitle, "соглашаюсь")
        XCTAssertEqual(sut.agreeData.personalTitle, "на обработку моих")
        XCTAssertEqual(sut.agreeData.processing, "персональных данных")
        
        XCTAssertNotNil(sut.agreeData.checkBox)
        XCTAssertEqual(sut.agreeData.checkBox.isChecked, true)
        XCTAssertEqual(sut.agreeData.checkBox.lineWidth, 1.25)
        XCTAssertEqual(sut.agreeData.checkBox.strokeColor, .mainColorsGray)
        XCTAssertEqual(sut.agreeData.checkBox.strokeStyle, .init(lineWidth: 1.25, lineCap: .round, lineJoin: .miter, miterLimit: 10.0, dash: [123.0], dashPhase: 70.0))

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertNotNil(sut.agreeData)
        XCTAssertEqual(sut.agreeData.isChecked, true)
        XCTAssertEqual(sut.agreeData.iTitle, "Я")
        XCTAssertEqual(sut.agreeData.agreeTitle, "соглашаюсь")
        XCTAssertEqual(sut.agreeData.personalTitle, "на обработку моих")
        XCTAssertEqual(sut.agreeData.processing, "персональных данных")
        
        XCTAssertNotNil(sut.agreeData.checkBox)
        XCTAssertEqual(sut.agreeData.checkBox.isChecked, true)
        XCTAssertEqual(sut.agreeData.checkBox.lineWidth, 1.25)
        XCTAssertEqual(sut.agreeData.checkBox.strokeColor, .mainColorsGray)
        XCTAssertEqual(sut.agreeData.checkBox.strokeStyle, .init(lineWidth: 1.25, lineCap: .round, lineJoin: .miter, miterLimit: 10.0, dash: [123.0], dashPhase: 70.0))
    }
    
    func test_init_shouldSetInitialValues_sendButton() {
        
        let sut = makeSUT()
        
        XCTAssertNotNil(sut.sendButton)
        XCTAssertEqual(sut.sendButton.style, .gray)
        XCTAssertEqual(sut.sendButton.state, .button)
        XCTAssertEqual(sut.sendButton.title, "Отправить")
        XCTAssertEqual(sut.sendButton.icon, .init("Logo Fora Bank"))
        XCTAssertEqual(sut.sendButton.color, .mainColorsGrayMedium)
        XCTAssertEqual(sut.sendButton.isDisabled, true)

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        XCTAssertNotNil(sut.sendButton)
        XCTAssertEqual(sut.sendButton.style, .gray)
        XCTAssertEqual(sut.sendButton.state, .button)
        XCTAssertEqual(sut.sendButton.title, "Отправить")
        XCTAssertEqual(sut.sendButton.icon, .init("Logo Fora Bank"))
        XCTAssertEqual(sut.sendButton.color, .mainColorsGrayMedium)
        XCTAssertEqual(sut.sendButton.isDisabled, true)
    }
    
    // MARK: - ModelAction.Auth.OrderLead.Response
    
    func test_shouldNotFlipState_onOrderLeadSuccessResponse_nil() {
        
        let model: Model = .productsMock
        let sut = makeSUT(model: model)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(sut.isSmsCode, false)
        
        let successResponse = ModelAction.Auth.OrderLead.Response.success(leadID: nil)
        model.sendAndWait(successResponse)
                
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(sut.isSmsCode, true)
    }
    
    func test_shouldNotFlipState_onOrderLeadSuccessResponse_nonNil() {
        
        let model: Model = .productsMock
        let sut = makeSUT(model: model)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(sut.isSmsCode, false)
        
        let successResponse = ModelAction.Auth.OrderLead.Response.success(leadID: 123)
        model.sendAndWait(successResponse)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(sut.isSmsCode, true)
    }
    
    func test_shouldFlipState_onOrderLeadErrorResponse() {
        
        let model: Model = .productsMock
        let sut = makeSUT(model: model)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(sut.isSmsCode, false)
        
        let errorResponse = ModelAction.Auth.OrderLead.Response.error(message: "Order Lead Error")
        model.sendAndWait(errorResponse)
                
        XCTAssertEqual(sut.isError, true)
        // TODO: fix prod to flip to error
        XCTAssertEqual(sut.state, .normal)
        
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(sut.alert?.title, "Ошибка")
        XCTAssertEqual(sut.alert?.message, "Order Lead Error")
        XCTAssertNotNil(sut.alert?.primary)
        XCTAssertEqual(sut.alert?.primary.type, .default)
        XCTAssertEqual(sut.alert?.primary.title, "Ok")
        XCTAssertNil(sut.alert?.secondary)

        XCTAssertEqual(sut.isSmsCode, true)
    }
    
    func test_shouldFlipState_onOrderLeadResponses() {
        
        let model: Model = .productsMock
        let sut = makeSUT(model: model)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(sut.isSmsCode, false)
        
        let errorResponse = ModelAction.Auth.OrderLead.Response.error(message: "Order Lead Error")
        model.sendAndWait(errorResponse)
                
        XCTAssertEqual(sut.isError, true)
        // TODO: fix prod to flip to error
        XCTAssertEqual(sut.state, .normal)
        
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(sut.alert?.title, "Ошибка")
        XCTAssertEqual(sut.alert?.message, "Order Lead Error")
        XCTAssertNotNil(sut.alert?.primary)
        XCTAssertEqual(sut.alert?.primary.type, .default)
        XCTAssertEqual(sut.alert?.primary.title, "Ok")
        XCTAssertNil(sut.alert?.secondary)

        XCTAssertEqual(sut.isSmsCode, true)
        
        let successResponse = ModelAction.Auth.OrderLead.Response.success(leadID: 123)
        model.sendAndWait(successResponse)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        
        // TODO: fix prod to nil out alert on success
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(sut.alert?.title, "Ошибка")
        XCTAssertEqual(sut.alert?.message, "Order Lead Error")
        XCTAssertNotNil(sut.alert?.primary)
        XCTAssertEqual(sut.alert?.primary.type, .default)
        XCTAssertEqual(sut.alert?.primary.title, "Ok")
        XCTAssertNil(sut.alert?.secondary)

        XCTAssertEqual(sut.isSmsCode, true)
    }
    
    // MARK: - ModelAction.Auth.VerifyPhone.Response
    
    func test_shouldNotFlipState_onVerifyPhoneSuccessResponse() {
        
        let model: Model = .productsMock
        let sut = makeSUT(model: model)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(sut.isOrderCompletion, false)
        XCTAssertEqual(sut.isSmsCode, false)
        
        XCTAssertNotNil(sut.smsCode)
        XCTAssertEqual(sut.smsCode.width, 55)
        XCTAssertEqual(sut.smsCode.text, "")
        XCTAssertEqual(sut.smsCode.isEditing, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.smsCode.isError, false)
        XCTAssertEqual(sut.smsCode.isUserInteractionEnabled, true)
        XCTAssertNil(sut.smsCode.timer)
        XCTAssertEqual(sut.smsCode.kind, .smsCode)
        XCTAssertEqual(sut.smsCode.isActive, false)
        
        let successResponse = ModelAction.Auth.VerifyPhone.Response.success
        model.sendAndWait(successResponse)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(sut.isOrderCompletion, true)
        XCTAssertEqual(sut.isSmsCode, false)
        
        XCTAssertNotNil(sut.smsCode)
        XCTAssertEqual(sut.smsCode.width, 55)
        XCTAssertEqual(sut.smsCode.text, "")
        XCTAssertEqual(sut.smsCode.isEditing, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.smsCode.isError, false)
        XCTAssertEqual(sut.smsCode.isUserInteractionEnabled, true)
        XCTAssertNil(sut.smsCode.timer)
        XCTAssertEqual(sut.smsCode.kind, .smsCode)
        XCTAssertEqual(sut.smsCode.isActive, false)
    }
    
    func test_shouldFlipState_onVerifyPhoneErrorResponse() {
        
        let model: Model = .productsMock
        let sut = makeSUT(model: model)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(sut.isSmsCode, false)
        
        XCTAssertNotNil(sut.smsCode)
        XCTAssertEqual(sut.smsCode.width, 55)
        XCTAssertEqual(sut.smsCode.text, "")
        XCTAssertEqual(sut.smsCode.isEditing, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.smsCode.isError, false)
        XCTAssertEqual(sut.smsCode.isUserInteractionEnabled, true)
        XCTAssertNil(sut.smsCode.timer)
        XCTAssertEqual(sut.smsCode.kind, .smsCode)
        XCTAssertEqual(sut.smsCode.isActive, false)

        let errorResponse = ModelAction.Auth.VerifyPhone.Response.error(message: "Order Lead Error")
        model.sendAndWait(errorResponse)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .error)
        
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(sut.alert?.title, "Ошибка")
        XCTAssertEqual(sut.alert?.message, "Order Lead Error")
        XCTAssertNotNil(sut.alert?.primary)
        XCTAssertEqual(sut.alert?.primary.type, .default)
        XCTAssertEqual(sut.alert?.primary.title, "Ok")
        XCTAssertNil(sut.alert?.secondary)
        
        XCTAssertEqual(sut.isSmsCode, false)
        
        XCTAssertNotNil(sut.smsCode)
        XCTAssertEqual(sut.smsCode.width, 55)
        XCTAssertEqual(sut.smsCode.text, "")
        XCTAssertEqual(sut.smsCode.isEditing, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.smsCode.isError, true)
        XCTAssertEqual(sut.smsCode.isUserInteractionEnabled, true)
        XCTAssertNil(sut.smsCode.timer)
        XCTAssertEqual(sut.smsCode.kind, .smsCode)
        XCTAssertEqual(sut.smsCode.isActive, false)
    }
    
    func test_shouldFlipState_onVerifyPhoneResponses() {
        
        let model: Model = .productsMock
        let sut = makeSUT(model: model)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .normal)
        XCTAssertNil(sut.alert)
        XCTAssertEqual(sut.isSmsCode, false)
        
        XCTAssertNotNil(sut.smsCode)
        XCTAssertEqual(sut.smsCode.width, 55)
        XCTAssertEqual(sut.smsCode.text, "")
        XCTAssertEqual(sut.smsCode.isEditing, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.smsCode.isError, false)
        XCTAssertEqual(sut.smsCode.isUserInteractionEnabled, true)
        XCTAssertNil(sut.smsCode.timer)
        XCTAssertEqual(sut.smsCode.kind, .smsCode)
        XCTAssertEqual(sut.smsCode.isActive, false)

        let errorResponse = ModelAction.Auth.VerifyPhone.Response.error(message: "Order Lead Error")
        model.sendAndWait(errorResponse)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .error)
        
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(sut.alert?.title, "Ошибка")
        XCTAssertEqual(sut.alert?.message, "Order Lead Error")
        XCTAssertNotNil(sut.alert?.primary)
        XCTAssertEqual(sut.alert?.primary.type, .default)
        XCTAssertEqual(sut.alert?.primary.title, "Ok")
        XCTAssertNil(sut.alert?.secondary)
        
        XCTAssertEqual(sut.isSmsCode, false)
        
        XCTAssertNotNil(sut.smsCode)
        XCTAssertEqual(sut.smsCode.width, 55)
        XCTAssertEqual(sut.smsCode.text, "")
        XCTAssertEqual(sut.smsCode.isEditing, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.smsCode.isError, true)
        XCTAssertEqual(sut.smsCode.isUserInteractionEnabled, true)
        XCTAssertNil(sut.smsCode.timer)
        XCTAssertEqual(sut.smsCode.kind, .smsCode)
        XCTAssertEqual(sut.smsCode.isActive, false)

        let successResponse = ModelAction.Auth.VerifyPhone.Response.success
        model.sendAndWait(successResponse)
        
        XCTAssertEqual(sut.isError, false)
        XCTAssertEqual(sut.state, .error)
        
        // TODO: Alert should be nilled out
        XCTAssertNotNil(sut.alert)
        XCTAssertEqual(sut.alert?.title, "Ошибка")
        XCTAssertEqual(sut.alert?.message, "Order Lead Error")
        XCTAssertNotNil(sut.alert?.primary)
        XCTAssertEqual(sut.alert?.primary.type, .default)
        XCTAssertEqual(sut.alert?.primary.title, "Ok")
        XCTAssertNil(sut.alert?.secondary)
        
        XCTAssertEqual(sut.isOrderCompletion, true)
        XCTAssertEqual(sut.isSmsCode, false)
        
        XCTAssertNotNil(sut.smsCode)
        XCTAssertEqual(sut.smsCode.width, 55)
        XCTAssertEqual(sut.smsCode.text, "")
        XCTAssertEqual(sut.smsCode.isEditing, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.smsCode.isError, false)
        XCTAssertEqual(sut.smsCode.isUserInteractionEnabled, true)
        XCTAssertNil(sut.smsCode.timer)
        XCTAssertEqual(sut.smsCode.kind, .smsCode)
        XCTAssertEqual(sut.smsCode.isActive, false)
    }
    
    // MARK: - sendButton action
    
    func test_shouldChangeStateToLoading_onOrderProductActionSendButtonTap_smsFalse() {
        
        let sut = makeSUT()

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.isSmsCode, false)
        XCTAssertEqual(sut.state, .normal)
        
        sendAndWait(OrderProductAction.Send.Button.Tap(), sut: sut)
        
        XCTAssertEqual(sut.state, .loading)
    }
        
    func test_shouldChangeStateToLoading_onOrderProductActionSendButtonTap_smsTrue() {
        
        let sut = makeSUT()

        sut.isSmsCode = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.isSmsCode, true)
        XCTAssertEqual(sut.state, .normal)
        
        sendAndWait(OrderProductAction.Send.Button.Tap(), sut: sut)
        
        XCTAssertEqual(sut.state, .loading)
    }
        
    // MARK: - smsCode action
    
    func test_shouldNotChangeState_onOrderProductActionResendTap() {
        
        let sut = makeSUT()

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.isSmsCode, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.state, .normal)
        
        sendAndWait(OrderProductAction.Resend.Tap(), sut: sut)
        
        XCTAssertEqual(sut.isSmsCode, false)
        XCTAssertEqual(sut.smsCode.isResend, false)
        XCTAssertEqual(sut.state, .normal)
    }
        
    // MARK: - smsCode text
    
    func test_shouldChangeSendButtonStyle_onTextInputLength() {
        
        let sut = makeSUT()

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.sendButton.style, .gray)
        
        smsAndWait("", sut: sut)
        
        XCTAssertEqual(sut.sendButton.style, .gray)
        XCTAssertNotEqual(sut.smsCode.text.count, 6)
        
        smsAndWait("12345", sut: sut)
        
        XCTAssertEqual(sut.sendButton.style, .gray)
        XCTAssertNotEqual(sut.smsCode.text.count, 6)
        
        smsAndWait("123456", sut: sut)
        
        XCTAssertEqual(sut.sendButton.style, .red)
        XCTAssertEqual(sut.smsCode.text.count, 6)
        
        smsAndWait("1234567", sut: sut)
        
        // TODO: fix in prod
        XCTAssertEqual(sut.sendButton.style, .red)
        XCTAssertNotEqual(sut.smsCode.text.count, 6)
    }
        
    // MARK: - stateChange
    
    func test_stateChange_shouldChangeSendButton() {
        
        let sut = makeSUT()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(sut.sendButton.state, .button)
        XCTAssertEqual(sut.sendButton.style, .gray)
        
        stateAndWait(.error, sut: sut)
        
        XCTAssertEqual(sut.state, .error)
        XCTAssertEqual(sut.sendButton.state, .button)
        XCTAssertEqual(sut.sendButton.style, .red)

        stateAndWait(.loading, sut: sut)
        
        XCTAssertEqual(sut.state, .loading)
        XCTAssertEqual(sut.sendButton.state, .spinner)
        XCTAssertEqual(sut.sendButton.style, .red)

        stateAndWait(.error, sut: sut)
        
        XCTAssertEqual(sut.state, .error)
        XCTAssertEqual(sut.sendButton.state, .button)
        XCTAssertEqual(sut.sendButton.style, .red)

        stateAndWait(.normal, sut: sut)
        
        XCTAssertEqual(sut.state, .normal)
        XCTAssertEqual(sut.sendButton.state, .button)
        XCTAssertEqual(sut.sendButton.style, .gray)
    }
    
    // MARK: - isValidatePersonalData
    
    func test_isValidatePersonalData_shouldChange_onInput() {
        
        let sut = makeSUT()
        let spy = ValueSpy(sut.isValidatePersonalData)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [false, false])

        sut.agreeData.isChecked = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [false, false, false])

        sut.nameTextField.text = "Abc"
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [false, false, false, false])

        sut.isValidPhoneNumber = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [false, false, false, false, true])
    }
    
    func test_shouldChangeSendButtonStyle_onIsValidatePersonalDataChange() {
        
        let sut = makeSUT()
        let spy = ValueSpy(sut.isValidatePersonalData)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values.last, false)
        XCTAssertEqual(sut.sendButton.style, .gray)
        
        sut.agreeData.isChecked = true
        sut.nameTextField.text = "Abc"
        sut.isValidPhoneNumber = true

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values.last, true)
        XCTAssertEqual(sut.sendButton.style, .red)
        
        sut.isValidPhoneNumber = false

        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values.last, false)
        XCTAssertEqual(sut.sendButton.style, .gray)
    }
    
    // MARK: - isValidateSmsCode
    
    func test_isValidateSmsCode_shouldChange_onInput() {
        
        let sut = makeSUT()
        let spy = ValueSpy(sut.isValidateSmsCode)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [false, false])

        sut.agreeData.isChecked = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [false, false, false])

        sut.nameTextField.text = "Abc"
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [false, false, false, false])

        sut.isValidPhoneNumber = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [false, false, false, false, false])

        smsAndWait("1234", sut: sut)
        
        XCTAssertEqual(spy.values, [false, false, false, false, false, true])
    }
    
    func test_shouldChangeSendButtonStyle_onIsValidateSmsCode() {
        
        let sut = makeSUT()
        let spy = ValueSpy(sut.isValidateSmsCode)
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.isSmsCode, false)
        XCTAssertEqual(spy.values.last, false)
        XCTAssertEqual(sut.sendButton.style, .gray)

        sut.agreeData.isChecked = true
        sut.nameTextField.text = "Abc"
        sut.isValidPhoneNumber = true
        sut.smsCode.text = "1234"
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.isSmsCode, false)
        XCTAssertEqual(spy.values.last, true)
        XCTAssertEqual(sut.sendButton.style, .red)
        
        sut.isSmsCode = true
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.isSmsCode, true)
        XCTAssertEqual(spy.values.last, true)
        XCTAssertEqual(sut.sendButton.style, .red)
    }
    
    // MARK: - phoneNumber text

    func test_phoneNumberTextChanges_shouldChange_isValidPhoneNumber() {
        
        let sut = makeSUT()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.isValidPhoneNumber, false)
        
        typeAndWait("1", sut: sut)
        
        XCTAssertEqual(sut.isValidPhoneNumber, false)
        
        typeAndWait("", sut: sut)
        
        XCTAssertEqual(sut.isValidPhoneNumber, false)
        
        typeAndWait("12345678", sut: sut)
        
        XCTAssertEqual(sut.isValidPhoneNumber, false)
        
        typeAndWait(nil, sut: sut)
        
        XCTAssertEqual(sut.isValidPhoneNumber, false)
        
        typeAndWait("7 911 111 11 11", sut: sut)
        
        XCTAssertEqual(sut.isValidPhoneNumber, true)
    }

    func test_phoneNumberTextChanges_shouldChange_isError() {
        
        let sut = makeSUT()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.isError, false)
        
        typeAndWait("1", sut: sut)
        
        XCTAssertEqual(sut.isError, true)
        
        typeAndWait("", sut: sut)
        
        XCTAssertEqual(sut.isError, true)
        
        typeAndWait("12345678", sut: sut)
        
        XCTAssertEqual(sut.isError, true)
        
        typeAndWait(nil, sut: sut)
        
        XCTAssertEqual(sut.isError, true)
        
        typeAndWait("7 911 111 11 11", sut: sut)
        
        XCTAssertEqual(sut.isError, false)
    }
    
    // MARK: - phoneNumber isActive

    func test_phoneNumberTextChanges_shouldChange_isActive() {
        
        let sut = makeSUT()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.phoneNumber.isActive, false)
        
        typeAndWait("1", sut: sut)
        
        XCTAssertEqual(sut.phoneNumber.isActive, true)
        
        typeAndWait("", sut: sut)
        
        XCTAssertEqual(sut.phoneNumber.isActive, false)
        
        typeAndWait("12345678", sut: sut)
        
        XCTAssertEqual(sut.phoneNumber.isActive, true)
        
        typeAndWait(nil, sut: sut)
        
        XCTAssertEqual(sut.phoneNumber.isActive, false)
        
        typeAndWait("7 911 111 11 11", sut: sut)
        
        XCTAssertEqual(sut.phoneNumber.isActive, true)
    }
    
    // MARK: - $isSmsCode
    
    func test_isUserInteractionEnabled_shouldFlip_onIsSmsCode() {
        
        let sut = makeSUT()
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(sut.isUserInteractionEnabled, true)
        
        setIsSmsAndWait(false, sut: sut)
        
        XCTAssertEqual(sut.isSmsCode, false)
        XCTAssertEqual(sut.isUserInteractionEnabled, true)
        
        setIsSmsAndWait(true, sut: sut)
        
        XCTAssertEqual(sut.isSmsCode, true)
        XCTAssertEqual(sut.isUserInteractionEnabled, false)
        
        setIsSmsAndWait(false, sut: sut)
        
        XCTAssertEqual(sut.isSmsCode, false)
        XCTAssertEqual(sut.isUserInteractionEnabled, true)
    }

    // MARK: - Helpers
    
    private func makeSUT(
        model: Model = .productsMock,
        file: StaticString = #file,
        line: UInt = #line
    ) -> OrderProductView.ViewModel {
        
        let sut = OrderProductView.ViewModel(.productsMock, productData: .test)

        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func typeAndWait(
        _ text: String?,
        sut: OrderProductView.ViewModel
    ) {
        sut.phoneNumber
            .setText(to: text)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
    
    private func smsAndWait(
        _ text: String,
        sut: OrderProductView.ViewModel
    ) {
        sut.smsCode.text = text
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
    
    private func setIsSmsAndWait(
        _ value: Bool,
        sut: OrderProductView.ViewModel
    ) {
        sut.isSmsCode = value
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
    
    private func stateAndWait(
        _ state: OrderProductView.ViewModel.State,
        sut: OrderProductView.ViewModel
    ) {
        sut.state = state
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
    
    private func sendAndWait(
        _ action: Action,
        sut: OrderProductView.ViewModel
    ) {
        sut.sendButton.action.send(action)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
}

private extension CatalogProductData {
    
    static let test: Self = .init(
        name: "CatalogProductData #1",
        description: ["Some Description"],
        imageEndpoint: "",
        infoURL: .test,
        orderURL: .test,
        tariff: 1,
        productType: 1
    )
}

private extension URL {
    
    static let test: Self = .init(string: "https://test.com")!
}

// MARK: - DSL

extension Model {
    
    func sendAndWait(_ action: Action) {
        
        self.action.send(action)
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
    }
}
