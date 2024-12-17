//
//  PaymentsSourceReducerTemplateTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 30.05.2023.
//

import XCTest
@testable import ForaBank

final class PaymentsSourceReducerTemplateTests: XCTestCase {
    
    private let templateId = 2513
    private let fakeParameterId = "1"
    
    func test_updateParameter_mobileService_withFakeParameterId_shouldReturnNil() throws {
        
        // given
        let (service, source, _, parameterId) = makeOperationDummy(
            .abroad,
            .template(templateId),
            .mobile,
            fakeParameterId
        )
        let sut = makeSUT()
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_changeService_withFakeParameterId_shouldReturnNil() throws {
        
        // given
        let (service, source, _, parameterId) = makeOperationDummy(
            .change,
            .qr,
            .betweenTheir,
            fakeParameterId
        )
        let sut = makeSUT()
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_withMe2Me_shouldReturnNil() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .change,
            .qr,
            .direct,
            fakeParameterId
        )
        
        let parameterList = TransferMe2MeData.me2MeStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: parameterList
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_fakeParameterId_changeService_shouldReturnNil() throws {
        
        // given
        let (service, source, _, parameterId) = makeOperationDummy(
            .change,
            .template(templateId),
            .contactAddressing,
            fakeParameterId
        )
        let sut = makeSUT()
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_withAnyway_countryIdParameter_shouldReturnCountryCode() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .abroad,
            .template(templateId),
            .direct,
            Identifier.countrySelect.rawValue
        )
        
        let parameterList = TransferAnywayData.anywayStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: parameterList)
        
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, "AM")
    }
    
    func test_updateParameter_withAnyway_sfpPhoneParameter_shouldReturnNumber() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .sfp,
            .template(templateId),
            .sfp,
            Identifier.sfpPhone.rawValue
        )
        
        let transferData = TransferAnywayData.anywayStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, "+1 231-23")
    }
    
    func test_updateParameter_withGeneral_sfpPhoneParameter_shouldReturnNumber() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .sfp,
            .template(templateId),
            .sfp,
            Identifier.sfpPhone.rawValue
        )
        let sut = makeSUT()
        sut.stubPaymentTemplates(for: type)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, "11111")
    }
    
    func test_updateParameter_withGeneral_sfpBankParameter_shouldReturnId() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .sfp,
            .template(templateId),
            .sfp,
            Identifier.sfpBank.rawValue
        )
        
        let sut = makeSUT()
        sut.stubPaymentTemplates(for: type)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, BankID.foraBankID.rawValue)
    }
    
    func test_updateParameter_withGeneral_sfpMessageParameter_shouldReturnComment() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .sfp,
            .template(templateId),
            .sfp,
            Identifier.sfpMessage.rawValue
        )
        
        let transferData = TransferGeneralData.generalStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, "comment")
    }
    
    func test_updateParameter_withGeneral_countryIdParameter_shouldReturnNil() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .sfp,
            .template(templateId),
            .sfp,
            Identifier.countryId.rawValue
        )
        
        let sut = makeSUT()
        sut.stubPaymentTemplates(for: type)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_withGeneral_amountParameter_shouldReturn_0() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .sfp,
            .template(templateId),
            .sfp,
            Identifier.amount.rawValue
        )
        
        let transferData = TransferGeneralData.generalStub(amount: nil)
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_withGeneral_amountParameter_shouldReturn_100() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .sfp,
            .template(templateId),
            .sfp,
            Identifier.amount.rawValue
        )
        
        let transferData = TransferGeneralData.generalStub(amount: 100)
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, "100.0")
    }
    
    func test_updateParameter_withAnyway_mobileParameter_shouldReturnNil() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .mobileConnection,
            .template(templateId),
            .mobile,
            Identifier.mobileConnectionPhone.rawValue
        )
        
        let transferData = TransferAnywayData.anywayStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_withMe2MeStub_mobilePhoneParameter_shouldReturnNil() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .mobileConnection,
            .template(templateId),
            .mobile,
            Identifier.mobileConnectionPhone.rawValue
        )
        
        let transferData = TransferMe2MeData.me2MeStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_mobilePhoneParameter_contactAdressing_shouldReturnNil() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .abroad,
            .template(templateId),
            .contactAddressing,
            Identifier.mobileConnectionPhone.rawValue
        )
        
        let transferData = TransferMe2MeData.me2MeStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_mobilePhoneParameter_fakeParameterId_shouldReturnNil() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .mobileConnection,
            .template(templateId),
            .mobile,
            fakeParameterId
        )
        
        let transferData = TransferAnywayData.anywayStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_sfpPhoneParameter_unknownTransferType_shouldReturnNil() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .return,
            .template(templateId),
            .unknown,
            Identifier.sfpPhone.rawValue
        )
        
        let transferData = TransferAnywayData.anywayStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
}

//MARK: Requisites paymentsProcessSourceTemplateReducerRequisites tests

extension PaymentsSourceReducerTemplateTests {
    
    func test_updateParameter_requisitsName_shouldReturnName() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            Identifier.requisitsName.rawValue
        )
        
        let transferData = TransferGeneralData.generalStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        let name = try XCTUnwrap(transferData.last?.payeeExternal?.name)
        XCTAssertEqual(value, name)
    }
    
    func test_updateParameter_requisitsInn_shouldReturnInn() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            Identifier.requisitsInn.rawValue
        )
        
        let transferData = TransferGeneralData.generalStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        let inn = try XCTUnwrap(transferData.last?.payeeExternal?.inn)
        XCTAssertEqual(value, inn)
    }
    
    func test_updateParameter_requisitsAccountNumber_shouldReturnNumber() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            Identifier.requisitsAccountNumber.rawValue
        )
        
        let transferData = TransferGeneralData.generalStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        let accountNumber = try XCTUnwrap(transferData.last?.payeeExternal?.accountNumber)
        XCTAssertEqual(value, accountNumber)
    }
    
    func test_updateParameter_requisitsBankBic_shouldReturnBic() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            Identifier.requisitsBankBic.rawValue
        )
        
        let transferData = TransferGeneralData.generalStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData
        )
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        let bic = try XCTUnwrap(transferData.last?.payeeExternal?.bankBIC)
        XCTAssertEqual(value, bic)
    }
    
    func test_updateParameter_requisitsKpp_shouldReturnKpp() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            Identifier.requisitsKpp.rawValue
        )
        
        let transferData = TransferGeneralData.generalStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        let kpp = try XCTUnwrap(transferData.last?.payeeExternal?.kpp)
        XCTAssertEqual(value, kpp)
    }
    
    func test_updateParameter_requisitsCompanyName_shouldReturnName() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            Identifier.requisitsCompanyName.rawValue
        )
        
        let transferData = TransferGeneralData.generalStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        let name = try XCTUnwrap(transferData.last?.payeeExternal?.name)
        XCTAssertEqual(value, name)
    }
    
    func test_updateParameter_requisitsMessage_shouldReturnMessage() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            Identifier.requisitsMessage.rawValue
        )
        
        let transferData = TransferGeneralData.generalStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        let comment = try XCTUnwrap(transferData.last?.comment)
        XCTAssertEqual(value, comment)
    }
    
    func test_updateParameter_requisitesService_fakeParameterId_shouldReturnNil() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            fakeParameterId
        )
        
        let sut = makeSUT()
        sut.stubPaymentTemplates(for: type)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_requisitesService_withMe2Me_shouldReturnNil() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            fakeParameterId
        )
        
        let transferData = TransferMe2MeData.me2MeStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        sut.paymentTemplates.value.append(template)
        
        // when
        let value = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(value, nil)
    }
    
    func test_updateParameter_payerProductId_productParameter_shouldReturnId() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            Identifier.product.rawValue
        )
        
        let transferData = TransferMe2MeData.me2MeStub(
            accountId: 123
        )
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        sut.paymentTemplates.value.append(template)
        
        // when
        let result = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(result, "123")
    }
    
    func test_updateParameter_parameterAmount_shouldReturnValue() throws {
        
        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .requisites,
            .template(templateId),
            .externalIndividual,
            Identifier.amount.rawValue
        )
        
        let transferData = TransferAnywayData.anywayStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        sut.paymentTemplates.value.append(template)
        
        // when
        let result = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)
        
        // then
        XCTAssertEqual(result, "100.0")
    }
    
    func test_updateParameter_toAnotherCard_parameterMobilePhone_shouldReturnNil() throws {

        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .toAnotherCard,
            .template(templateId),
            .externalIndividual,
            Identifier.mobileConnectionPhone.rawValue
        )

        let transferData = TransferAnywayData.anywayStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        sut.paymentTemplates.value.append(template)

        // when
        let result = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)

        // then
        XCTAssertEqual(result, nil)
    }
    
    func test_updateParameter_toAnotherCard_productTemplate_shouldReturnProductId() throws {

        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .toAnotherCard,
            .template(templateId),
            .externalIndividual,
            Identifier.productTemplate.rawValue
        )

        let transferData = TransferGeneralData.generalStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        sut.paymentTemplates.value.append(template)
        sut.productTemplates.value.append(ProductTemplateData.productTemplateStub())

        // when
        let result = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)

        // then
        XCTAssertEqual(result, "T:1")
    }
    
    func test_updateParameter_toAnotherCard_withMe2MeData_shouldReturnNil() throws {

        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .toAnotherCard,
            .template(templateId),
            .externalIndividual,
            Identifier.productTemplate.rawValue
        )

        let transferData = TransferMe2MeData.me2MeStub()
        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: transferData)
        sut.paymentTemplates.value.append(template)

        // when
        let result = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)

        // then
        XCTAssertEqual(result, nil)
    }
    
    func test_updateParameter_toAnotherCard_mobilePhoneParameter_shouldReturnNil() throws {

        // given
        let (service, source, type, parameterId) = makeOperationDummy(
            .toAnotherCard,
            .template(templateId),
            .externalIndividual,
            Identifier.mobileConnectionPhone.rawValue
        )

        let sut = makeSUT()
        let template = PaymentTemplateData.templateStub(
            type: type,
            parameterList: [])
        sut.paymentTemplates.value.append(template)

        // when
        let result = updateParameterValue(
            model: sut,
            service: service,
            source: source,
            parameterId: parameterId)

        // then
        XCTAssertEqual(result, nil)
    }
}

// MARK: - Helpers DSL

extension PaymentsSourceReducerTemplateTests {
    
    func makeSUT() -> Model {
        
        .mockWithEmptyExcept()
    }
    
    typealias Service = Payments.Service
    typealias Source = Payments.Operation.Source
    typealias Identifier = Payments.Operation.Parameter.Identifier
    typealias Kind = PaymentTemplateData.Kind
    
    func updateParameterValue(
        model: Model,
        service: Service,
        source: Source,
        parameterId: Payments.Parameter.ID
    ) -> Payments.Parameter.Value? {
        
        model.paymentsProcessSourceReducer(
            service: service,
            source: source,
            parameterId: parameterId)
    }
    
    func makeOperationDummy(
        _ service: Service,
        _ source: Source,
        _ type: Kind,
        _ parameterId: Payments.Parameter.ID
    ) -> (Service, Source, Kind, Payments.Parameter.ID) {
        
        (service, source, type, parameterId)
    }
}

extension Model {
    
    func stubPaymentTemplates(
        paymentTemplateId: Int = 2513,
        for type: PaymentsSourceReducerTemplateTests.Kind
    ) {
        
        let transferData = TransferGeneralData.generalStub()
        let template = PaymentTemplateData.templateStub(
            paymentTemplateId: paymentTemplateId,
            type: type,
            parameterList: transferData
        )
        
        paymentTemplates.value.append(template)
    }
}
