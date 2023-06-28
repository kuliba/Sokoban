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
            transferEnum: .oth,
            payeeFullName: payeeFullName
        )
        
        XCTAssertEqual(detail.templateName, payeeFullName)
    }
    
    func test_templateName_default_payeeFullNameNil_shouldReturnDefaultValue() throws {

        let detail = Detail.stub(
            transferEnum: .oth
        )
        
        XCTAssertEqual(detail.templateName, "Шаблон по операции")
    }
}

extension OperationDetailData {
    
    static func stub(
        paymentTemplateId: Int? = 1,
        transferEnum: OperationDetailData.TransferEnum? = .accountClose,
        payeeFullName: String? = nil,
        payeePhone: String? = nil) -> OperationDetailData {
        
        return .init(
            oktmo: nil,
            account: nil,
            accountTitle: nil,
            amount: 100,
            billDate: nil,
            billNumber: nil,
            claimId: "",
            comment: nil,
            countryName: nil,
            currencyAmount: "",
            dateForDetail: "",
            division: nil,
            driverLicense: nil,
            externalTransferType: .individual,
            isForaBank: false,
            isTrafficPoliceService: false,
            memberId: nil,
            operation: nil,
            payeeAccountId: nil,
            payeeAccountNumber: nil,
            payeeAmount: nil,
            payeeBankBIC: nil,
            payeeBankCorrAccount: nil,
            payeeBankName: nil,
            payeeCardId: nil,
            payeeCardNumber: nil,
            payeeCurrency: nil,
            payeeFirstName: nil,
            payeeFullName: payeeFullName,
            payeeINN: nil,
            payeeKPP: nil,
            payeeMiddleName: nil,
            payeePhone: payeePhone,
            payeeSurName: nil,
            payerAccountId: 10,
            payerAccountNumber: ":",
            payerAddress: "",
            payerAmount: 11,
            payerCardId: nil,
            payerCardNumber: nil,
            payerCurrency: "",
            payerDocument: nil,
            payerFee: 10,
            payerFirstName: "",
            payerFullName: "",
            payerINN: nil,
            payerMiddleName: nil,
            payerPhone: nil,
            payerSurName: nil,
            paymentOperationDetailId: 1,
            paymentTemplateId: paymentTemplateId,
            period: nil,
            printFormType: .addressing_cash,
            provider: nil,
            puref: nil,
            regCert: nil,
            requestDate: "",
            responseDate: "",
            returned: nil,
            transferDate: "",
            transferEnum: transferEnum,
            transferNumber: nil,
            transferReference: nil,
            cursivePayerAmount: nil,
            cursivePayeeAmount: nil,
            cursiveAmount: nil,
            serviceSelect: nil,
            serviceName: nil,
            merchantSubName: nil,
            merchantIcon: nil,
            operationStatus: nil,
            shopLink: nil,
            payeeCheckAccount: nil,
            depositNumber: nil,
            depositDateOpen: nil,
            currencyRate: nil,
            mcc: nil,
            printData: nil,
            paymentMethod: nil)
    }
}
