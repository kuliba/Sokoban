//
//  AnywayPaymentContext+preview.swift
//  TransactionPreview
//
//  Created by Igor Malyarov on 20.05.2024.
//

import AnywayPaymentAdapters
import AnywayPaymentBackend
import AnywayPaymentDomain
import Foundation
import RemoteServices

extension AnywayPaymentContext {
    
    static let preview: Self = .init(
        payment: .preview.updating(),
        staged: .init(),
        outline: .preview
    )
}

private extension AnywayPayment {
    
    static let preview: Self = .init(
        elements: [.parameter(.stringInput)],
        infoMessage: nil,
        isFinalStep: false,
        isFraudSuspected: false,
        puref: .init("iFora||54321")
    )
}


private extension AnywayPaymentOutline {
    
#warning("looks like PaymentCore should be optional in AnywayPaymentOutline")
    static let preview: Self = .init(
        core: .preview,
        fields: [:]
    )
}

private extension AnywayPaymentOutline.PaymentCore {
    
    static let preview: Self = .init(
        amount: 123.45,
        currency: "RUB",
        productID: 987654321,
        productType: .account
    )
}
private extension AnywayPayment {
    
    func updating() -> Self {
        
        let map = ResponseMapper.mapCreateAnywayTransferResponse
        guard let response = try? map(.init(String.sample.utf8), .ok).get()
        else { return self }
        
#warning("looks like PaymentCore should be optional in AnywayPaymentOutline")
        return self.update(
            with: .init(response),
            and: .init(
                core: .init(
                    amount: 123.45,
                    currency: "RUB",
                    productID: 234567891,
                    productType: .account
                ),
                fields: [:]
            )
        )
    }
}

private extension HTTPURLResponse {
    
    static var ok: Self {
        
        return .init(
            url: .init(string: "url")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
    }
}

extension String {
    
    // contains e1_sample_step1-3
    static let sample0 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "additionalList": [
            {
                "fieldName": "advisedAmount",
                "fieldValue": "4273.87",
                "fieldTitle": "Рекомендованная сумма"
            }
        ],
        "parameterListForNextStep": [
            {
                "id": "1",
                "title": "Лицевой счет",
                "viewType": "INPUT",
                "dataType": "%Numeric",
                "type": "Input",
                "regExp": "^.{1,250}$",
                "rawLength": 0,
                "isRequired": true,
                "readOnly": false,
                "inputFieldType": "ACCOUNT",
                "visible": true,
                "md5hash": "6e17f502dae62b03d8bd4770606ee4b2"
            },
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
            },
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
            },
            {
                "id": "##ID##",
                "viewType": "OUTPUT",
                "content": "ffc84724-8976-4d37-8af8-be84a4386126",
                "visible": false
            },
            {
                "id": "##STEP##",
                "viewType": "OUTPUT",
                "content": "1",
                "visible": false
            }
        ]
    }
}
"""
    
    static let sample = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": true,
        "needOTP": true,
        "amount": 4374.48,
        "fee": 0.00,
        "currencyAmount": "RUB",
        "currencyPayer": "RUB",
        "debitAmount": 4374.48,
        "payeeName": "ЕРЦ УПРАВДОМ: ЖКУ МОСКОВСКАЯ/КАЛУЖСКАЯ ОБЛ., Г. МОСКВА",
        "needSum": true,
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
                "fieldValue": "228.150",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"
            },
            {
                "fieldName": "9",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"
            },
            {
                "fieldName": "12",
                "fieldValue": "407.250",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"
            },
            {
                "fieldName": "13",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"
            },
            {
                "fieldName": "16",
                "fieldValue": "311.570",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"
            },
            {
                "fieldName": "17",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"
            },
            {
                "fieldName": "20",
                "fieldValue": "32.129",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ХВС №1012018234307"
            },
            {
                "fieldName": "21",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307"
            },
            {
                "fieldName": "24",
                "fieldValue": "48.052",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"
            },
            {
                "fieldName": "25",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"
            },
            {
                "fieldName": "28",
                "fieldValue": "2.789",
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
                "fieldValue": "4374.48",
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
            },
            {
                "fieldName": "SumSTrs",
                "fieldValue": "4374.48",
                "fieldTitle": "Сумма"
            }
        ],
        "parameterListForNextStep": [
            {
                "id": "1",
                "title": "Лицевой счет",
                "viewType": "INPUT",
                "dataType": "%Numeric",
                "type": "Input",
                "regExp": "^.{1,250}$",
                "rawLength": 0,
                "isRequired": true,
                "readOnly": false,
                "inputFieldType": "ACCOUNT",
                "visible": true,
                "md5hash": "6e17f502dae62b03d8bd4770606ee4b2"
            },
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
            },
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
            },
            {
                "id": "##ID##",
                "viewType": "OUTPUT",
                "content": "ffc84724-8976-4d37-8af8-be84a4386126",
                "visible": false
            },
            {
                "id": "##STEP##",
                "viewType": "OUTPUT",
                "content": "1",
                "visible": false
            }
        ]
    }
}
"""
}
