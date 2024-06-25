//
//  ProductStatementDataTests.swift
//  ForaBankTests
//
//  Created by Дмитрий on 20.01.2022.
//

import XCTest
@testable import ForaBank

class ProductStatementDataTests: XCTestCase {
    
    let bundle = Bundle(for: ProductStatementDataTests.self)
    let decoder = JSONDecoder.serverDate
    let encoder = JSONEncoder.serverDate
    let calendar = Calendar.current
    
    func testDecoding_Generic() throws {
        
        // given
        let url = bundle.url(forResource: "ProductStatementDataDecodingGeneric", withExtension: "json")!
        let json = try Data(contentsOf: url)
        let fastPayment = ProductStatementData.FastPayment(documentComment: "string", foreignBankBIC: "044525491", foreignBankID: "10000001153", foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"", foreignName: "Петров Петр Петрович", foreignPhoneNumber: "70115110217", opkcid: "A1355084612564010000057CAFC75755",operTypeFP: "string", tradeName: "string", guid: "string")
        
        // when
        let result = try decoder.decode(ProductStatementData.self, from: json)
        
        // then
        XCTAssertEqual(result.mcc, 3245)
        XCTAssertEqual(result.accountId, 10004111477)
        XCTAssertEqual(result.accountNumber, "70601810711002740401")
        XCTAssertEqual(result.amount, 144.21)
        XCTAssertEqual(result.cardTranNumber, "4256901080508437")
        XCTAssertEqual(result.city, "string")
        XCTAssertEqual(result.comment, "Перевод денежных средств. НДС не облагается.")
        XCTAssertEqual(result.country, "string")
        XCTAssertEqual(result.currencyCodeNumeric, 810)
        
        //"2022-01-20T13:44:17.810Z"
        let date = try Date.date(from: "2022-03-28T21:00:00.000Z", formatter: .iso8601)
        XCTAssertEqual(result.date, date)
        
        XCTAssertEqual(result.deviceCode, "string")
        XCTAssertEqual(result.documentAmount, 144.21)
        XCTAssertEqual(result.documentId, 10230444722)
        XCTAssertEqual(result.fastPayment, fastPayment)
        XCTAssertEqual(result.groupName, "Прочие операции")
        XCTAssertEqual(result.isCancellation, false)
        XCTAssertEqual(result.md5hash, "75f3ee3b2d44e5808f41777c613f23c9")
        XCTAssertEqual(result.merchantName, "DBO MERCHANT FORA, Zubovskiy 2")
        XCTAssertEqual(result.merchantNameRus, "DBO MERCHANT FORA, Zubovskiy 2")
        XCTAssertEqual(result.opCode, 1)
        XCTAssertEqual(result.operationId, "909743")
        XCTAssertEqual(result.operationType, OperationType.debit)
        XCTAssertEqual(result.paymentDetailType, ProductStatementData.Kind.betweenTheir)
        XCTAssertEqual(result.svgImage, SVGImageData.init(description: "string"))
        XCTAssertEqual(result.terminalCode, "41010601")
        
        let tranDate = try Date.date(from: "2022-03-28T21:00:00.000Z", formatter: .iso8601)
        XCTAssertEqual(result.tranDate, tranDate)
        
        XCTAssertEqual(result.type, OperationEnvironment.inside)
    }
    
    func test_merchant_whenMerchantNameRusIsNotNil_shouldReturnMerchantNameRus() {
        
        let data = makeProductStatementData(merchantName: nil, merchantNameRus: "Test Merchant")
        XCTAssertEqual(data.merchant, "Test Merchant")
    }
    
    func test_merchant_whenMerchantNameRusIsNilAndMerchantNameIsNotNil_shouldReturnMerchantName() {
        
        let data = makeProductStatementData(merchantName: "Test Merchant", merchantNameRus: nil)
        XCTAssertEqual(data.merchant, "Test Merchant")
    }
    
    func test_merchant_whenMerchantNameRusAndMerchantNameAreNil_shouldReturnPlaceholder() {
        
        let data = makeProductStatementData(merchantName: nil, merchantNameRus: nil)
        XCTAssertEqual(data.merchant, ProductStatementData.merchantNamePlaceholder)
    }
    
    func test_isMinusSign_whenOperationTypeIsDebit_shouldReturnTrue() {
        
        let data = makeProductStatementData(operationType: .debit)
        XCTAssertTrue(data.isMinusSign)
    }
    
    func test_isMinusSign_whenOperationTypeIsDebitFict_shouldReturnTrue() {
        
        let data = makeProductStatementData(operationType: .debitFict)
        XCTAssertTrue(data.isMinusSign)
    }
    
    func test_isMinusSign_whenOperationTypeIsDebitPlan_shouldReturnTrue() {
        
        let data = makeProductStatementData(operationType: .debitPlan)
        XCTAssertTrue(data.isMinusSign)
    }
    
    func test_isMinusSign_whenOperationTypeIsNotDebit_shouldReturnFalse() {
        
        let data = makeProductStatementData(operationType: .credit)
        XCTAssertFalse(data.isMinusSign)
    }
    
    func test_operationSymbolsAndAmount_whenOperationTypeIsDebit_shouldReturnMinusSign() {
        
        let data = makeProductStatementData(operationType: .debit)
        let amountFormatted = "100.00"
        XCTAssertEqual(data.operationSymbolsAndAmount(amountFormatted), "- \(amountFormatted)")
    }
    
    func test_operationSymbolsAndAmount_whenOperationTypeIsNotDebit_shouldReturnPlusSign() {
        
        let data = makeProductStatementData(operationType: .credit)
        let amountFormatted = "100.00"
        XCTAssertEqual(data.operationSymbolsAndAmount(amountFormatted), "+ \(amountFormatted)")
    }
    
    func test_isReturn_whenGroupNameContainsVozvrat_shouldReturnTrue() {
        
        let data = makeProductStatementData(groupName: "Возврат платежа")
        XCTAssertTrue(data.isReturn)
    }
    
    func test_isReturn_whenGroupNameDoesNotContainVozvrat_shouldReturnFalse() {
        
        let data = makeProductStatementData(groupName: "Оплата услуг")
        XCTAssertFalse(data.isReturn)
    }
    
    func test_fastPaymentComment_whenIsReturnIsTrue_shouldReturnVozvrat() {
        
        let data = makeProductStatementData(fastPayment: nil, groupName: "Возврат платежа")
        XCTAssertEqual(data.fastPaymentComment, "Возврат по операции")
    }
    
    func test_dateValue_whenTranDateIsNotNil_shouldReturnTranDate() {
        
        let tranDate = Date()
        let data = makeProductStatementData(tranDate: tranDate)//, date: nil)
        XCTAssertEqual(data.dateValue, tranDate)
    }
    func test_fastPaymentComment_whenFastPaymentDocumentCommentIsNotNil_shouldReturnFastPaymentDocumentComment() {
        
        let fastPayment = makeFastPayment(documentComment: "Test Comment")
        let data = makeProductStatementData(fastPayment: fastPayment, groupName: "Оплата услуг")
        XCTAssertEqual(data.fastPaymentComment, "Test Comment")
    }
    
    func test_fastPaymentComment_whenIsReturnIsTrue_shouldReturnRefund() {
        
        let fastPayment = makeFastPayment(documentComment: nil)
        let data = makeProductStatementData(fastPayment: fastPayment, groupName: "Возврат платежа")
        XCTAssertEqual(data.fastPaymentComment, "Возврат по операции")
    }
    
    func test_dateValue_whenTranDateIsNilAndDateIsNotNil_shouldReturnDate() {
        
        let date = Date()
        let data = makeProductStatementData(date: date, tranDate: nil)
        XCTAssertEqual(data.dateValue, date)
    }
    
    func test_isCreditType_whenOperationTypeIsCredit_shouldReturnTrue() {
        
        let data = makeProductStatementData(operationType: .credit)
        XCTAssertTrue(data.isCreditType)
    }
    
    func test_isCreditType_whenOperationTypeIsNotCredit_shouldReturnFalse() {
        
        let data = makeProductStatementData(operationType: .debit)
        XCTAssertFalse(data.isCreditType)
    }
    
    func test_isDebitType_whenOperationTypeIsDebit_shouldReturnTrue() {
        
        let data = makeProductStatementData(operationType: .debit)
        XCTAssertTrue(data.isDebitType)
    }
    
    func test_isDebitType_whenOperationTypeIsNotDebit_shouldReturnFalse() {
        
        let data = makeProductStatementData(operationType: .credit)
        XCTAssertFalse(data.isDebitType)
    }
    
    func test_formattedAmountWithSign_whenIsCreditTypeIsTrue_shouldReturnAmountWithPlusSign() {
        
        let data = makeProductStatementData(operationType: .credit)
        let formatAmount = "100.00"
        XCTAssertEqual(data.formattedAmountWithSign(formatAmount), "+ \(formatAmount)")
    }
    
    func test_formattedAmountWithSign_whenIsCreditTypeIsFalse_shouldReturnAmountWithoutSign() {
        
        let data = makeProductStatementData(operationType: .debit)
        let formatAmount = "100.00"
        XCTAssertEqual(data.formattedAmountWithSign(formatAmount), formatAmount)
    }
    
    func test_payeerTitle_whenIsDebitTypeIsTrue_shouldReturnPoluchatel() {
        
        let data = makeProductStatementData(operationType: .debit)
        XCTAssertEqual(data.payeerTitle(), "Получатель")
    }
    
    func test_payeerTitle_whenIsDebitTypeIsFalse_shouldReturnOtpravitel() {
        
        let data = makeProductStatementData(operationType: .credit)
        XCTAssertEqual(data.payeerTitle(), "Отправитель")
    }
    
    // MARK: - Should Show Template/Document Buttons
    
    func test_shouldShowTemplateButton_whenOperationTypeIsCreditPlan_shouldReturnFalse() {
        
        let data = makeProductStatementData(operationType: .creditPlan)
        XCTAssertFalse(data.shouldShowTemplateButton)
    }
    
    func test_shouldShowTemplateButton_whenOperationTypeIsDebitFict_shouldReturnFalse() {
        
        let data = makeProductStatementData(operationType: .debitFict)
        XCTAssertFalse(data.shouldShowTemplateButton)
    }
    
    func test_shouldShowTemplateButton_whenOperationTypeIsCreditFict_shouldReturnFalse() {
        
        let data = makeProductStatementData(operationType: .creditFict)
        XCTAssertFalse(data.shouldShowTemplateButton)
    }
    
    func test_shouldShowTemplateButton_whenOperationTypeIsNotCreditPlanDebitFictOrCreditFict_shouldReturnTrue() {
        
        let data = makeProductStatementData(operationType: .debit)
        XCTAssertTrue(data.shouldShowTemplateButton)
    }
    
    func test_shouldShowDocumentButton_whenOperationTypeIsDebitPlan_shouldReturnFalse() {
        
        let data = makeProductStatementData(operationType: .debitPlan)
        XCTAssertFalse(data.shouldShowDocumentButton)
    }
    
    func test_shouldShowDocumentButton_whenOperationTypeIsCreditPlan_shouldReturnFalse() {
        
        let data = makeProductStatementData(operationType: .creditPlan)
        XCTAssertFalse(data.shouldShowDocumentButton)
    }
    
    func test_shouldShowDocumentButton_whenOperationTypeIsDebitFict_shouldReturnFalse() {
        
        let data = makeProductStatementData(operationType: .debitFict)
        XCTAssertFalse(data.shouldShowDocumentButton)
    }
    
    func test_shouldShowDocumentButton_whenOperationTypeIsCreditFict_shouldReturnFalse() {
        
        let data = makeProductStatementData(operationType: .creditFict)
        XCTAssertFalse(data.shouldShowDocumentButton)
    }
    
    func test_shouldShowDocumentButton_whenOperationTypeIsNotDebitPlanCreditPlanDebitFictOrCreditFict_shouldReturnTrue() {
        
        let data = makeProductStatementData(operationType: .debit)
        XCTAssertTrue(data.shouldShowDocumentButton)
    }
    
    // MARK: - HELPERS
    
    private func makeProductStatementData( //
        mcc: Int? = 1234,
        accountId: Int? = 12345,
        accountNumber: String = "1234567890",
        amount: Double = 100.0,
        cardTranNumber: String? = "1234567890123456",
        city: String? = "Test City",
        comment: String = "Test Comment",
        country: String? = "Test Country",
        currencyCodeNumeric: Int = 840,
        date: Date = Date(),
        deviceCode: String? = "TestDevice",
        documentAmount: Double? = 100.0,
        documentId: Int? = 12345,
        fastPayment: ProductStatementData.FastPayment? = .test,
        groupName: String = "Test Group Name",
        isCancellation: Bool? = true,
        md5hash: String = "testmd5hash",
        merchantName: String? = "Test Merchant Name",
        merchantNameRus: String? = "Тестовое Имя Продавца",
        opCode: Int? = 54321,
        operationId: String = "testoperationid",
        operationType: OperationType = .debit,
        paymentDetailType: ProductStatementData.Kind = .betweenTheir,
        svgImage: SVGImageData? = SVGImageData(description: "Test SVG Image"),
        terminalCode: String? = "testTerminalCode",
        tranDate: Date? = Date(),
        type: OperationEnvironment = .inside
    ) -> ProductStatementData {
        
        return ProductStatementData(
            mcc: mcc,
            accountId: accountId,
            accountNumber: accountNumber,
            amount: amount,
            cardTranNumber: cardTranNumber,
            city: city,
            comment: comment,
            country: country,
            currencyCodeNumeric: currencyCodeNumeric,
            date: date,
            deviceCode: deviceCode,
            documentAmount: documentAmount,
            documentId: documentId,
            fastPayment: fastPayment,
            groupName: groupName,
            isCancellation: isCancellation,
            md5hash: md5hash,
            merchantName: merchantName,
            merchantNameRus: merchantNameRus,
            opCode: opCode,
            operationId: operationId,
            operationType: operationType,
            paymentDetailType: paymentDetailType,
            svgImage: svgImage,
            terminalCode: terminalCode,
            tranDate: tranDate,
            type: type
        )
    }
    
    private func makeFastPayment(
        documentComment: String? = "Test FastPayment Comment",
        foreignBankBIC: String? = "044525491",
        foreignBankID: String? = "10000001153",
        foreignBankName: String? = "Test Foreign Bank Name",
        foreignName: String? = "Test Foreign Name",
        foreignPhoneNumber: String? = "70115110217",
        opkcid: String? = "A1355084612564010000057CAFC75755",
        operTypeFP: String? = "string",
        tradeName: String? = "Test Trade Name",
        guid: String? = "testguid"
    ) -> ProductStatementData.FastPayment {
        
        return ProductStatementData.FastPayment(
            documentComment: documentComment ?? "",
            foreignBankBIC: foreignBankBIC ?? "",
            foreignBankID: foreignBankID ?? "",
            foreignBankName: foreignBankName ?? "",
            foreignName: foreignName ?? "",
            foreignPhoneNumber: foreignPhoneNumber ?? "",
            opkcid: opkcid ?? "",
            operTypeFP: operTypeFP ?? "",
            tradeName: tradeName ?? "",
            guid: guid ?? ""
        )
    }
}

private extension ProductStatementData.FastPayment {
    
    static let test: Self = .init(documentComment: "string", foreignBankBIC: "044525491", foreignBankID: "10000001153", foreignBankName: "КУ ООО ПИР Банк - ГК \\\"АСВ\\\"", foreignName: "Петров Петр Петрович", foreignPhoneNumber: "70115110217", opkcid: "A1355084612564010000057CAFC75755", operTypeFP: "string", tradeName: "string", guid: "string")
    
}
