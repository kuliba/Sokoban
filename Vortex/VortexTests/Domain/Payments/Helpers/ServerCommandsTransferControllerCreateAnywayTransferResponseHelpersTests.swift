//
//  ServerCommandsTransferControllerCreateAnywayTransferResponseHelpersTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 22.02.2023.
//

@testable import ForaBank
import XCTest

final class ServerCommandsTransferControllerCreateAnywayTransferResponseHelpersTests: XCTestCase {
    
    typealias Response = ServerCommands.TransferController.CreateAnywayTransfer.Response
    
    func test_errorResponse() {
        let errorResponse = Response.error
        
        XCTAssertEqual(errorResponse.statusCode, .error(102))
        XCTAssertEqual(errorResponse.errorMessage, "Техническая ошибка. Попробуйте еще раз")
        XCTAssertEqual(errorResponse.data, nil)
    }
    
    func test_bundled() throws {
        
        let response = Response.data(errorMessage: "string", data: .bundled)
        let fromBundle = try XCTUnwrap(Response.dataFromBundle())
        
        XCTAssertEqual(response, fromBundle)
        XCTAssertEqual(response.statusCode, fromBundle.statusCode)
        XCTAssertEqual(response.errorMessage, fromBundle.errorMessage)
        XCTAssertEqual(response.data, fromBundle.data)
    }
}

extension ServerCommands.TransferController.CreateAnywayTransfer.Response {
    
    /// Error response:
    ///
    /// {
    ///   "data" : null,
    ///   "statusCode" : 102,
    ///   "errorMessage" : "Техническая ошибка. Попробуйте еще раз"
    /// }
    static let error: Self = .init(
        statusCode: .error(102),
        errorMessage: "Техническая ошибка. Попробуйте еще раз",
        data: nil
    )
    
    static func data(
        errorMessage: String? = nil,
        data: TransferAnywayResponseData
    ) -> Self {
        
        .init(
            statusCode: .ok,
            errorMessage: errorMessage,
            data: data
        )
    }
    
    static func dataFromBundle() throws -> Self {
        
        typealias TestCase = ServerCommandsTransferControllerCreateAnywayTransferResponseHelpersTests

        return try TestCase.data(fromFilename: "CreateAnywayTransferResponseGeneric")
    }
}

extension TransferAnywayResponseData {
    
    //    static let iFora4285: TransferAnywayResponseData = .init()
    //    static let iFora4286: TransferAnywayResponseData = .init()
    
    static let bundled: TransferAnywayResponseData = .init(
        amount: 100,
        creditAmount: 100,
        currencyAmount: .rub,
        currencyPayee: .rub,
        currencyPayer: .rub,
        currencyRate: 86.7,
        debitAmount: 100,
        fee: 100,
        needMake: true,
        needOTP: true,
        payeeName: "Иван Иванович И.",
        documentStatus: .complete,
        paymentOperationDetailId: 1,
        additionalList: [
            .init(
                fieldName: "a3_PERSONAL_ACCOUNT_5_5",
                fieldTitle: "Лицевой счет у Получателя",
                fieldValue: "1234567890",
                svgImage: .init(description: "string"),
                typeIdParameterList: nil,
                recycle: nil
            )
        ],
        finalStep: false,
        infoMessage: "string",
        needSum: false, printFormType: nil,
        parameterListForNextStep: [
            .init(
                content: "account",
                dataType: "%String",
                id: "a3_NUMBER_1_2",
                isPrint: false,
                isRequired: true,
                mask: "+7(___)-___-__-__",
                maxLength: 10,
                minLength: 0,
                order: 2,
                rawLength: 0,
                readOnly: false,
                regExp: "^\\d{10}$",
                subTitle: "Пример: 9051111111",
                title: "Номер телефона +7",
                type: "Input",
                inputFieldType: .phone,
                dataDictionary: nil,
                dataDictionaryРarent: nil,
                group: nil,
                subGroup: nil,
                inputMask: nil,
                phoneBook: nil,
                svgImage: .init(description: "string"),
                viewType: .input
            )
        ],
        scenario: .ok
    )
}
