//
//  AnywayPaymentSemiIntegrationTests.swift
//
//
//  Created by Igor Malyarov on 30.05.2024.
//

import AnywayPaymentAdapters
import AnywayPaymentBackend
import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentSemiIntegrationTests: XCTestCase {
    
    func test_multiSumFlow() throws {
        
        let payment0: AnywayPayment = makeEmptyPayment()
        XCTAssertTrue(payment0.elements.isEmpty)
        
        let payment1 = try update(payment0, with: .step1Response)
        XCTAssertNoDiff(payment1.elementsView, [
            .init("p: 1", "Лицевой счет"),
            .init("footer", "continue")
        ])
        //        XCTAssertNoDiff(payment1.makeDigest(), .init(
        //            additional: [],
        //            core: nil,
        //            puref: ""
        //        ))
        
#warning("add assertions for digest (or its simplified view)")
        
#warning("add assertions")
        let payment2 = try update(payment1, with: .step2Response)
        XCTAssertNoDiff(payment2.elementsView, [
            .init("p: 1", "Лицевой счет"),
            .init("p: 2", "Признак платежа"),
            .init("footer", "continue")
        ])
        
        let payment3 = try update(payment2, with: .step3Response)
        XCTAssertNoDiff(payment3.elementsView, [
            .init("p: 1", "Лицевой счет"),
            .init("p: 2", "Признак платежа"),
            .init("f: 4", "Адрес"),
            .init("f: 8", "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"),
            .init("f: 12", "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"),
            .init("f: 16", "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"),
            .init("f: 20", "ПРЕД. ПОКАЗАНИЯ ХВС №1012018234307"),
            .init("f: 24", "ПРЕД. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"),
            .init("f: 28", "ПРЕД. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213"),
            .init("f: 142", "Сумма страховки"),
            .init("f: 147", "Код филиала"),
            .init("f: advisedAmount", "Рекомендованная сумма"),
            .init("p: 5", "Период(ММГГГГ)"),
            .init("p: 9", "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"),
            .init("p: 13", "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"),
            .init("p: 17", "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"),
            .init("p: 21", "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307"),
            .init("p: 25", "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"),
            .init("p: 29", "ТЕК. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213"),
            .init("p: 65", "УСЛУГИ_ЖКУ"),
            .init("p: 143", "Сумма пени"),
            .init("w: core", "RUB, 1234567890, account"),
            .init("footer", "continue")
        ])
        
        let payment4 = try update(payment3, with: .step4Response)
        XCTAssertNoDiff(payment4.elementsView, [
            .init("p: 1", "Лицевой счет"),
            .init("p: 2", "Признак платежа"),
            .init("f: 4", "Адрес"),
            .init("f: 8", "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"),
            .init("f: 12", "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"),
            .init("f: 16", "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"),
            .init("f: 20", "ПРЕД. ПОКАЗАНИЯ ХВС №1012018234307"),
            .init("f: 24", "ПРЕД. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"),
            .init("f: 28", "ПРЕД. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213"),
            .init("f: 142", "Сумма страховки"),
            .init("f: 147", "Код филиала"),
            .init("f: advisedAmount", "Рекомендованная сумма"),
            .init("p: 5", "Период(ММГГГГ)"),
            .init("p: 9", "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"),
            .init("p: 13", "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"),
            .init("p: 17", "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"),
            .init("p: 21", "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307"),
            .init("p: 25", "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"),
            .init("p: 29", "ТЕК. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213"),
            .init("p: 65", "УСЛУГИ_ЖКУ"),
            .init("p: 143", "Сумма пени"),
            .init("w: core", "RUB, 1234567890, account"),
            .init("f: SumSTrs", "Сумма"),
            .init("footer", "amount")
        ])
        
        let payment5 = try update(payment4, with: .step5Response)
        XCTAssertNoDiff(payment5.elementsView, [
            .init("p: 1", "Лицевой счет"),
            .init("p: 2", "Признак платежа"),
            .init("f: 4", "Адрес"),
            .init("f: 8", "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"),
            .init("f: 12", "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"),
            .init("f: 16", "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"),
            .init("f: 20", "ПРЕД. ПОКАЗАНИЯ ХВС №1012018234307"),
            .init("f: 24", "ПРЕД. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"),
            .init("f: 28", "ПРЕД. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213"),
            .init("f: 142", "Сумма страховки"),
            .init("f: 147", "Код филиала"),
            .init("f: advisedAmount", "Рекомендованная сумма"),
            .init("p: 5", "Период(ММГГГГ)"),
            .init("p: 9", "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"),
            .init("p: 13", "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"),
            .init("p: 17", "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"),
            .init("p: 21", "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307"),
            .init("p: 25", "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"),
            .init("p: 29", "ТЕК. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213"),
            .init("p: 65", "УСЛУГИ_ЖКУ"),
            .init("p: 143", "Сумма пени"),
            .init("w: core", "RUB, 1234567890, account"),
            .init("f: SumSTrs", "Сумма"),
            .init("w: info", "info"),
            .init("w: otp", "otp"),
            .init("footer", "continue"),
        ])
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.CreateAnywayTransferResponse
    
    private func update(
        _ payment: AnywayPayment,
        with string: String,
        and outline: AnywayPaymentOutline = makeEmptyOutline()
    ) throws -> AnywayPayment {
        
        let update = try XCTUnwrap(AnywayPaymentUpdate(makeResponse(from: string)))
        
        return payment.update(with: update, and: outline)
    }
    
    private func makeResponse(
        from string: String
    ) throws -> Response {
        
        try ResponseMapper.mapCreateAnywayTransferResponse(.init(string.utf8), ok()).get()
    }
    
    private func ok(
        url: URL = anyURL()
    ) -> HTTPURLResponse {
        
        return .init(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
}

private struct TestView: Equatable {
    
    let id: String
    let title: String
    
    init(
        _ id: String,
        _ title: String
    ) {
        self.id = id
        self.title = title
    }
}

private extension AnywayPayment {
    
    var elementsView: [TestView] {
        
        var elements = elements.map(\.testView)
        elements.append(footer.testView)
        
        return elements
    }
}

private extension AnywayPayment.Footer {
    
    var testView: TestView {
        
        switch self {
        case .amount:   return .init("footer", "amount")
        case .continue: return .init("footer", "continue")
        }
    }
}

private extension AnywayElement {
    
    var testView: TestView {
        
        switch self {
        case let .field(field):
            return field.testView
            
        case let .parameter(parameter):
            return parameter.testView
            
        case let .widget(widget):
            return widget.testView
        }
    }
}

private extension AnywayElement.Field {
    
    var testView: TestView {
        
        return .init("f: \(id)", title)
    }
}

private extension AnywayElement.Parameter {
    
    var testView: TestView {
        
        return .init("p: \(field.id)", uiAttributes.title)
    }
}

private extension AnywayElement.Widget {
    
    var testView: TestView {
        
        switch self {
        case let .info(info):
            return .init("w: info", "info")
            
        case let .product(product):
            return .init("w: core", "\(product.currency), \(product.productID), \(product.productType)")
            
        case .otp:
            return .init("w: otp", "otp")
        }
    }
}

private func makeEmptyOutline(
    amount: Decimal = .init(Double.random(in: 1...1_000)),
    product: AnywayPaymentOutline.Product = makeOutlineProduct(),
    fields: [AnywayPaymentOutline.ID: AnywayPaymentOutline.Value] = [:],
    payload: AnywayPaymentOutline.Payload = makeAnywayPaymentPayload()
) -> AnywayPaymentOutline {
    
    return .init(amount: amount, product: product, fields: fields, payload: payload)
}

private func makeOutlineProduct(
    currency: String = "RUB",
    productID: Int = 1234567890,
    productType: AnywayPaymentOutline.Product.ProductType = .account
) -> AnywayPaymentOutline.Product {
    
    return .init(
        currency: currency,
        productID: productID,
        productType: productType
    )
}

private func makeAnywayPaymentPayload(
    puref: AnywayPaymentOutline.Payload.Puref = anyMessage(),
    title: String = anyMessage(),
    subtitle: String = anyMessage(),
    icon: String = anyMessage()
) -> AnywayPaymentOutline.Payload {
    
    return .init(puref: puref, title: title, subtitle: subtitle, icon: icon)
}

private func makeEmptyPayment(
) -> AnywayPayment {
    
    return .init(
        amount: nil,
        elements: [],
        footer: .continue,
        isFinalStep: false
    )
}

func unimplemented<T>(
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) -> T {
    
    fatalError("Unimplemented: \(message)", file: file, line: line)
}

private extension String {
    
    static let step1Response = """
{
    "statusCode":0,
    "errorMessage":null,
    "data":{
       "parameterListForNextStep":[
          {
             "id":"1",
             "title":"Лицевой счет",
             "viewType":"INPUT",
             "dataType":"%Numeric",
             "type":"Input",
             "regExp":"^.{1,250}$",
             "rawLength":0,
             "isRequired":true,
             "readOnly":false,
             "inputFieldType":"ACCOUNT",
             "visible":true,
             "md5hash":"6e17f502dae62b03d8bd4770606ee4b2"
          }
       ]
    }
}
"""
    
    static let step2Response = """
{
   "statusCode": 0,
   "errorMessage": null,
   "data": {
       "parameterListForNextStep": [
           {
               "id": "2",
               "title": "Признак платежа",
               "viewType": "INPUT",
               "dataType": "=;ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС=ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС;БЕЗ СТРАХОВОГО ВЗНОСА=БЕЗ СТРАХОВОГО ВЗНОСА;ПРОЧИЕ ПЛАТЕЖИ=ПРОЧИЕ ПЛАТЕЖИ",
               "type": "Select",
               "regExp": "^.{1,250}$",
               "rawLength": 0,
               "isRequired": true,
               "readOnly": false,
               "visible": true
           }
       ]
   }
}
"""
    
    static let step3Response = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "additionalList": [
      {
        "fieldName": "4",
        "fieldValue": "МОСКВА,АМУРСКАЯ УЛ.,2А К2,108",
        "fieldTitle": "Адрес",
        "md5hash": "87f2fad4a6997e1d3ae634c551c50f14"
      },
      {
        "fieldName": "8",
        "fieldValue": "253.650",
        "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"
      },
      {
        "fieldName": "12",
        "fieldValue": "444.420",
        "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"
      },
      {
        "fieldName": "16",
        "fieldValue": "370.060",
        "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"
      },
      {
        "fieldName": "20",
        "fieldValue": "37.750",
        "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ХВС №1012018234307"
      },
      {
        "fieldName": "24",
        "fieldValue": "56.216",
        "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"
      },
      {
        "fieldName": "28",
        "fieldValue": "2.839",
        "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
        "md5hash": "017e8b24ab276b57bd7be847905eeb4a"
      },
      {
        "fieldName": "142",
        "fieldValue": "0.00",
        "fieldTitle": "Сумма страховки"
      },
      {
        "fieldName": "147",
        "fieldValue": "04",
        "fieldTitle": "Код филиала"
      },
      {
        "fieldName": "advisedAmount",
        "fieldValue": "4273.87",
        "fieldTitle": "Рекомендованная сумма"
      }
    ],
    "parameterListForNextStep": [
      {
        "id": "5",
        "title": "Период(ММГГГГ)",
        "viewType": "INPUT",
        "dataType": "%String",
        "type": "Input",
        "regExp": "^.{1,250}$",
        "rawLength": 0,
        "isRequired": false,
        "content": "042024",
        "readOnly": false,
        "visible": true
      },
      {
        "id": "9",
        "title": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504",
        "viewType": "INPUT",
        "dataType": "%String",
        "type": "Input",
        "regExp": "^.{1,250}$",
        "rawLength": 0,
        "isRequired": false,
        "content": " ",
        "readOnly": false,
        "visible": true
      },
      {
        "id": "13",
        "title": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504",
        "viewType": "INPUT",
        "dataType": "%String",
        "type": "Input",
        "regExp": "^.{1,250}$",
        "rawLength": 0,
        "isRequired": false,
        "content": " ",
        "readOnly": false,
        "visible": true
      },
      {
        "id": "17",
        "title": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504",
        "viewType": "INPUT",
        "dataType": "%String",
        "type": "Input",
        "regExp": "^.{1,250}$",
        "rawLength": 0,
        "isRequired": false,
        "content": " ",
        "readOnly": false,
        "visible": true
      },
      {
        "id": "21",
        "title": "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307",
        "viewType": "INPUT",
        "dataType": "%String",
        "type": "Input",
        "regExp": "^.{1,250}$",
        "rawLength": 0,
        "isRequired": false,
        "content": " ",
        "readOnly": false,
        "visible": true
      },
      {
        "id": "25",
        "title": "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708",
        "viewType": "INPUT",
        "dataType": "%String",
        "type": "Input",
        "regExp": "^.{1,250}$",
        "rawLength": 0,
        "isRequired": false,
        "content": " ",
        "readOnly": false,
        "visible": true
      },
      {
        "id": "29",
        "title": "ТЕК. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
        "viewType": "INPUT",
        "dataType": "%String",
        "type": "Input",
        "regExp": "^.{1,250}$",
        "rawLength": 0,
        "isRequired": false,
        "content": " ",
        "readOnly": false,
        "inputFieldType": "COUNTER",
        "visible": true,
        "md5hash": "017e8b24ab276b57bd7be847905eeb4a"
      },
      {
        "id": "65",
        "title": "УСЛУГИ_ЖКУ",
        "viewType": "INPUT",
        "dataType": "%Numeric",
        "type": "Input",
        "regExp": "^.{1,250}$",
        "rawLength": 2,
        "isRequired": false,
        "content": "4273.87",
        "readOnly": false,
        "visible": true
      },
      {
        "id": "143",
        "title": "Сумма пени",
        "viewType": "INPUT",
        "dataType": "%Numeric",
        "type": "Input",
        "regExp": "^.{1,250}$",
        "rawLength": 2,
        "isRequired": false,
        "content": "0.00",
        "readOnly": false,
        "inputFieldType": "PENALTY",
        "visible": true,
        "md5hash": "4e14d4a92a2286786b4daa8ec0e9d4a3"
      }
    ],
    "options": [
      "MULTI_SUM"
    ]
  }
}
"""
    
    static let step4Response = """
{
   "statusCode": 0,
   "errorMessage": null,
   "data": {
       "amount": 4273.87,
       "needSum": true,
       "additionalList": [
           {
               "fieldName": "SumSTrs",
               "fieldValue": "4273.87",
               "fieldTitle": "Сумма"
           }
       ],
       "parameterListForNextStep": []
   }
}
"""
    
    static let step5Response = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": true,
        "needOTP": true,
        "amount": 4273.87,
        "fee": 0.00,
        "currencyAmount": "RUB",
        "currencyPayer": "RUB",
        "debitAmount": 4273.87,
        "payeeName": "ЕРЦ УПРАВДОМ: ЖКУ МОСКОВСКАЯ/КАЛУЖСКАЯ ОБЛ., Г. МОСКВА",
        "additionalList": [
            {
                "fieldName": "1",
                "fieldValue": "100611401082",
                "fieldTitle": "Лицевой счет",
                "md5hash": "6e17f502dae62b03d8bd4770606ee4b2"
            },
            {
                "fieldName": "2",
                "fieldValue": "БЕЗ СТРАХОВОГО ВЗНОСА",
                "fieldTitle": "Признак платежа"
            },
            {
                "fieldName": "4",
                "fieldValue": "МОСКВА,АМУРСКАЯ УЛ.,2А К2,108",
                "fieldTitle": "Адрес",
                "md5hash": "87f2fad4a6997e1d3ae634c551c50f14"
            },
            {
                "fieldName": "5",
                "fieldValue": "022024",
                "fieldTitle": "Период(ММГГГГ)"
            },
            {
                "fieldName": "8",
                "fieldValue": "253.650",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"
            },
            {
                "fieldName": "9",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"
            },
            {
                "fieldName": "12",
                "fieldValue": "444.420",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"
            },
            {
                "fieldName": "13",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"
            },
            {
                "fieldName": "16",
                "fieldValue": "370.060",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"
            },
            {
                "fieldName": "17",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"
            },
            {
                "fieldName": "20",
                "fieldValue": "37.750",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ХВС №1012018234307"
            },
            {
                "fieldName": "21",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307"
            },
            {
                "fieldName": "24",
                "fieldValue": "56.216",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"
            },
            {
                "fieldName": "25",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"
            },
            {
                "fieldName": "28",
                "fieldValue": "2.839",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
                "md5hash": "017e8b24ab276b57bd7be847905eeb4a"
            },
            {
                "fieldName": "29",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
                "md5hash": "017e8b24ab276b57bd7be847905eeb4a"
            },
            {
                "fieldName": "65",
                "fieldValue": "4273.87",
                "fieldTitle": "УСЛУГИ_ЖКУ"
            },
            {
                "fieldName": "142",
                "fieldValue": "0.00",
                "fieldTitle": "Сумма страховки"
            },
            {
                "fieldName": "143",
                "fieldValue": "0.00",
                "fieldTitle": "Сумма пени",
                "md5hash": "4e14d4a92a2286786b4daa8ec0e9d4a3"
            },
            {
                "fieldName": "147",
                "fieldValue": "04",
                "fieldTitle": "Код филиала"
            },
            {
                "fieldName": "advisedAmount",
                "fieldValue": "4273.87",
                "fieldTitle": "Рекомендованная сумма"
            }
        ],
        "parameterListForNextStep": [],
        "finalStep": true,
        "scenario": "OK"
    }
}
"""
}
