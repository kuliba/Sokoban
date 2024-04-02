//
//  AnywayPaymentUpdateTests.swift
//
//
//  Created by Igor Malyarov on 02.04.2024.
//

import AnywayPaymentBackend
import AnywayPaymentCore
import RemoteServices
import XCTest

struct AnywayPaymentUpdate: Equatable {
    
    let details: Details
    let fields: [Field]
    let parameters: [Parameter]
}

extension AnywayPaymentUpdate {
    
    struct Details: Equatable {
        
        let amounts: Amounts
        let control: Control
        let info: Info
    }
    
    struct Field: Equatable {}
    
    struct Parameter: Equatable {
        
        let field: Field
        let masking: Masking
        let validation: Validation
        let uiAttributes: UIAttributes
    }
}

extension AnywayPaymentUpdate.Details {
    
    struct Amounts: Equatable {
        
        let amount: Decimal?
        let creditAmount: Decimal?
        let currencyAmount: String?
        let currencyPayee: String?
        let currencyPayer: String?
        let currencyRate: Decimal?
        let debitAmount: Decimal?
        let fee: Decimal?
    }
    
    struct Control: Equatable {
        
        let isFinalStep: Bool
        let isFraudSuspected: Bool
        let needMake: Bool
        let needOTP: Bool
        let needSum: Bool
    }
    
    struct Info: Equatable {
        
        let documentStatus: String? // enum!
        let infoMessage: String?
        let payeeName: String?
        let paymentOperationDetailID: Int?
        let printFormType: String?
    }
}

extension AnywayPaymentUpdate.Parameter {
    
    struct Field: Equatable {
        
        let content: String?
        let dataDictionary: String?
        let dataDictionaryРarent: String?
        let dataType: String
        let id: String
    }
    
    struct Masking: Equatable {
        
        let inputMask: String?
        let mask: String?
    }
    
    struct Validation: Equatable {
        
        let isRequired: Bool
        let maxLength: Int?
        let minLength: Int?
        let rawLength: Int
        let regExp: String
    }
    
    struct UIAttributes: Equatable {
        
        let group: String?
        let inputFieldType: InputFieldType?
        let isPrint: Bool
        let order: Int?
        let phoneBook: Bool
        let isReadOnly: Bool
        let subGroup: String?
        let subTitle: String?
        let svgImage: String?
        let title: String
        let type: String
        let viewType: ViewType
    }
}

extension AnywayPaymentUpdate.Parameter.UIAttributes {
    
    enum InputFieldType: Equatable {
        
        case account
        case address
        case amount
        case bank
        case bic
        case counter
        case date
        case insurance
        case inn
        case name
        case oktmo
        case penalty
        case phone
        case purpose
        case recipient
        case view
    }
    
    enum ViewType: Equatable {
        
        case constant, input, output
    }
}

extension AnywayPaymentUpdate {
    
    init(_ response: ResponseMapper.CreateAnywayTransferResponse) {
        
        self.init(
            details: .init(response),
            fields: [],
            parameters: response.parametersForNextStep.map { .init($0) }
        )
    }
}

private extension AnywayPaymentUpdate.Details {
    
    init(_ response: ResponseMapper.CreateAnywayTransferResponse) {
        
        self.init(
            amounts: .init(response),
            control: .init(response),
            info: .init(response)
        )
    }
}

private extension AnywayPaymentUpdate.Details.Amounts {
    
    init(_ response: ResponseMapper.CreateAnywayTransferResponse) {
        
        self.init(
            amount: response.amount,
            creditAmount: response.creditAmount,
            currencyAmount: response.currencyAmount,
            currencyPayee: response.currencyPayee,
            currencyPayer: response.currencyPayer,
            currencyRate: response.currencyRate,
            debitAmount: response.debitAmount,
            fee: response.fee
        )
    }
}

private extension AnywayPaymentUpdate.Details.Control {
    
    init(_ response: ResponseMapper.CreateAnywayTransferResponse) {
        
        self.init(
            isFinalStep: response.finalStep,
            isFraudSuspected: response.scenario == .suspect,
            needMake: response.needMake,
            needOTP: response.needOTP,
            needSum: response.needSum
        )
    }
}

private extension AnywayPaymentUpdate.Details.Info {
    
    init(_ response: ResponseMapper.CreateAnywayTransferResponse) {
        
        self.init(
            documentStatus: response.documentStatus,
            infoMessage: response.infoMessage,
            payeeName: response.payeeName,
            paymentOperationDetailID: response.paymentOperationDetailID,
            printFormType: response.printFormType
        )
    }
}

private extension AnywayPaymentUpdate.Parameter {
    
    init(_ parameter: ResponseMapper.CreateAnywayTransferResponse.Parameter) {
        
        self.init(
            field: .init(parameter),
            masking: .init(parameter),
            validation: .init(parameter),
            uiAttributes: .init(parameter)
        )
    }
}

private extension AnywayPaymentUpdate.Parameter.Field {
    
    init(_ parameter: ResponseMapper.CreateAnywayTransferResponse.Parameter) {
        
        self.init(
            content: parameter.content,
            dataDictionary: parameter.dataDictionary,
            dataDictionaryРarent: parameter.dataDictionaryРarent,
            dataType: parameter.dataType,
            id: parameter.id
        )
    }
}

private extension AnywayPaymentUpdate.Parameter.Masking {
    
    init(_ parameter: ResponseMapper.CreateAnywayTransferResponse.Parameter) {
        
        self.init(
            inputMask: parameter.inputMask,
            mask: parameter.mask
        )
    }
}

private extension AnywayPaymentUpdate.Parameter.Validation {
    
    init(_ parameter: ResponseMapper.CreateAnywayTransferResponse.Parameter) {
        
        self.init(
            isRequired: parameter.isRequired,
            maxLength: parameter.maxLength,
            minLength: parameter.minLength,
            rawLength: parameter.rawLength,
            regExp: parameter.regExp
        )
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes {
    
    init(_ parameter: ResponseMapper.CreateAnywayTransferResponse.Parameter) {
        
        self.init(
            group: parameter.group,
            inputFieldType: parameter.inputFieldType.map { .init($0) },
            isPrint: parameter.isPrint,
            order: parameter.order,
            phoneBook: parameter.phoneBook,
            isReadOnly: parameter.isReadOnly,
            subGroup: parameter.subGroup,
            subTitle: parameter.subTitle,
            svgImage: parameter.svgImage,
            title: parameter.title,
            type: parameter.type,
            viewType: .init(parameter.viewType)
        )
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes.InputFieldType {
    
    init(_ type: ResponseMapper.CreateAnywayTransferResponse.Parameter.InputFieldType) {
        
        switch type {
        case .account:   self = .account
        case .address:   self = .address
        case .amount:    self = .amount
        case .bank:      self = .bank
        case .bic:       self = .bic
        case .counter:   self = .counter
        case .date:      self = .date
        case .insurance: self = .insurance
        case .inn:       self = .inn
        case .name:      self = .name
        case .oktmo:     self = .oktmo
        case .penalty:   self = .penalty
        case .phone:     self = .phone
        case .purpose:   self = .purpose
        case .recipient: self = .recipient
        case .view:      self = .view
        }
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes.ViewType {
    
    init(_ type: ResponseMapper.CreateAnywayTransferResponse.Parameter.ViewType) {
        
        switch type {
        case .constant: self = .constant
        case .input:    self = .input
        case .output:   self = .output
        }
    }
}

final class AnywayPaymentUpdateTests: XCTestCase {
    
    func test_init_validData() throws {
        
        try assert(.validData, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(),
                control: makeDetailsControl(
                    isFinalStep: false,
                    isFraudSuspected: false,
                    needMake: false,
                    needOTP: false,
                    needSum: false
                ),
                info: makeDetailsInfo(
                    paymentOperationDetailID: 54321
                )
            ),
            fields: [],
            parameters: [
                .init(
                    field: makeParameterField(
                        dataType: "%String",
                        id: "1"
                    ),
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        isRequired: true,
                        rawLength: 0,
                        regExp: "^.{1,250}$"
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        inputFieldType: .account,
                        isPrint: true,
                        order: 1,
                        svgImage: "svgImage",
                        title: "Лицевой счет",
                        type: "Input",
                        viewType: .input
                    )
                )
            ]
        ))
    }
    
    func test_init_validData2() throws {
        
        try assert(.validData2, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(),
                control: makeDetailsControl(
                    isFinalStep: true,
                    isFraudSuspected: true,
                    needMake: true,
                    needOTP: true,
                    needSum: true
                ),
                info: makeDetailsInfo()
            ),
            fields: [],
            parameters: [
                .init(
                    field: makeParameterField(
                        dataType: "%String",
                        id: "1"
                    ),
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        isRequired: true,
                        rawLength: 0,
                        regExp: "^.{1,250}$"
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        inputFieldType: .account,
                        isPrint: true,
                        order: 1,
                        svgImage: "svgImage",
                        title: "Лицевой счет",
                        type: "Input",
                        viewType: .input
                    )
                )
            ]
        ))
    }
    
    //    func test_init_valid_sber01() throws {
    //
    //        try assert(.valid_sber01, mapsTo: .init(
    //            fields: [],
    //            details: makeDetails(
    //                finalStep: false,
    //                needMake: false,
    //                needOTP: false,
    //                needSum: false,
    //                isFraudSuspected: false
    //            ),
    //            parameters: []
    //        ))
    //    }
    
    //    func test_init_valid_sber02() throws {
    //
    //        try assert(.valid_sber02, mapsTo: .init(
    //            fields: [],
    //            details: makeDetails(
    //                finalStep: false,
    //                needMake: false,
    //                needOTP: false,
    //                needSum: false,
    //                isFraudSuspected: false
    //            ),
    //            parameters: []
    //        ))
    //    }
    //
    //    func test_init_valid_sber03() throws {
    //
    //        try assert(.valid_sber03, mapsTo: .init(
    //            fields: [],
    //            details: makeDetails(
    //                amount: 5_888.1,
    //                finalStep: false,
    //                needMake: false,
    //                needOTP: false,
    //                needSum: true,
    //                isFraudSuspected: false
    //            ),
    //            parameters: []
    //        ))
    //    }
    
    func test_init_valid_sber04() throws {
        
        try assert(.valid_sber04, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(
                    amount: 5_888.1
                ),
                control: makeDetailsControl(
                    isFinalStep: false,
                    isFraudSuspected: false,
                    needMake: false,
                    needOTP: false,
                    needSum: true
                ),
                info: makeDetailsInfo()
            ),
            fields: [],
            parameters: []
        ))
    }
    
    func test_init_valid_sber05() throws {
        
        try assert(.valid_sber05, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(
                    amount: 5_888.1,
                    currencyAmount: "RUB",
                    debitAmount: 5_888.1,
                    fee: 0
                ),
                control: makeDetailsControl(
                    isFinalStep: true,
                    isFraudSuspected: false,
                    needMake: false,
                    needOTP: false,
                    needSum: true
                ),
                info: makeDetailsInfo()
            ),
            fields: [],
            parameters: []
        ))
    }
    
    // MARK: - Helpers
    
    private func makeDetailsAmounts(
        amount: Decimal? = nil,
        creditAmount: Decimal? = nil,
        currencyAmount: String? = nil,
        currencyPayee: String? = nil,
        currencyPayer: String? = nil,
        currencyRate: Decimal? = nil,
        debitAmount: Decimal? = nil,
        fee: Decimal? = nil
    ) -> AnywayPaymentUpdate.Details.Amounts {
        
        .init(
            amount: amount,
            creditAmount: creditAmount,
            currencyAmount: currencyAmount,
            currencyPayee: currencyPayee,
            currencyPayer: currencyPayer,
            currencyRate: currencyRate,
            debitAmount: debitAmount,
            fee: fee
        )
    }
    
    private func makeDetailsControl(
        isFinalStep: Bool,
        isFraudSuspected: Bool,
        needMake: Bool,
        needOTP: Bool,
        needSum: Bool
    ) -> AnywayPaymentUpdate.Details.Control {
        
        .init(
            isFinalStep: isFinalStep,
            isFraudSuspected: isFraudSuspected,
            needMake: needMake,
            needOTP: needOTP,
            needSum: needSum
        )
    }
    
    private func makeDetailsInfo(
        documentStatus: String? = nil,
        infoMessage: String? = nil,
        payeeName: String? = nil,
        paymentOperationDetailID: Int? = nil,
        printFormType: String? = nil
    ) -> AnywayPaymentUpdate.Details.Info {
        
        .init(
            documentStatus: documentStatus,
            infoMessage: infoMessage,
            payeeName: payeeName,
            paymentOperationDetailID: paymentOperationDetailID,
            printFormType: printFormType
        )
    }
    
    private func makeParameterField(
        content: String? = nil,
        dataDictionary: String? = nil,
        dataDictionaryРarent: String? = nil,
        dataType: String,
        id: String
    ) -> AnywayPaymentUpdate.Parameter.Field {
        
        .init(
            content: content,
            dataDictionary: dataDictionary,
            dataDictionaryРarent: dataDictionaryРarent,
            dataType: dataType,
            id: id
        )
    }
    
    private func makeParameterMasking(
        inputMask: String? = nil,
        mask: String? = nil
    ) -> AnywayPaymentUpdate.Parameter.Masking {
        
        .init(
            inputMask: inputMask,
            mask: mask
        )
    }
    
    private func makeParameterValidation(
        isRequired: Bool = false,
        maxLength: Int? = nil,
        minLength: Int? = nil,
        rawLength: Int,
        regExp: String
    ) -> AnywayPaymentUpdate.Parameter.Validation {
        
        .init(
            isRequired: isRequired,
            maxLength: maxLength,
            minLength: minLength,
            rawLength: rawLength,
            regExp: regExp
        )
    }
    
    private func makeParameterUIAttributes(
        group: String? = nil,
        inputFieldType: AnywayPaymentUpdate.Parameter.UIAttributes.InputFieldType? = nil,
        isPrint: Bool = false,
        order: Int? = nil,
        phoneBook: Bool = false,
        isReadOnly: Bool = false,
        subGroup: String? = nil,
        subTitle: String? = nil,
        svgImage: String? = nil,
        title: String,
        type: String,
        viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType
    ) -> AnywayPaymentUpdate.Parameter.UIAttributes {
        
        .init(
            group: group,
            inputFieldType: inputFieldType,
            isPrint: isPrint,
            order: order,
            phoneBook: phoneBook,
            isReadOnly: isReadOnly,
            subGroup: subGroup,
            subTitle: subTitle,
            svgImage: svgImage,
            title: title,
            type: type,
            viewType: viewType
        )
    }
    
    private func assert(
        _ string: String,
        mapsTo update: AnywayPaymentUpdate,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        let response = try decode(string)
        
        XCTAssertNoDiff(.init(response), update, file: file, line: line)
    }
    
    private func decode(
        _ string: String
    ) throws -> ResponseMapper.CreateAnywayTransferResponse {
        
        try ResponseMapper.mapCreateAnywayTransferResponse(
            string.json,
            anyHTTPURLResponse()
        ).get()
    }
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let validData = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": null,
        "needOTP": null,
        "amount": null,
        "creditAmount": null,
        "fee": null,
        "currencyAmount": null,
        "currencyPayer": null,
        "currencyPayee": null,
        "currencyRate": null,
        "debitAmount": null,
        "payeeName": null,
        "paymentOperationDetailId": 54321,
        "documentStatus": null,
        "needSum": false,
        "additionalList": [],
        "parameterListForNextStep": [
            {
                "id": "1",
                "order": 1,
                "title": "Лицевой счет",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": true,
                "content": null,
                "readOnly": false,
                "isPrint": true,
                "svgImage": "svgImage",
                "inputFieldType": "ACCOUNT",
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            }
        ],
        "finalStep": false,
        "infoMessage": null,
        "printFormType": null,
        "scenario": null
    }
}
"""
    
    static let validData2 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": true,
        "needOTP": true,
        "amount": null,
        "creditAmount": null,
        "fee": null,
        "currencyAmount": null,
        "currencyPayer": null,
        "currencyPayee": null,
        "currencyRate": null,
        "debitAmount": null,
        "payeeName": null,
        "paymentOperationDetailId": null,
        "documentStatus": null,
        "needSum": true,
        "additionalList": [],
        "parameterListForNextStep": [
            {
                "id": "1",
                "order": 1,
                "title": "Лицевой счет",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": true,
                "content": null,
                "readOnly": false,
                "isPrint": true,
                "svgImage": "svgImage",
                "inputFieldType": "ACCOUNT",
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            }
        ],
        "finalStep": true,
        "infoMessage": null,
        "printFormType": null,
        "scenario": "SCOR_SUSPECT_FRAUD"
    }
}
"""
    
    static let valid_sber01 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": null,
        "needOTP": null,
        "amount": null,
        "creditAmount": null,
        "fee": null,
        "currencyAmount": null,
        "currencyPayer": null,
        "currencyPayee": null,
        "currencyRate": null,
        "debitAmount": null,
        "payeeName": null,
        "paymentOperationDetailId": null,
        "documentStatus": null,
        "needSum": false,
        "additionalList": [],
        "parameterListForNextStep": [
            {
                "id": "1",
                "order": 1,
                "title": "Лицевой счет",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": true,
                "content": null,
                "readOnly": false,
                "isPrint": true,
                "svgImage": "<svg width=\\"32\\" height=\\"32\\" viewBox=\\"0 0 32 32\\" fill=\\"none\\" xmlns=\\"http://www.w3.org/2000/svg\\">\\n<path d=\\"M17.8808 6H9.99969C9.46934 6 8.96071 6.21074 8.58569 6.58586C8.21068 6.96098 8 7.46975 8 8.00025V24.0023C8 24.5327 8.21068 25.0415 8.58569 25.4166C8.96071 25.7918 9.46934 26.0025 9.99969 26.0025H21.9978C22.5282 26.0025 23.0368 25.7918 23.4118 25.4166C23.7868 25.0415 23.9975 24.5327 23.9975 24.0023V12.1184M17.8808 6L23.9975 12.1184M17.8808 6V12.1184H23.9975\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M10.9404 19.5313H15.4775M10.9404 21.2962H15.4775M12.6418 17.7664L12.0746 23.0611M14.3432 17.7664L13.7761 23.0611\\" stroke=\\"#999999\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n</svg>\\n",
                "inputFieldType": "ACCOUNT",
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            }
        ],
        "finalStep": false,
        "infoMessage": null,
        "printFormType": null,
        "scenario": null
    }
}
"""
    
    static let valid_sber02 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": null,
        "needOTP": null,
        "amount": null,
        "creditAmount": null,
        "fee": null,
        "currencyAmount": null,
        "currencyPayer": null,
        "currencyPayee": null,
        "currencyRate": null,
        "debitAmount": null,
        "payeeName": null,
        "paymentOperationDetailId": null,
        "documentStatus": null,
        "needSum": false,
        "additionalList": [],
        "parameterListForNextStep": [
            {
                "id": "2",
                "order": 2,
                "title": "Признак платежа",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "=;ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС=ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС;БЕЗ СТРАХОВОГО ВЗНОСА=БЕЗ СТРАХОВОГО ВЗНОСА;ПРОЧИЕ ПЛАТЕЖИ=ПРОЧИЕ ПЛАТЕЖИ",
                "type": "Select",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": true,
                "content": null,
                "readOnly": false,
                "isPrint": false,
                "svgImage": null,
                "inputFieldType": null,
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            }
        ],
        "finalStep": false,
        "infoMessage": null,
        "printFormType": null,
        "scenario": null
    }
}
"""
    
    static let valid_sber03 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": null,
        "needOTP": null,
        "amount": 5888.10,
        "creditAmount": null,
        "fee": null,
        "currencyAmount": null,
        "currencyPayer": null,
        "currencyPayee": null,
        "currencyRate": null,
        "debitAmount": null,
        "payeeName": null,
        "paymentOperationDetailId": null,
        "documentStatus": null,
        "needSum": true,
        "additionalList": [
            {
                "fieldName": "advisedAmount",
                "fieldValue": "5888.1",
                "fieldTitle": "Рекомендованная сумма",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            }
        ],
        "parameterListForNextStep": [
            {
                "id": "5",
                "order": 5,
                "title": "Период(ММГГГГ)",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": false,
                "content": "022024",
                "readOnly": false,
                "isPrint": true,
                "svgImage": null,
                "inputFieldType": null,
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            },
            {
                "id": "9",
                "order": 9,
                "title": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": false,
                "content": " ",
                "readOnly": false,
                "isPrint": false,
                "svgImage": null,
                "inputFieldType": null,
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            },
            {
                "id": "13",
                "order": 13,
                "title": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": false,
                "content": " ",
                "readOnly": false,
                "isPrint": false,
                "svgImage": null,
                "inputFieldType": null,
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            },
            {
                "id": "17",
                "order": 17,
                "title": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": false,
                "content": " ",
                "readOnly": false,
                "isPrint": false,
                "svgImage": null,
                "inputFieldType": null,
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            },
            {
                "id": "21",
                "order": 21,
                "title": "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": false,
                "content": " ",
                "readOnly": false,
                "isPrint": false,
                "svgImage": null,
                "inputFieldType": null,
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            },
            {
                "id": "25",
                "order": 25,
                "title": "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": false,
                "content": " ",
                "readOnly": false,
                "isPrint": false,
                "svgImage": null,
                "inputFieldType": null,
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            },
            {
                "id": "29",
                "order": 29,
                "title": "ТЕК. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
                "subTitle": null,
                "viewType": "INPUT",
                "dataType": "%String",
                "type": "Input",
                "mask": null,
                "regExp": "^.{1,250}$",
                "maxLength": null,
                "minLength": null,
                "rawLength": 0,
                "isRequired": false,
                "content": " ",
                "readOnly": false,
                "isPrint": false,
                "svgImage": "<svg width=\\"32\\" height=\\"32\\" viewBox=\\"0 0 32 32\\" fill=\\"none\\" xmlns=\\"http://www.w3.org/2000/svg\\">\\n<path d=\\"M16.2512 26.2525C21.7748 26.2525 26.2525 21.7748 26.2525 16.2512C26.2525 10.7277 21.7748 6.25 16.2512 6.25C10.7277 6.25 6.25 10.7277 6.25 16.2512C6.25 21.7748 10.7277 26.2525 16.2512 26.2525Z\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M11.4673 11.3586L9.64894 9.61293\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M21.11 11.3586L22.9285 9.61293\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M6.69214 16.2512L9.21288 16.2483\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M23.2896 16.2545L25.8103 16.2516\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2838 9.25842L16.2324 6.73821\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M18.3184 22.2816L14.1909 22.2752\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2576 12.6445L16.2576 14.7685\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.251 17.6154L16.251 18.5973\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2511 17.6151C17.0043 17.6151 17.6149 17.0045 17.6149 16.2513C17.6149 15.498 17.0043 14.8875 16.2511 14.8875C15.4979 14.8875 14.8873 15.498 14.8873 16.2513C14.8873 17.0045 15.4979 17.6151 16.2511 17.6151Z\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n</svg>\\n",
                "inputFieldType": "COUNTER",
                "dataDictionary": null,
                "dataDictionaryРarent": null,
                "group": null,
                "subGroup": null,
                "inputMask": null,
                "phoneBook": null
            }
        ],
        "finalStep": false,
        "infoMessage": null,
        "printFormType": null,
        "scenario": null
    }
}
"""
    
    static let valid_sber04 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": null,
        "needOTP": null,
        "amount": 5888.10,
        "creditAmount": null,
        "fee": null,
        "currencyAmount": null,
        "currencyPayer": null,
        "currencyPayee": null,
        "currencyRate": null,
        "debitAmount": null,
        "payeeName": null,
        "paymentOperationDetailId": null,
        "documentStatus": null,
        "needSum": true,
        "additionalList": [
            {
                "fieldName": "SumSTrs",
                "fieldValue": "5888.1",
                "fieldTitle": "Сумма",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            }
        ],
        "parameterListForNextStep": [],
        "finalStep": false,
        "infoMessage": null,
        "printFormType": null,
        "scenario": null
    }
}
"""
    
    static let valid_sber05 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needMake": null,
        "needOTP": null,
        "amount": 5888.10,
        "creditAmount": null,
        "fee": 0.00,
        "currencyAmount": "RUB",
        "currencyPayer": null,
        "currencyPayee": null,
        "currencyRate": null,
        "debitAmount": 5888.1,
        "payeeName": null,
        "paymentOperationDetailId": null,
        "documentStatus": null,
        "needSum": true,
        "additionalList": [
            {
                "fieldName": "1",
                "fieldValue": "100611401082",
                "fieldTitle": "Лицевой счет",
                "svgImage": "<svg width=\\"32\\" height=\\"32\\" viewBox=\\"0 0 32 32\\" fill=\\"none\\" xmlns=\\"http://www.w3.org/2000/svg\\">\\n<path d=\\"M17.8808 6H9.99969C9.46934 6 8.96071 6.21074 8.58569 6.58586C8.21068 6.96098 8 7.46975 8 8.00025V24.0023C8 24.5327 8.21068 25.0415 8.58569 25.4166C8.96071 25.7918 9.46934 26.0025 9.99969 26.0025H21.9978C22.5282 26.0025 23.0368 25.7918 23.4118 25.4166C23.7868 25.0415 23.9975 24.5327 23.9975 24.0023V12.1184M17.8808 6L23.9975 12.1184M17.8808 6V12.1184H23.9975\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M10.9404 19.5313H15.4775M10.9404 21.2962H15.4775M12.6418 17.7664L12.0746 23.0611M14.3432 17.7664L13.7761 23.0611\\" stroke=\\"#999999\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n</svg>\\n",
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "2",
                "fieldValue": "БЕЗ СТРАХОВОГО ВЗНОСА",
                "fieldTitle": "Признак платежа",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "4",
                "fieldValue": "МОСКВА,АМУРСКАЯ УЛ.,2А К2,108",
                "fieldTitle": "Адрес",
                "svgImage": "<svg width=\\"32\\" height=\\"32\\" viewBox=\\"0 0 32 32\\" fill=\\"none\\" xmlns=\\"http://www.w3.org/2000/svg\\">\\n<path d=\\"M25 14C25 21 16 27 16 27C16 27 7 21 7 14C7 11.6131 7.94821 9.32387 9.63604 7.63604C11.3239 5.94821 13.6131 5 16 5C18.3869 5 20.6761 5.94821 22.364 7.63604C24.0518 9.32387 25 11.6131 25 14Z\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16 17C17.6569 17 19 15.6569 19 14C19 12.3431 17.6569 11 16 11C14.3431 11 13 12.3431 13 14C13 15.6569 14.3431 17 16 17Z\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n</svg>\\n",
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "5",
                "fieldValue": "022024",
                "fieldTitle": "Период(ММГГГГ)",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "8",
                "fieldValue": "206.750",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "9",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "12",
                "fieldValue": "366.260",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "13",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "16",
                "fieldValue": "259.990",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "17",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "20",
                "fieldValue": "27.495",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ХВС №1012018234307",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "21",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "24",
                "fieldValue": "39.647",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ХВ_ГВС №1012018015708",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "25",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "28",
                "fieldValue": "2.609",
                "fieldTitle": "ПРЕД. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
                "svgImage": "<svg width=\\"32\\" height=\\"32\\" viewBox=\\"0 0 32 32\\" fill=\\"none\\" xmlns=\\"http://www.w3.org/2000/svg\\">\\n<path d=\\"M16.2512 26.2525C21.7748 26.2525 26.2525 21.7748 26.2525 16.2512C26.2525 10.7277 21.7748 6.25 16.2512 6.25C10.7277 6.25 6.25 10.7277 6.25 16.2512C6.25 21.7748 10.7277 26.2525 16.2512 26.2525Z\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M11.4673 11.3586L9.64894 9.61293\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M21.11 11.3586L22.9285 9.61293\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M6.69214 16.2512L9.21288 16.2483\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M23.2896 16.2545L25.8103 16.2516\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2838 9.25842L16.2324 6.73821\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M18.3184 22.2816L14.1909 22.2752\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2576 12.6445L16.2576 14.7685\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.251 17.6154L16.251 18.5973\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2511 17.6151C17.0043 17.6151 17.6149 17.0045 17.6149 16.2513C17.6149 15.498 17.0043 14.8875 16.2511 14.8875C15.4979 14.8875 14.8873 15.498 14.8873 16.2513C14.8873 17.0045 15.4979 17.6151 16.2511 17.6151Z\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n</svg>\\n",
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "29",
                "fieldValue": " ",
                "fieldTitle": "ТЕК. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
                "svgImage": "<svg width=\\"32\\" height=\\"32\\" viewBox=\\"0 0 32 32\\" fill=\\"none\\" xmlns=\\"http://www.w3.org/2000/svg\\">\\n<path d=\\"M16.2512 26.2525C21.7748 26.2525 26.2525 21.7748 26.2525 16.2512C26.2525 10.7277 21.7748 6.25 16.2512 6.25C10.7277 6.25 6.25 10.7277 6.25 16.2512C6.25 21.7748 10.7277 26.2525 16.2512 26.2525Z\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M11.4673 11.3586L9.64894 9.61293\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M21.11 11.3586L22.9285 9.61293\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M6.69214 16.2512L9.21288 16.2483\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M23.2896 16.2545L25.8103 16.2516\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2838 9.25842L16.2324 6.73821\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M18.3184 22.2816L14.1909 22.2752\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2576 12.6445L16.2576 14.7685\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.251 17.6154L16.251 18.5973\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2511 17.6151C17.0043 17.6151 17.6149 17.0045 17.6149 16.2513C17.6149 15.498 17.0043 14.8875 16.2511 14.8875C15.4979 14.8875 14.8873 15.498 14.8873 16.2513C14.8873 17.0045 15.4979 17.6151 16.2511 17.6151Z\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n</svg>\\n",
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "65",
                "fieldValue": "5888.10",
                "fieldTitle": "УСЛУГИ_ЖКУ",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "142",
                "fieldValue": "0.00",
                "fieldTitle": "Сумма страховки",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "143",
                "fieldValue": "0.00",
                "fieldTitle": "Сумма пени",
                "svgImage": "<svg width=\\"32\\" height=\\"32\\" viewBox=\\"0 0 32 32\\" fill=\\"none\\" xmlns=\\"http://www.w3.org/2000/svg\\">\\n<path d=\\"M19.673 9.95C19.0815 9.95 18.508 10.0259 17.962 10.1674C17.4158 10.0259 16.8424 9.95 16.2509 9.95C15.6595 9.95 15.086 10.0259 14.5399 10.1674C13.9938 10.0259 13.4203 9.95 12.8289 9.95C9.17491 9.95 6.19963 12.8301 6.19963 16.3735C6.19963 19.917 9.17491 22.7971 12.8288 22.7971C13.4203 22.7971 13.9937 22.7212 14.5398 22.5797C15.0859 22.7212 15.6594 22.7971 16.2508 22.7971C16.8423 22.7971 17.4158 22.7212 17.9619 22.5797C18.508 22.7212 19.0815 22.7971 19.6729 22.7971C23.3269 22.7971 26.3021 19.917 26.3021 16.3735C26.3021 12.8301 23.3269 9.95 19.673 9.95ZM12.8288 21.5617C9.87342 21.5617 7.47166 19.2328 7.47166 16.3735C7.47166 13.5143 9.87338 11.1854 12.8288 11.1854C15.7842 11.1854 18.1859 13.5143 18.1859 16.3735C18.1859 19.2328 15.7842 21.5617 12.8288 21.5617ZM21.608 16.3735C21.608 19.0644 19.4808 21.2851 16.7668 21.5374C18.3978 20.3666 19.458 18.4882 19.458 16.3735C19.458 14.2589 18.3978 12.3805 16.7668 11.2096C19.4808 11.4619 21.608 13.6827 21.608 16.3735ZM25.0301 16.3735C25.0301 19.0644 22.9029 21.2851 20.1889 21.5374C21.8199 20.3666 22.88 18.4882 22.88 16.3735C22.88 14.2589 21.8199 12.3805 20.1889 11.2097C22.9029 11.462 25.0301 13.6827 25.0301 16.3735Z\\" fill=\\"#999999\\" stroke=\\"#999999\\" stroke-width=\\"0.1\\"/>\\n</svg>\\n",
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "147",
                "fieldValue": "04",
                "fieldTitle": "Код филиала",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            },
            {
                "fieldName": "advisedAmount",
                "fieldValue": "5888.1",
                "fieldTitle": "Рекомендованная сумма",
                "svgImage": null,
                "recycle": null,
                "typeIdParameterList": null
            }
        ],
        "parameterListForNextStep": [],
        "finalStep": true,
        "infoMessage": null,
        "printFormType": null,
        "scenario": "OK"
    }
}
"""
}
