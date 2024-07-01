//
//  AnywayPaymentTransactionReducerMultiSumWithAntiFraudTests.swift
//  
//
//  Created by Igor Malyarov on 18.06.2024.
//

import XCTest

final class AnywayPaymentTransactionReducerMultiSumWithAntiFraudTests: AnywayPaymentTransactionReducerTests {
    
    // MARK: - multi-sum & antifraud @ mock
    
    func test_multiSumWithAntiFraudFlow_elements() throws {
        
        var (state, states) = msFraud_0_initiate()
        XCTAssertNoDiff(state.elementIDs, [])
        
        try msFraud_1_update(&state, &states)
        XCTAssertNoDiff(state.elementIDs, [.parameterID("1")])
        
        try msFraud_2_setValue(&state, &states)
        try msFraud_3_continue(&state, &states)
        try msFraud_4_update(&state, &states)

        XCTAssertNoDiff(state.elementIDs, [.parameterID("1"), .parameterID("2")])
        XCTAssertNoDiff(state.widgetIDs.count, 0)
        
        try msFraud_5_continue(&state, &states)
        try msFraud_6_update(&state, &states)

        XCTAssertNoDiff(state.context.payment.elements.count, 21)
        let parameterIDsStep3 = state.parameterIDs
        XCTAssertNoDiff(parameterIDsStep3.count, 11)
        XCTAssertNoDiff(parameterIDsStep3, ["1", "2",  "5", "9", "13", "17", "21", "25", "29", "65", "143"])
        XCTAssertNoDiff(state.widgetIDs.count, 0)
        
        try msFraud_7_continue(&state, &states)
        try msFraud_8_update(&state, &states)

        XCTAssertNoDiff(state.context.payment.elements.count, 23)
        XCTAssertNoDiff(state.parameterIDs, parameterIDsStep3)
        XCTAssertNoDiff(state.widgetIDs, [.product])
        
        try msFraud_9_continue(&state, &states)

        let contextStep4 = state.context
        
        try msFraud_10_update(&state, &states)
        XCTAssertNoDiff(state.context, contextStep4)
        
        try msFraud_11_continue(&state, &states)
        XCTAssertNoDiff(state.context, contextStep4)
        
        try msFraud_12_consent(&state, &states)
        XCTAssertNoDiff(state.context.payment.elements.count, 24)
    }
    
    func test_multiSumWithAntiFraudFlow_staged() throws {
        
        var (state, states) = msFraud_0_initiate()
        try msFraud_1_update(&state, &states)
        try msFraud_2_setValue(&state, &states)
        
        XCTAssertNoDiff(states.map(\.context.staged), [[], [], []])
        
        try msFraud_3_continue(&state, &states)
        let stagedStep3 = [[], [], [], Set(["1"])]
        XCTAssertNoDiff(states.map(\.context.staged), stagedStep3)
        
        try msFraud_4_update(&state, &states)
        XCTAssertNoDiff(states.map(\.context.staged), stagedStep3 + [["1"]])
        
        try msFraud_5_continue(&state, &states)
        try msFraud_6_update(&state, &states)
        
        let stagedStep6 = stagedStep3 + [["1"], ["1", "2"], ["1", "2"]]
        XCTAssertNoDiff(states.map(\.context.staged), stagedStep6)
        
        try msFraud_7_continue(&state, &states)
        try msFraud_8_update(&state, &states)
        try msFraud_9_continue(&state, &states)
        try msFraud_10_update(&state, &states)
        try msFraud_11_continue(&state, &states)
        try msFraud_12_consent(&state, &states)
        try msFraud_13_consent_continue(&state, &states)
        
        let staged = Set(["1", "2",  "5", "9", "13", "17", "21", "25", "29", "65", "143"])
        XCTAssertEqual(staged.count, 11)
        
        XCTAssertNoDiff(
            states.map(\.context.staged),
            stagedStep6 + .init(repeating: staged, count: 7)
        )
    }
    
    func test_multiSumWithAntiFraudFlow_outline_fields() throws {
        
        var (state, states) = msFraud_0_initiate()
        try msFraud_1_update(&state, &states)
        try msFraud_2_setValue(&state, &states)
        XCTAssertNoDiff(states.map(\.context.outline.fields), [[:], [:], [:]])
        
        let fieldsStep3 = ["1": "a"]

        try msFraud_3_continue(&state, &states)
        XCTAssertNoDiff(state.context.outline.fields, fieldsStep3)
        
        try msFraud_4_update(&state, &states)
        XCTAssertNoDiff(state.context.outline.fields, fieldsStep3)
        
        let fieldsStep5 = [
            "1": "a",
            "2": "ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС"
        ]

        try msFraud_5_continue(&state, &states)
        XCTAssertNoDiff(state.context.outline.fields, fieldsStep5)
        
        try msFraud_6_update(&state, &states)
        XCTAssertNoDiff(state.context.outline.fields, fieldsStep5)
        
        try msFraud_7_continue(&state, &states)
        try msFraud_8_update(&state, &states)
        try msFraud_9_continue(&state, &states)
        try msFraud_10_update(&state, &states)
        try msFraud_11_continue(&state, &states)
        try msFraud_12_consent(&state, &states)

        XCTAssertNoDiff(
            states.map(\.context.outline.fields),
            [[:], [:], [:], fieldsStep3, fieldsStep3, fieldsStep5, fieldsStep5] +
            .init(repeating: msFraudOutlineFields, count: 6)
        )
    }
    
    func test_multiSumWithAntiFraudFlow_isValid() throws {
        
        var (state, states) = msFraud_0_initiate()
        XCTAssertTrue(state.isValid)
        
        try msFraud_1_update(&state, &states)
        XCTAssertFalse(state.isValid)
        
        try msFraud_2_setValue(&state, &states)
        try msFraud_3_continue(&state, &states)
        try msFraud_4_update(&state, &states)
        try msFraud_5_continue(&state, &states)
        try msFraud_6_update(&state, &states)
        try msFraud_7_continue(&state, &states)
        try msFraud_8_update(&state, &states)
        try msFraud_9_continue(&state, &states)
        try msFraud_10_update(&state, &states)
        try msFraud_11_continue(&state, &states)
        try msFraud_12_consent(&state, &states)
        
        XCTAssertNoDiff(states.map(\.isValid), [true, false] + .init(repeating: true, count: 10) + [false])
    }
    
    func test_multiSumWithAntiFraudFlow_consent_status() throws {
        
        var (state, states) = msFraud_0_initiate()
        XCTAssertNil(state.status)
        
        try msFraud_1_update(&state, &states)
        XCTAssertNil(state.status)
        
        try msFraud_2_setValue(&state, &states)
        XCTAssertNil(state.status)
        
        try msFraud_3_continue(&state, &states)
        XCTAssertEqual(state.status, .inflight)
        
        try msFraud_4_update(&state, &states)
        XCTAssertNil(state.status)
        
        try msFraud_5_continue(&state, &states)
        XCTAssertEqual(state.status, .inflight)
        
        try msFraud_6_update(&state, &states)
        XCTAssertNil(state.status)
        
        try msFraud_7_continue(&state, &states)
        XCTAssertEqual(state.status, .inflight)
        
        try msFraud_8_update(&state, &states)
        XCTAssertNil(state.status)
        
        XCTAssertNoDiff(states.map(\.status), [
            .none,
            .none,
            .none,
            .inflight,
            .none,
            .inflight,
            .none,
            .inflight,
            .none
        ])
        
        try msFraud_9_continue(&state, &states)
        XCTAssertEqual(state.status, .inflight)
        
        try msFraud_10_update(&state, &states)
        try XCTAssertNoDiff(state.status, msFraudSuspectedStep5())
        
        try msFraud_11_continue(&state, &states)
        try XCTAssertEqual(state.status, msFraudSuspectedStep5(), "Fraud Status should be changed with `continue`")
        
        try msFraud_12_consent(&state, &states)
        XCTAssertNil(state.status)
    }
    
    func test_multiSumWithAntiFraudFlow_cancel_status() throws {
        
        var (state, states) = msFraud_0_initiate()
        try msFraud_1_update(&state, &states)
        try msFraud_2_setValue(&state, &states)
        try msFraud_3_continue(&state, &states)
        try msFraud_4_update(&state, &states)
        try msFraud_5_continue(&state, &states)
        try msFraud_6_update(&state, &states)
        try msFraud_7_continue(&state, &states)
        try msFraud_8_update(&state, &states)
        try msFraud_9_continue(&state, &states)
        try msFraud_10_update(&state, &states)
        try msFraud_11_continue(&state, &states)
        try msFraud_12_cancel(&state, &states)
        
        try XCTAssertNoDiff(states.map(\.status), [
            .none,
            .none,
            .none,
            .inflight,
            .none,
            .inflight,
            .none,
            .inflight,
            .none,
            .inflight,
            msFraudSuspectedStep5(),
            msFraudSuspectedStep5(),
            .result(.failure(.fraud(.cancelled))),
            
        ])
    }
    
    // MARK: - multi-sun helpers
    
    private var msFraudOutlineFields: [String: String] {
        
        let fields = [
            "1": "a",
            "2": "ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС",
            "5": "042024",
            "9": " ",
            "13": " ",
            "17": " ",
            "21": " ",
            "25": " ",
            "29": " ",
            "65": "4273.87",
            "143": "0.00"
        ]
        precondition(fields.count == 11)
        return fields
    }
    
    private func msFraud_0_initiate(
        _ state: State? = nil
    ) -> (State, [State]) {
        
        let state = state ?? makeState()
        return (state, [state])
    }
    
    private func msFraud_1_update(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        try update(&state, with: .multuSumFraudStep1)
        states.append(state)
    }
    
    private func msFraud_2_setValue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .payment(.setValue("a", for: "1")))
        states.append(state)
    }
    
    private func msFraud_3_continue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .continue)
        states.append(state)
    }
    
    private func msFraud_4_update(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        try update(&state, with: .multuSumFraudStep2)
        states.append(state)
    }
    
    private func msFraud_5_continue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .continue)
        states.append(state)
    }
    
    private func msFraud_6_update(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        try update(&state, with: .multuSumFraudStep3)
        states.append(state)
    }
    
    private func msFraud_7_continue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .continue)
        states.append(state)
    }
    
    private func msFraud_8_update(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        try update(&state, with: .multuSumFraudStep4)
        states.append(state)
    }
    
    private func msFraud_9_continue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .continue)
        states.append(state)
    }
    
    private func msFraud_10_update(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        try update(&state, with: .multuSumFraudStep5)
        states.append(state)
    }
    
    private func msFraud_11_continue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .continue)
        states.append(state)
    }
    
    private func msFraud_12_consent(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .fraud(.consent))
        states.append(state)
    }
    
    private func msFraud_12_cancel(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .fraud(.cancel))
        states.append(state)
    }
    
    private func msFraud_13_consent_continue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .continue)
        states.append(state)
    }
    
    private func msFraudSuspectedStep5() throws -> Status {
        
        try .fraudSuspected(makePaymentUpdate(from: .multuSumFraudStep5))
    }
}

// MARK: - Test data

private extension String {
    
    static let multuSumFraudStep1 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "parameterListForNextStep": [
            {
                "id": "1",
                "title": "Лицевой счет",
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "regExp": "^.{1,250}$",
                "rawLength": 0,
                "isRequired": true,
                "readOnly": false,
                "inputFieldType": "ACCOUNT",
                "visible": true,
                "md5hash": "6e17f502dae62b03d8bd4770606ee4b2"
            }
        ]
    }
}
"""
    
    static let multuSumFraudStep2 = """
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
    
    static let multuSumFraudStep3 = """
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
    
    static let multuSumFraudStep4 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "amount": 11,
        "needSum": true,
        "additionalList": [
            {
                "fieldName": "SumSTrs",
                "fieldValue": "11",
                "fieldTitle": "Сумма"
            }
        ],
        "parameterListForNextStep": []
    }
}
"""
    
    static let multuSumFraudStep5 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": true,
        "needOTP": true,
        "amount": 11,
        "fee": 0.00,
        "currencyAmount": "RUB",
        "currencyPayer": "RUB",
        "debitAmount": 11,
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
        "scenario": "SCOR_SUSPECT_FRAUD"
    }
}
"""
}
