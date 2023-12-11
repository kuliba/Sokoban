//
//  ResponseMapper+mapCreateSberQRPaymentResponseTests.swift
//
//
//  Created by Igor Malyarov on 10.12.2023.
//

import SberQR
import XCTest

final class ResponseMapper_mapCreateSberQRPaymentResponseTests: XCTestCase {
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = anyData()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverServerErrorOnNilData() throws {
        
        let result = map(jsonWithError)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverServerErrorOnServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = map(jsonWithError, nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverInvalidOnNonOKHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = anyData()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: data
        )))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverResponseWithAmount_paymentOperationDetailId() throws {
        
        let result = map(paymentOperationDetailId)
        
        assert(result, equals: .success(.init(parameters: [
            makePaymentOperationDetailId()
        ])))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverResponseWithAmount_printFormType() throws {
        
        let result = map(printFormType)
        
        assert(result, equals: .success(.init(parameters: [
            makePrintFormType()
        ])))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverResponseWithAmount_successStatus() throws {
        
        let result = map(successStatus)
        
        assert(result, equals: .success(.init(parameters: [
            makeSuccessStatus()
        ])))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverResponseWithAmount_success_title() throws {
        
        let result = map(successTitle)
        
        assert(result, equals: .success(.init(parameters: [
            makeSuccessTitle()
        ])))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverResponseWithAmount_success_amount() throws {
        
        let result = map(successAmount)
        
        assert(result, equals: .success(.init(parameters: [
            makeSuccessAmount()
        ])))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverResponseWithAmount_brandName() throws {
        
        let result = map(brandName)
        
        assert(result, equals: .success(.init(parameters: [
            makeBrandName()
        ])))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverResponseWithAmount_success_option_buttons() throws {
        
        let result = map(successOptionButtons)
        
        assert(result, equals: .success(.init(parameters: [
            makeSuccessOptionButtons()
        ])))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverResponseWithAmount_button_main() throws {
        
        let result = map(buttonMain)
        
        assert(result, equals: .success(.init(parameters: [
            makeButtonMain()
        ])))
    }
    
    func test_mapCreateSberQRPaymentResponse_shouldDeliverResponseWithAmount() throws {
        
        let result = map(jsonSuccess)
        
        assert(result, equals: .success(.init(parameters: [
            makePaymentOperationDetailId(),
            makePrintFormType(),
            makeSuccessStatus(),
            makeSuccessTitle(),
            makeSuccessAmount(),
            makeBrandName(),
            makeSuccessOptionButtons(),
            makeButtonMain(),
        ])))
    }
    
    // MARK: - Helpers
    
    private typealias Parameter = CreateSberQRPaymentResponse.Parameter
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.CreateSberQRPaymentResult {
        
        ResponseMapper.mapCreateSberQRPaymentResponse(
            data,
            httpURLResponse
        )
    }
    
    private func map(
        _ string: String,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.CreateSberQRPaymentResult {
        
        map(Data(string.utf8), httpURLResponse)
    }
    
    private func makePaymentOperationDetailId() -> Parameter {
        
        .dataLong(.init(
            id: .paymentOperationDetailId,
            value: 81396
        ))
    }

    private func makePrintFormType() -> Parameter {
        
        .dataString(.init(
            id: .printFormType,
            value: "sberQR"
        ))
    }
    
    private func makeSuccessStatus() -> Parameter {
        
        .successStatusIcon(.init(
            id: .successStatus,
            value: .complete
        ))
    }

    private func makeSuccessTitle() -> Parameter {
        
        .successText(.init(
            id: .successTitle,
            value: "Покупка оплачена",
            style: .title
        ))
    }

    private func makeSuccessAmount() -> Parameter {
        
        .successText(.init(
            id: .successAmount,
            value: "220 ₽",
            style: .amount
        ))
    }
    
    private func makeBrandName() -> Parameter {
        
        .subscriber(.init(
            id: .brandName,
            value: "сббол енот_QR",
            style: .small,
            icon: "b6e5b5b8673544184896724799e50384",
            subscriptionPurpose: nil
        ))
    }
    
    private func makeSuccessOptionButtons() -> Parameter {
        
        .successOptionButton(.init(
            id: .successOptionButtons,
            values: [.document, .details]
        ))
    }
    
    private func makeButtonMain() -> Parameter {
        
        .button(.init(
            id: .buttonMain,
            value: "На главный",
            color: .red,
            action: .main,
            placement: .bottom
        ))
    }
    
    private func assert(
        _ receivedResult: ResponseMapper.CreateSberQRPaymentResult,
        equals expectedResult: ResponseMapper.CreateSberQRPaymentResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        switch (receivedResult, expectedResult) {
        case let (
            .failure(received),
            .failure(expected)
        ):
            XCTAssertNoDiff(received, expected, file: file, line: line)
            
        case let (
            .success(received),
            .success(expected)
        ):
            XCTAssertNoDiff(received, expected, file: file, line: line)
            
        default:
            XCTFail("\nExpected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
        }
    }
}

private let jsonWithError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""


private let paymentOperationDetailId = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "parameters": [
      {
        "id": "paymentOperationDetailId",
        "type": "DATA_LONG",
        "value": 81396
      }
    ]
  }
}
"""

private let printFormType = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "parameters": [
      {
        "id": "printFormType",
        "type": "DATA_STRING",
        "value": "sberQR"
      }
    ]
  }
}
"""

private let successStatus = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "parameters": [
      {
        "id": "success_status",
        "type": "SUCCESS_STATUS_ICON",
        "value": "COMPLETE"
      },
    ]
  }
}
"""

private let successTitle = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "parameters": [
      {
        "id": "success_title",
        "type": "SUCCESS_TEXT",
        "value": "Покупка оплачена",
        "style": "TITLE"
      },
    ]
  }
}
"""

private let successAmount = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "parameters": [
      {
        "id": "success_amount",
        "type": "SUCCESS_TEXT",
        "value": "220 ₽",
        "style": "AMOUNT"
      },
    ]
  }
}
"""

private let brandName = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "parameters": [
      {
        "id": "brandName",
        "type": "SUBSCRIBER",
        "value": "сббол енот_QR",
        "style": "SMALL",
        "icon": "b6e5b5b8673544184896724799e50384",
        "subscriptionPurpose": null
      },
    ]
  }
}
"""

private let successOptionButtons = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "parameters": [
      {
        "id": "success_option_buttons",
        "type": "SUCCESS_OPTION_BUTTONS",
        "value": [
          "DOCUMENT",
          "DETAILS"
        ]
      },
    ]
  }
}
"""

private let buttonMain = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "parameters": [
      {
        "id": "button_main",
        "type": "BUTTON",
        "value": "На главный",
        "color": "red",
        "action": "MAIN",
        "placement": "BOTTOM"
      }
    ]
  }
}
"""

private let jsonSuccess = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "parameters": [
      {
        "id": "paymentOperationDetailId",
        "type": "DATA_LONG",
        "value": 81396
      },
      {
        "id": "printFormType",
        "type": "DATA_STRING",
        "value": "sberQR"
      },
      {
        "id": "success_status",
        "type": "SUCCESS_STATUS_ICON",
        "value": "COMPLETE"
      },
      {
        "id": "success_title",
        "type": "SUCCESS_TEXT",
        "value": "Покупка оплачена",
        "style": "TITLE"
      },
      {
        "id": "success_amount",
        "type": "SUCCESS_TEXT",
        "value": "220 ₽",
        "style": "AMOUNT"
      },
      {
        "id": "brandName",
        "type": "SUBSCRIBER",
        "value": "сббол енот_QR",
        "style": "SMALL",
        "icon": "b6e5b5b8673544184896724799e50384",
        "subscriptionPurpose": null
      },
      {
        "id": "success_option_buttons",
        "type": "SUCCESS_OPTION_BUTTONS",
        "value": [
          "DOCUMENT",
          "DETAILS"
        ]
      },
      {
        "id": "button_main",
        "type": "BUTTON",
        "value": "На главный",
        "color": "red",
        "action": "MAIN",
        "placement": "BOTTOM"
      }
    ]
  }
}
"""
