//
//  AnywayPaymentTransactionReducerRestartPaymentTests.swift
//
//
//  Created by Igor Malyarov on 18.06.2024.
//

import XCTest

final class AnywayPaymentTransactionReducerRestartPaymentTests: AnywayPaymentTransactionReducerTests {
    
    func test_restartFlow_confirm() throws {
        
        var (state, states) = restart_0_initiate()
        XCTAssertNoDiff(state.elementIDs, [])
        XCTAssertTrue(state.isValid)
        XCTAssertTrue(states.map(\.isValid).allSatisfy({ $0 }))
        
        try restart_1_update(&state, &states)
        XCTAssertNoDiff(state.parameterIDs, ["1"])
        XCTAssertFalse(state.isValid)
        
        try msFraud_2_setValue(&state, &states)
        assertValue("009", forParameterID: "1", in: state)
        XCTAssertTrue(state.isValid)
        
        try restart_3_continue(&state, &states)
        XCTAssertNoDiff(state.context.staged, ["1"])
        XCTAssertNoDiff(state.context.outline.fields, ["1": "009"])
        XCTAssertTrue(state.isValid)
        
        try restart_4_update(&state, &states)
        XCTAssertNoDiff(state.context.staged, ["1"])
        XCTAssertNoDiff(state.context.outline.fields, ["1": "009"])
        
        XCTAssertNoDiff(states.map(\.status), [
            .none, .none, .none,
            .inflight,
            .none
        ])
        XCTAssertTrue(state.isValid)
        
        try restart_5_setValue(&state, &states)
        assertValue("00", forParameterID: "1", in: state)
        XCTAssertNoDiff(state.status, .awaitingPaymentRestartConfirmation)
        XCTAssertTrue(states.map(\.context.shouldRestart).allSatisfy({ !$0 }))
        XCTAssertTrue(state.isValid)
        
        try restart_6_confirm(&state, &states)
        assertValue("00", forParameterID: "1", in: state)
        XCTAssertTrue(state.isValid)
        XCTAssertNil(state.status)
        XCTAssertTrue(state.context.shouldRestart)
        XCTAssertNoDiff(state.context.staged, ["1"])
        XCTAssertNoDiff(state.context.outline.fields, ["1": "009"], "Outline should be updated after `continue`")
        
        try restart_7_continue(&state, &states)
        XCTAssertNoDiff(state.elementIDs, []) // OR WHAT IS IN PAYMENT_RESET
        XCTAssertTrue(state.isValid)
        XCTAssertNoDiff(state.status, .inflight)
        XCTAssertTrue(state.context.shouldRestart)
        XCTAssertNoDiff(state.context.staged, [])
        XCTAssertNoDiff(state.context.outline.fields, [
            "1": "00",
            "4": "0720",
            "6": "1000.15",
            "8": "200.15",
        ], "Outline should be updated after `continue`")
        
        try restart_8_confirm_update(&state, &states)
        XCTAssertNoDiff(state.parameterIDs, ["1"])
        assertValue("00", forParameterID: "1", in: state)
        XCTAssertTrue(state.isValid)
        XCTAssertNil(state.status)
        XCTAssertFalse(state.context.shouldRestart)
        XCTAssertNoDiff(state.context.staged, [])
        XCTAssertNoDiff(state.context.outline.fields, [
            "1": "00",
            "4": "0720",
            "6": "1000.15",
            "8": "200.15",
        ], "Outline should be updated after `continue`")
    }
    
    func test_restartFlow_deny() throws {
        
        var (state, states) = restart_0_initiate()
        try restart_1_update(&state, &states)
        try msFraud_2_setValue(&state, &states)
        try restart_3_continue(&state, &states)
        try restart_4_update(&state, &states)
        try restart_5_setValue(&state, &states)
        assertValue("00", forParameterID: "1", in: state)
        XCTAssertNoDiff(state.status, .awaitingPaymentRestartConfirmation)
        
        try restart_6_deny(&state, &states)
        assertValue("009", forParameterID: "1", in: state)
        XCTAssertTrue(state.isValid)
        XCTAssertNil(state.status)
        XCTAssertFalse(state.context.shouldRestart)
        XCTAssertNoDiff(state.context.staged, ["1"])
        XCTAssertNoDiff(state.context.outline.fields, ["1": "009"])
        
        try restart_7_continue(&state, &states)
        assertValue("009", forParameterID: "1", in: state)
        XCTAssertTrue(state.isValid)
        XCTAssertNoDiff(state.status, .inflight)
        XCTAssertFalse(state.context.shouldRestart)
        XCTAssertNoDiff(state.context.staged, ["1", "4", "6", "8"])
        XCTAssertNoDiff(state.context.outline.fields, [
            "1": "009",
            "4": "0720",
            "6": "1000.15",
            "8": "200.15",
        ], "Outline should be updated after `continue`")
    }

    // MARK: - Flow Helpers
    
    private func restart_0_initiate(
        _ state: State? = nil
    ) -> (State, [State]) {
        
        let state = state ?? makeState()
        return (state, [state])
    }
    
    private func restart_1_update(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        try update(&state, with: .restartStep1)
        states.append(state)
    }
    
    private func msFraud_2_setValue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .payment(.setValue("009", for: "1")))
        states.append(state)
    }
    
    private func restart_3_continue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .continue)
        states.append(state)
    }
    
    private func restart_4_update(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        try update(&state, with: .restartStep2)
        states.append(state)
    }
    
    private func restart_5_setValue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .payment(.setValue("00", for: "1")))
        states.append(state)
    }
    
    private func restart_6_confirm(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .paymentRestartConfirmation(true))
        states.append(state)
    }
    
    private func restart_6_deny(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .paymentRestartConfirmation(false))
        states.append(state)
    }
    
    private func restart_7_continue(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        reduce(&state, .continue)
        states.append(state)
    }
    
    private func restart_8_confirm_update(
        _ state: inout State,
        _ states: inout [State]
    ) throws {
        
        try update(&state, with: .restartStep1)
        states.append(state)
    }
}

// MARK: - Test data

private extension String {
    
    static let restartStep1 = """
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
        "regExp": ".+?",
        "rawLength": 0,
        "isRequired": true,
        "readOnly": false,
        "inputFieldType": "ACCOUNT",
        "visible": true,
        "md5hash": "6e17f502dae62b03d8bd4770606ee4b2"
      },
      {
        "id": "##ID##",
        "viewType": "OUTPUT",
        "content": "9bbed931-2c58-4d34-a069-07c5c40637fe",
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
    
    static let restartStep2 = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "additionalList": [
      {
        "fieldName": "2",
        "fieldValue": "Г. МОСКВА, УЛ. ЖИТНАЯ, 14.",
        "fieldTitle": "Адрес",
        "md5hash": "87f2fad4a6997e1d3ae634c551c50f14"
      },
      {
        "fieldName": "advisedAmount",
        "fieldValue": "1300.3",
        "fieldTitle": "Рекомендованная сумма"
      }
    ],
    "parameterListForNextStep": [
      {
        "id": "4",
        "title": "Период",
        "viewType": "INPUT",
        "dataType": "%Numeric",
        "type": "Input",
        "regExp": "^(0[1-9])\\\\d{2}|(1[012])\\\\d{2}|(0000)$",
        "rawLength": 0,
        "isRequired": false,
        "content": "0720",
        "readOnly": false,
        "visible": true
      },
      {
        "id": "6",
        "title": "ОТОПЛЕНИЕ",
        "viewType": "INPUT",
        "dataType": "%Numeric",
        "type": "Input",
        "regExp": "^(([1-9]\\\\d{0,})|([0]))([.]\\\\d{1}|[.]\\\\d{2})?",
        "rawLength": 2,
        "isRequired": false,
        "content": "1000.15",
        "readOnly": false,
        "inputFieldType": "COUNTER",
        "visible": true,
        "md5hash": "017e8b24ab276b57bd7be847905eeb4a"
      },
      {
        "id": "8",
        "title": "ГАЗ",
        "viewType": "INPUT",
        "dataType": "%Numeric",
        "type": "Input",
        "regExp": "^(([1-9]\\\\d{0,})|([0]))([.]\\\\d{1}|[.]\\\\d{2})?",
        "rawLength": 2,
        "isRequired": false,
        "content": "200.15",
        "readOnly": false,
        "visible": true
      },
      {
        "id": "##ID##",
        "viewType": "OUTPUT",
        "content": "9bbed931-2c58-4d34-a069-07c5c40637fe",
        "visible": false
      },
      {
        "id": "##STEP##",
        "viewType": "OUTPUT",
        "content": "2",
        "visible": false
      }
    ],
    "options": [
      "MULTI_SUM"
    ]
  }
}
"""
}
