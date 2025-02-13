//
//  PaymentsTemplateDataTests.swift
//  VortexTests
//
//  Created by Дмитрий Савушкин on 01.06.2023.
//

import XCTest
@testable import Vortex

final class PaymentsTemplateDataTests: XCTestCase {
    
    typealias Kind = PaymentTemplateData.Kind
    typealias Me2MeData = TransferMe2MeData
    typealias GeneralData = TransferGeneralData
    typealias AnywayData = TransferAnywayData
    
    func test_paymentsTemplate_typeInside_ByPhonePhoneNumber_shouldReturnPhoneNumberNil() throws {
        
        let type = Kind.mobile
        let transferData = Me2MeData.me2MeStub()
        
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        
        XCTAssertNil(template.phoneNumber)
    }
    
    func test_paymentsTemplate_typeInside_ByPhonePhoneNumber_shouldReturnPhoneNumber() throws {
        
        let type = Kind.mobile
        let transferData = GeneralData.generalStub()
        
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        let insideByPhonePhoneNumber = template.phoneNumber
        
        XCTAssertEqual(
            insideByPhonePhoneNumber,
            "11111")
    }
    
    func test_paymentsTemplate_insideByPhoneBankId() throws {
        
        let type = Kind.mobile
        let transferData = GeneralData.generalStub()
        
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        
        XCTAssertEqual(
            template.vortexID,
            BankID.vortexID.rawValue)
    }
    
    func test_paymentsTemplate_typeInside_shouldReturnPhoneBankIdNil() throws {
        
        let type = Kind.mobile
        let transferData = Me2MeData.me2MeStub()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        
        let insideByPhoneBankId = template.vortexID
        
        XCTAssertNil(insideByPhoneBankId)
    }
    
    //MARK: Computed Property Tests
    
    func test_paymentsTemplate_shouldReturnTransferAnywayData() throws {
        
        let transferData = AnywayData.anywayStub()
        let template = PaymentTemplateData.templateStub(
            type: .betweenTheir,
            parameterList: transferData
        )
        
        let anywayData = try XCTUnwrap(template.transferAnywayData)
        
        XCTAssertNotNil(anywayData)
        XCTAssertEqual(anywayData.amount, 100)
        XCTAssertEqual(anywayData.additional, [
            .init(
                fieldid: 1,
                fieldname: "trnPickupPoint",
                fieldvalue: "AM"
            ),
            .init(
                fieldid: 1,
                fieldname: "RecipientID",
                fieldvalue: "123123"
            )
        ])
    }
    
    func test_paymentsTemplate_shouldReturnTransferAnywayDataNil() throws {
        
        let transferData = Me2MeData.me2MeStub()
        let template = PaymentTemplateData.templateStub(
            type: .betweenTheir,
            parameterList: transferData
        )
        
        XCTAssertNil(template.transferAnywayData)
    }
    
    func test_paymentsTemplate_shouldReturnPayerProductIdNilOnNilPayer() throws {
        
        let transferData = Me2MeData.me2MeStub(accountId: nil)
        let template = PaymentTemplateData.templateStub(
            type: .betweenTheir,
            parameterList: transferData
        )
        
        XCTAssertNil(template.payerProductId)
    }
    
    func test_paymentsTemplate_shouldReturnPayerProductOnAccountID() throws {
        
        let transferData = Me2MeData.me2MeStub(accountId: 123)
        let template = PaymentTemplateData.templateStub(
            type: .betweenTheir,
            parameterList: transferData
        )
        
        XCTAssertEqual(template.payerProductId, 123)
    }
    
    func test_paymentsTemplate_shouldReturnPayerProductOnCardID() throws {
        
        let transferData = Me2MeData.me2MeStub(cardId: 456)
        let template = PaymentTemplateData.templateStub(
            type: .betweenTheir,
            parameterList: transferData
        )
        
        XCTAssertEqual(template.payerProductId, 456)
    }
    
    func test_paymentsTemplate_shouldReturnPayerProductId() throws {
        
        let transferData = GeneralData.generalStub(amount: 100, cardId: 10000184511)
        let template = PaymentTemplateData.templateStub(
            type: .betweenTheir,
            parameterList: transferData
        )
        
        let payerProductId = try XCTUnwrap(template.payerProductId)
        
        XCTAssertNotNil(payerProductId)
        XCTAssertEqual(template.amount, 100)
        XCTAssertEqual(template.payerProductId, 1)
    }
    
    //MARK: PaymentTemplateData.Kind Tests
    
    func test_paymentsTemplateKind_description_shouldReturnBetweenTheir() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .betweenTheir
        )
        
        XCTAssertEqual(template.description, "Между своими счетами")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnInsideBank() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .insideBank
        )
        
        XCTAssertEqual(template.description, "Внутри банка")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnOtherBank() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .otherBank
        )
        
        XCTAssertEqual(template.description, "В другой банк")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnByPhone() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .byPhone
        )
        
        XCTAssertEqual(template.description, "По номеру телефона")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnSfp() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .sfp
        )
        
        XCTAssertEqual(template.description, "Перевод СБП")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnExternalEntity() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .externalEntity
        )
        
        XCTAssertEqual(template.description, "По реквизитам: компания")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnExternalIndividual() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .externalIndividual
        )
        
        XCTAssertEqual(template.description, "По реквизитам: частный")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnContactAdressless() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .contactAdressless
        )
        
        XCTAssertEqual(template.description, "Перевод Контакт")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnDirect() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: "DIRECT"
        )
        
        XCTAssertEqual(template.description, "Перевод МИГ")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnHousingAndCommunalService() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .housingAndCommunalService
        )
        
        XCTAssertEqual(template.description, "Услуги ЖКХ")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnMobile() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .mobile
        )
        
        XCTAssertEqual(template.description, "Мобильная связь")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnInternet() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .internet
        )
        
        XCTAssertEqual(template.description, "Интернет, ТВ")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnTransport() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .transport
        )
        
        XCTAssertEqual(template.description, "Транспорт")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnTaxAndStateService() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: "TAX_AND_STATE_SERVICE"
        )
        
        XCTAssertEqual(template.description, "Налоги и госуслуги")
    }
    
    func test_paymentsTemplateKind_description_shouldReturnInterestDeposit() throws {
        
        let template = PaymentTemplateData.templateStub(
            type: .interestDeposit
        )
        
        XCTAssertEqual(template.description, "Проценты по депозитам")
    }
}
