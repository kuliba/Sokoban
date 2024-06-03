//
//  OperationDetailDataTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 07.06.2023.
//

import XCTest
@testable import ForaBank

final class OperationDetailDataTests: XCTestCase {

    typealias Detail = OperationDetailData
    
    let payeeFullName = "name"

    // MARK: Template name computed property tests
    
    func test_templateName_transport_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .transport,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_transport_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .transport
        )
        
        XCTAssertEqual(detail.templateName, "Транспорт")
    }
    
    func test_templateName_taxAndStateService_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .taxAndStateService,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_taxAndStateService_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .taxAndStateService
        )
        
        XCTAssertEqual(detail.templateName, "Налоги и госуслуги")
    }
    
    func test_templateName_accountToAccount_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .accountToAccount,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_accountToAccount_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .accountToAccount
        )
        
        XCTAssertEqual(detail.templateName, "Перевод между своими")
    }
    
    func test_templateName_accountToCard_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .accountToCard,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_accountToCard_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .accountToCard
        )
        
        XCTAssertEqual(detail.templateName, "Между своими")
    }
    
    func test_templateName_accountToPhone_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .accountToPhone,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_accountToPhone_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .accountToPhone
        )
        
        XCTAssertEqual(detail.templateName, "Перевод внутри банка")
    }
    
    func test_templateName_contactAddressingCash_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .contactAddressingCash,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_contactAddressingCash_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .contactAddressingCash
        )
        
        XCTAssertEqual(detail.templateName, "Перевод Contact")
    }
    
    func test_templateName_direct_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .direct,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_direct_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .direct
        )
        
        XCTAssertEqual(detail.templateName, "Перевод МИГ")
    }
    
    func test_templateName_elecsnet_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .elecsnet
        )
        
        XCTAssertEqual(detail.templateName, "В другой банк")
    }
    
    func test_templateName_external_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .external,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_external_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .external
        )
        
        XCTAssertEqual(detail.templateName, "Перевод по реквизитам")
    }
    
    func test_templateName_housingAndCommunalService_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .housingAndCommunalService,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_housingAndCommunalService_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .housingAndCommunalService
        )
        
        XCTAssertEqual(detail.templateName, "ЖКХ")
    }
    
    func test_templateName_internet_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .internet,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_internet_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .internet
        )
        
        XCTAssertEqual(detail.templateName, "Интернет и ТВ")
    }
    
    func test_templateName_mobile_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .mobile,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_mobile_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .mobile
        )
        
        XCTAssertEqual(detail.templateName, "Мобильная связь")
    }
    
    func test_templateName_sfp_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .sfp,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_sfp_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .sfp
        )
        
        XCTAssertEqual(detail.templateName, "Исходящие СБП")
    }
    
    func test_templateName_conversionAccountToAccount_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .conversionAccountToAccount,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_conversionAccountToAccount_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .conversionAccountToAccount
        )
        
        XCTAssertEqual(detail.templateName, "Перевод между счетами")
    }
    
    func test_templateName_conversionAccountToCard_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .conversionAccountToCard,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_conversionAccountToCard_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .conversionAccountToCard
        )
        
        XCTAssertEqual(detail.templateName, "Перевод со счета на карту")
    }
    
    func test_templateName_conversionCardToAccount_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .conversionCardToAccount,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_conversionCardToAccount_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .conversionCardToAccount
        )
        
        XCTAssertEqual(detail.templateName, "Перевод с карты на счет")
    }
    
    func test_templateName_conversionCardToCard_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .conversionCardToCard,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_conversionCardToCard_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .conversionCardToCard
        )
        
        XCTAssertEqual(detail.templateName, "Перевод с карты на карту")
    }
    
    func test_templateName_conversionAccountToPhone_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .conversionAccountToPhone,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_conversionAccountToPhone_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .conversionAccountToPhone
        )
        
        XCTAssertEqual(detail.templateName, "Перевод между счетами")
    }
    
    func test_templateName_conversionAccountToPhone_payeePhone_shouldReturnDefaultValue() throws {

        let phone = "phone"
        let detail = Detail.stub(
            transferEnum: .conversionAccountToPhone,
            payeePhone: phone
        )
        
        XCTAssertEqual(detail.templateName, phone)
    }
    
    func test_templateName_other_shouldReturnPayeeFullName() throws {

        let detail = Detail.stub(
            transferEnum: .other,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_default_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .other
        )
        
        XCTAssertEqual(detail.templateName, "Шаблон по операции")
    }
    
    //MARK: PayerTransferData
    
    func test_payerTransferData_withOperationDetailStub_shouldReturnPayerTransferData() {
        
        let sut = Detail.stub()
        
        XCTAssertNoDiff(sut.payerTransferData, .init(
            inn: nil,
            accountId: nil,
            accountNumber: "payerAccountNumber",
            cardId: 1,
            cardNumber: "payerCardNumber",
            phoneNumber: nil)
        )
    }
    
    //MARK: PayeeExternal

    func test_payeeExternal_withOperationDetailStub_accountNumberNil_shouldReturnNil() {
        
        let sut = Detail.stub()
        
        XCTAssertNil(sut.payeeExternal)
    }
    
    func test_payeeExternal_withOperationDetailStub_shouldReturnPayerExternal() {
        
        let sut = Detail.stub(payeeFullName: "payeeFullName")
        
        XCTAssertNoDiff(sut.payeeExternal, .init(
            inn: nil,
            kpp: nil,
            accountId: nil,
            accountNumber: "payeeAccountNumber",
            bankBIC: nil,
            cardId: nil,
            cardNumber: nil,
            compilerStatus: nil,
            date: nil,
            name: "payeeFullName",
            tax: nil
        ))
    }
    
    //MARK: PayeeInternal

    func test_payeeInternal_withOperationDetailStub_shouldReturnPayeeInternal() {
        
        let sut = Detail.stub(payeePhone: "payeePhone")
        
        XCTAssertNoDiff(sut.payeeInternal, .init(
            accountId: nil,
            accountNumber: "payeeAccountNumber",
            cardId: nil,
            cardNumber: nil,
            phoneNumber: "payeePhone",
            productCustomName: nil
        ))
    }
    
    //MARK: RestrictedTemplateButton
    
    func test_shouldHaveTemplateButton_withOperationDetailStub_forAccountClose_shouldReturnFalse() {
        
        let sut = Detail.stub(transferEnum: .accountClose)
        
        XCTAssertFalse(sut.shouldHaveTemplateButton)
    }
    
    func test_shouldHaveTemplateButton_withOperationDetailStub_forCardToCard_shouldReturnTrue() {
        
        let sut = Detail.stub(transferEnum: .cardToCard)
        
        XCTAssertTrue(sut.shouldHaveTemplateButton)
    }
    
    //MARK: Computed Property
    
    func test_payerGeneralTransferData_shouldReturnCardId() {
        
        let sut = Detail.stub()
        
        XCTAssertEqual(
            sut.payerGeneralTransferData,
            .init(
                inn: nil,
                accountId: nil,
                accountNumber: nil,
                cardId: 1,
                cardNumber: nil,
                phoneNumber: nil
            )
        )
    }
    
    func test_payerGeneralTransferData_shouldReturnAccountId() {
        
        let sut = Detail.stub(cardId: nil, payerAccountId: 1)
        
        XCTAssertEqual(
            sut.payerGeneralTransferData,
            .init(
                inn: nil,
                accountId: 1,
                accountNumber: nil,
                cardId: nil,
                cardNumber: nil,
                phoneNumber: nil
            )
        )
    }
    
    func test_payerGeneralTransferData_shouldReturnCardIdWithAccountId() {
        
        let sut = Detail.stub(cardId: 1, payerAccountId: 1)
        
        XCTAssertEqual(
            sut.payerGeneralTransferData,
            .init(
                inn: nil,
                accountId: nil,
                accountNumber: nil,
                cardId: 1,
                cardNumber: nil,
                phoneNumber: nil
            )
        )
    }
}
