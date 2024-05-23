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
        elements: [
            .parameter(.stringInput),
            .widget(.otp(nil)),
            .widget(.core(.init(
                amount: 1_234.56,
                currency: "RUB",
                productID: .accountID(234567891) // ProductSelect.Product+ext.swift:21
            )))
        ],
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
    static let sample = """
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
}
