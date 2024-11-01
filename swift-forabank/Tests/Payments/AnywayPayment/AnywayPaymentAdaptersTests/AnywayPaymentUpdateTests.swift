//
//  AnywayPaymentUpdateTests.swift
//
//
//  Created by Igor Malyarov on 02.04.2024.
//

import AnywayPaymentAdapters
import AnywayPaymentCore
import AnywayPaymentDomain
import RemoteServices
import XCTest

final class AnywayPaymentUpdateTests: XCTestCase {
    
    func test_init_shouldFailOnFinalStepTrueNeedMakeFalse() throws {
        
        try XCTAssertNil(makeUpdate(from: .makeResponse(
            finalStep: true,
            needMake: false
        )))
    }
    
    func test_init_shouldFailOnFinalStepTrueNeedMakeNil() throws {
        
        try XCTAssertNil(makeUpdate(from: .makeResponse(
            finalStep: true,
            needMake: nil
        )))
    }
    
    func test_init_shouldFailOnFinalStepFalseNeedMakeTrue() throws {
        
        try XCTAssertNil(makeUpdate(from: .makeResponse(
            finalStep: false,
            needMake: true
        )))
    }
    
    func test_init_shouldFailOnFinalStepNilNeedMakeTrue() throws {
        
        try XCTAssertNil(makeUpdate(from: .makeResponse(
            finalStep: nil,
            needMake: true
        )))
    }
    
    func test_init_shouldTrimWhitespaces() {
        
        let response = makeResponse(
            params: [
                makeResponseParameter(content: " "),
                makeResponseParameter(content: "  "),
                makeResponseParameter(content: " a"),
                makeResponseParameter(content: "a "),
                makeResponseParameter(content: " a "),
                makeResponseParameter(content: "  a  "),
            ])
        let update = AnywayPaymentUpdate(response)
        
        XCTAssertNoDiff(update?.parameters.map(\.field.content), ["", "", "a", "a", "a", "a"])
    }
    
#warning("move below to Helperrs")
    
    func test_init_validData() throws {
        
        try assert(.validData, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(),
                control: makeDetailsControl(),
                info: makeDetailsInfo(
                    paymentOperationDetailID: 54321
                )
            ),
            fields: [
                makeField(
                    name: "3",
                    value: "Москва г., Донская ул., д.112 корп.211, кв.111",
                    title: "Адрес",
                    icon: .md5Hash("87f2fad4a6997e1d3ae634c551c50f14")
                ),
                makeField(
                    name: "n1",
                    value: "v1",
                    title: "t1"
                ),
                makeField(
                    name: "n2",
                    value: "v2",
                    title: "t2",
                    icon: .md5Hash("md5hash2")
                ),
                makeField(
                    name: "n3",
                    value: "v3",
                    title: "t3",
                    icon: .svg("svgImage3")
                ),
                makeField(
                    name: "n4",
                    value: "v4",
                    title: "t4",
                    icon: .withFallback(md5Hash: "md5hash4", svg: "svgImage4")
                ),
            ],
            parameters: [
                .init(
                    field: makeParameterField(id: "1"),
                    icon: .svg("svgImage"),
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(),
                    uiAttributes: makeParameterUIAttributes(
                        inputFieldType: .account,
                        isPrint: true,
                        order: 1,
                        title: "Лицевой счет",
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
                    needOTP: true,
                    needSum: true
                ),
                info: makeDetailsInfo()
            ),
            fields: [],
            parameters: [
                .init(
                    field: makeParameterField(id: "1"),
                    icon: .svg("svgImage"),
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(),
                    uiAttributes: makeParameterUIAttributes(
                        inputFieldType: .account,
                        isPrint: true,
                        order: 1,
                        title: "Лицевой счет",
                        viewType: .input
                    )
                )
            ]
        ))
    }
    
    func test_init_shouldNotMapInvisible_e1_sample_step1() throws {
        
        try assert(.e1_sample_step1, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(),
                control: makeDetailsControl(),
                info: makeDetailsInfo()
            ),
            fields: [],
            parameters: [
                .init(
                    field: makeParameterField(id: "1"),
                    icon: .md5Hash("6e17f502dae62b03d8bd4770606ee4b2"),
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(),
                    uiAttributes: makeParameterUIAttributes(
                        dataType: .numeric,
                        inputFieldType: .account,
                        isPrint: false,
                        title: "Лицевой счет",
                        viewType: .input
                    )
                )
            ]
        ))
    }
    
    func test_init_valid_sber01() throws {
        
        try assert(.valid_sber01, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(),
                control: makeDetailsControl(),
                info: makeDetailsInfo()
            ),
            fields: [],
            parameters: [
                .init(
                    field: makeParameterField(id: "1"),
                    icon: .svg(.svgSample6),
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(),
                    uiAttributes: makeParameterUIAttributes(
                        inputFieldType: .account,
                        isPrint: true,
                        order: 1,
                        title: "Лицевой счет",
                        viewType: .input
                    )
                )
            ]
        ))
    }
    
    func test_init_valid_sber02() throws {
        
        try assert(.valid_sber02, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(),
                control: makeDetailsControl(),
                info: makeDetailsInfo()
            ),
            fields: [],
            parameters: [
                .init(
                    field: makeParameterField(id: "2"),
                    icon: nil,
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        rawLength: 0,
                        regExp:  "^.{1,250}$"
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        dataType: .pairs(
                            nil, [
                                .init(
                                    key: "ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС",
                                    value: "ВКЛЮЧАЯ СТРАХОВОЙ ВЗНОС"
                                ),
                                .init(
                                    key: "БЕЗ СТРАХОВОГО ВЗНОСА",
                                    value: "БЕЗ СТРАХОВОГО ВЗНОСА"
                                ),
                                .init(
                                    key: "ПРОЧИЕ ПЛАТЕЖИ",
                                    value: "ПРОЧИЕ ПЛАТЕЖИ"
                                ),
                            ]),
                        order: 2,
                        title: "Признак платежа",
                        type: .select,
                        viewType: .input
                    )
                )
            ]
        ))
    }
    
    func test_init_valid_sber03() throws {
        
        try assert(.valid_sber03, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(
                    amount: 5_888.1
                ),
                control: makeDetailsControl(
                    isFinalStep: false,
                    isFraudSuspected: false,
                    needOTP: false,
                    needSum: true
                ),
                info: makeDetailsInfo()
            ),
            fields: [
                makeField(
                    name: "advisedAmount",
                    value: "5888.1",
                    title: "Рекомендованная сумма"
                )
            ],
            parameters: [
                .init(
                    field: makeParameterField(
                        content: "022024",
                        id: "5"
                    ),
                    icon: nil,
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        isRequired: false
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        isPrint: true,
                        order: 5,
                        title: "Период(ММГГГГ)",
                        viewType: .input
                    )
                ),
                .init(
                    field: makeParameterField(
                        content: "",
                        id: "9"
                    ),
                    icon: nil,
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        isRequired: false
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        order: 9,
                        title: "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504",
                        viewType: .input
                    )
                ),
                .init(
                    field: makeParameterField(
                        content: "",
                        id: "13"
                    ),
                    icon: nil,
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        isRequired: false
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        order: 13,
                        title: "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504",
                        viewType: .input
                    )
                ),
                .init(
                    field: makeParameterField(
                        content: "",
                        id: "17"
                    ),
                    icon: nil,
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        isRequired: false
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        order: 17,
                        title: "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504",
                        viewType: .input
                    )
                ),
                .init(
                    field: makeParameterField(
                        content: "",
                        id: "21"
                    ),
                    icon: nil,
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        isRequired: false
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        order: 21,
                        title: "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307",
                        viewType: .input
                    )
                ),
                .init(
                    field: makeParameterField(
                        content: "",
                        id: "25"
                    ),
                    icon: nil,
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        isRequired: false
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        order: 25,
                        title: "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708",
                        viewType: .input
                    )
                ),
                .init(
                    field: makeParameterField(
                        content: "",
                        id: "29"
                    ),
                    icon: .svg(.svgSample7),
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        isRequired: false
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        inputFieldType: .counter,
                        order: 29,
                        title: "ТЕК. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
                        viewType: .input
                    )
                ),
            ]
        ))
    }
    
    func test_init_valid_sber04() throws {
        
        try assert(.valid_sber04, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(
                    amount: 5_888.1
                ),
                control: makeDetailsControl(
                    isFinalStep: false,
                    isFraudSuspected: false,
                    needOTP: false,
                    needSum: true
                ),
                info: makeDetailsInfo()
            ),
            fields: [
                makeField(
                    name: "SumSTrs",
                    value: "5888.1",
                    title: "Сумма"
                )
            ],
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
                    needOTP: false,
                    needSum: true
                ),
                info: makeDetailsInfo()
            ),
            fields: [
                makeField(
                    name: "1",
                    value: "100611401082",
                    title: "Лицевой счет",
                    icon: .svg(.svgSample1)
                ),
                makeField(
                    name: "2",
                    value: "БЕЗ СТРАХОВОГО ВЗНОСА",
                    title: "Признак платежа"
                ),
                makeField(
                    name: "4",
                    value: "МОСКВА,АМУРСКАЯ УЛ.,2А К2,108",
                    title: "Адрес",
                    icon: .svg(.svgSample2)
                ),
                makeField(
                    name: "5",
                    value: "022024",
                    title: "Период(ММГГГГ)"
                ),
                makeField(
                    name: "8",
                    value: "206.750",
                    title: "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"
                ),
                makeField(
                    name: "9",
                    value: " ",
                    title: "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"
                ),
                makeField(
                    name: "12",
                    value: "366.260",
                    title: "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"
                ),
                makeField(
                    name: "13",
                    value: " ",
                    title: "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504"
                ),
                makeField(
                    name: "16",
                    value: "259.990",
                    title: "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"
                ),
                makeField(
                    name: "17",
                    value: " ",
                    title: "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504"
                ),
                makeField(
                    name: "20",
                    value: "27.495",
                    title: "ПРЕД. ПОКАЗАНИЯ ХВС №1012018234307"
                ),
                makeField(
                    name: "21",
                    value: " ",
                    title: "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307"
                ),
                makeField(
                    name: "24",
                    value: "39.647",
                    title: "ПРЕД. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"
                ),
                makeField(
                    name: "25",
                    value: " ",
                    title: "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708"
                ),
                makeField(
                    name: "28",
                    value: "2.609",
                    title: "ПРЕД. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
                    icon: .svg(.svgSample3)
                ),
                makeField(
                    name: "29",
                    value: " ",
                    title: "ТЕК. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
                    icon: .svg(.svgSample4)
                ),
                makeField(
                    name: "65",
                    value: "5888.10",
                    title: "УСЛУГИ_ЖКУ"
                ),
                makeField(
                    name: "142",
                    value: "0.00",
                    title: "Сумма страховки"
                ),
                makeField(
                    name: "143",
                    value: "0.00",
                    title: "Сумма пени",
                    icon: .svg(.svgSample5)
                ),
                makeField(
                    name: "147",
                    value: "04",
                    title: "Код филиала"
                ),
                makeField(
                    name: "advisedAmount",
                    value: "5888.1",
                    title: "Рекомендованная сумма"
                ),
            ],
            parameters: []
        ))
    }
    
    func test_init_withSumSTrs() throws {
        
        try assert(.withSumSTrs, mapsTo: .init(
            details: .init(
                amounts: makeDetailsAmounts(amount: 4273.87),
                control: makeDetailsControl(needSum: true),
                info: makeDetailsInfo()
            ),
            fields: [
                makeField(name: "SumSTrs", value: "4273.87", title: "Сумма")
            ],
            parameters: []
        ))
    }
    
    func test_init_selectorConstant() throws {
        
        try assert(.selectorConstant, mapsTo: makeUpdate(
            parameters: [
                .init(
                    field: makeParameterField(id: "1"),
                    icon: nil,
                    masking: makeParameterMasking(),
                    validation: makeParameterValidation(
                        isRequired: false,
                        regExp: ""
                    ),
                    uiAttributes: makeParameterUIAttributes(
                        dataType: .pairs(
                            nil,
                            [.init(key: "ПАСПОРТ РФ", value: "ПАСПОРТ РФ"),
                             .init(key: "СВИД О РОЖДЕНИИ", value: "СВИД О РОЖДЕНИИ")]
                        ),
                        title: "Селектор c viewType = CONSTANT",
                        type: .select,
                        viewType: .constant
                    )
                )
            ]
        ))
    }
    
    // MARK: - Helpers
    
    private func makeUpdate(
        details: AnywayPaymentUpdate.Details? = nil,
        fields: [AnywayPaymentUpdate.Field] = [],
        parameters: [AnywayPaymentUpdate.Parameter] = []
    ) -> AnywayPaymentUpdate {
        
        return .init(
            details: details ?? .init(
                amounts: makeDetailsAmounts(),
                control: makeDetailsControl(),
                info: makeDetailsInfo()
            ),
            fields: fields,
            parameters: parameters
        )
    }
    
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
        
        return .init(
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
        isFinalStep: Bool = false,
        isFraudSuspected: Bool = false,
        isMultiSum: Bool = false,
        needOTP: Bool = false,
        needSum: Bool = false
    ) -> AnywayPaymentUpdate.Details.Control {
        
        return .init(
            isFinalStep: isFinalStep,
            isFraudSuspected: isFraudSuspected,
            isMultiSum: isMultiSum,
            needOTP: needOTP,
            needSum: needSum
        )
    }
    
    private func makeDetailsInfo(
        documentStatus: AnywayPaymentUpdate.Details.Info.DocumentStatus? = nil,
        infoMessage: String? = nil,
        payeeName: String? = nil,
        paymentOperationDetailID: Int? = nil,
        printFormType: String? = nil
    ) -> AnywayPaymentUpdate.Details.Info {
        
        return .init(
            documentStatus: documentStatus,
            infoMessage: infoMessage,
            payeeName: payeeName,
            paymentOperationDetailID: paymentOperationDetailID,
            printFormType: printFormType
        )
    }
    
    private func makeField(
        name: String,
        value: String,
        title: String,
        icon: AnywayPaymentUpdate.Icon? = nil
    ) -> AnywayPaymentUpdate.Field {
        
        return .init(
            name: name,
            value: value,
            title: title,
            icon: icon
        )
    }
    
    private func makeParameterField(
        content: String? = nil,
        dataDictionary: String? = nil,
        dataDictionaryРarent: String? = nil,
        id: String
    ) -> AnywayPaymentUpdate.Parameter.Field {
        
        return .init(
            content: content,
            dataDictionary: dataDictionary,
            dataDictionaryРarent: dataDictionaryРarent,
            id: id
        )
    }
    
    private func makeParameterMasking(
        inputMask: String? = nil,
        mask: String? = nil
    ) -> AnywayPaymentUpdate.Parameter.Masking {
        
        .init(inputMask: inputMask, mask: mask)
    }
    
    private func makeParameterValidation(
        isRequired: Bool = true,
        maxLength: Int? = nil,
        minLength: Int? = nil,
        rawLength: Int = 0,
        regExp: String = "^.{1,250}$"
    ) -> AnywayPaymentUpdate.Parameter.Validation {
        
        return .init(
            isRequired: isRequired,
            maxLength: maxLength,
            minLength: minLength,
            rawLength: rawLength,
            regExp: regExp
        )
    }
    
    private func makeParameterUIAttributes(
        dataType: AnywayPaymentUpdate.Parameter.UIAttributes.DataType = .string,
        group: String? = nil,
        inputFieldType: AnywayPaymentUpdate.Parameter.UIAttributes.InputFieldType? = nil,
        isPrint: Bool = false,
        order: Int? = nil,
        phoneBook: Bool = false,
        isReadOnly: Bool = false,
        subGroup: String? = nil,
        subTitle: String? = nil,
        title: String,
        type: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType = .input,
        viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType
    ) -> AnywayPaymentUpdate.Parameter.UIAttributes {
        
        return .init(
            dataType: dataType,
            group: group,
            inputFieldType: inputFieldType,
            isPrint: isPrint,
            order: order,
            phoneBook: phoneBook,
            isReadOnly: isReadOnly,
            subGroup: subGroup,
            subTitle: subTitle,
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
        
        try XCTAssertNoDiff(
            makeUpdate(from: string, file: file, line: line),
            update,
            file: file, line: line
        )
    }
    
    private func makeUpdate(
        from string: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> AnywayPaymentUpdate? {
        
        do {
            let response = try map(string)
            return .init(response)
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
            throw error
        }
    }
    
    private func map(
        _ string: String
    ) throws -> ResponseMapper.CreateAnywayTransferResponse {
        
        try ResponseMapper.mapCreateAnywayTransferResponse(
            string.json,
            anyHTTPURLResponse()
        ).get()
    }
    
    private func makeResponse(
        params: [ResponseMapper.CreateAnywayTransferResponse.Parameter]
    ) -> ResponseMapper.CreateAnywayTransferResponse {
        
        return .init(
            additional: [],
            finalStep: false,
            needMake: false,
            needOTP: false,
            needSum: false,
            parametersForNextStep: params,
            options: []
        )
    }
    
    private func makeResponseParameter(
        content: String?
    ) -> ResponseMapper.CreateAnywayTransferResponse.Parameter {
        
        return .init(
            content: content,
            dataType: .number,
            id: UUID().uuidString,
            inputFieldType: .none,
            isPrint: true,
            isRequired: true,
            phoneBook: false,
            rawLength: 0,
            isReadOnly: false,
            regExp: "",
            md5hash: nil,
            svgImage: nil,
            title: "title",
            type: .input,
            viewType: .input,
            visible: true
        )
    }
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static func makeResponse(
        finalStep: Bool?,
        needMake: Bool?
    ) -> String {
        
"""
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "amount": 4273.87,
        "finalStep": \(finalStep?.description ?? "null"),
        "needMake": \(needMake?.description ?? "null"),
        "parameterListForNextStep": []
    }
}
"""
    }
    
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
        "additionalList": [
            {
                "fieldName": "3",
                "fieldValue": "Москва г., Донская ул., д.112 корп.211, кв.111",
                "fieldTitle": "Адрес",
                "md5hash": "87f2fad4a6997e1d3ae634c551c50f14"
            },
            {
                "fieldName": "n1",
                "fieldValue": "v1",
                "fieldTitle": "t1"
            },
            {
                "fieldName": "n2",
                "fieldValue": "v2",
                "fieldTitle": "t2",
                "md5hash": "md5hash2"
            },
            {
                "fieldName": "n3",
                "fieldValue": "v3",
                "fieldTitle": "t3",
                "svgImage": "svgImage3"
            },
            {
                "fieldName": "n4",
                "fieldValue": "v4",
                "fieldTitle": "t4",
                "md5hash": "md5hash4",
                "svgImage": "svgImage4"
            }
        ],
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
    
    static let e1_sample_step1 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "additionalList": [],
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
        "needMake": true,
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
    
    static let svgSample = """
"<svg width=\\"32\\" height=\\"32\\" viewBox=\\"0 0 32 32\\" fill=\\"none\\" xmlns=\\"http://www.w3.org/2000/svg\\">\\n<path d=\\"M16.2512 26.2525C21.7748 26.2525 26.2525 21.7748 26.2525 16.2512C26.2525 10.7277 21.7748 6.25 16.2512 6.25C10.7277 6.25 6.25 10.7277 6.25 16.2512C6.25 21.7748 10.7277 26.2525 16.2512 26.2525Z\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M11.4673 11.3586L9.64894 9.61293\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M21.11 11.3586L22.9285 9.61293\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M6.69214 16.2512L9.21288 16.2483\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M23.2896 16.2545L25.8103 16.2516\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2838 9.25842L16.2324 6.73821\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M18.3184 22.2816L14.1909 22.2752\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2576 12.6445L16.2576 14.7685\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.251 17.6154L16.251 18.5973\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n<path d=\\"M16.2511 17.6151C17.0043 17.6151 17.6149 17.0045 17.6149 16.2513C17.6149 15.498 17.0043 14.8875 16.2511 14.8875C15.4979 14.8875 14.8873 15.498 14.8873 16.2513C14.8873 17.0045 15.4979 17.6151 16.2511 17.6151Z\\" stroke=\\"#999999\\" stroke-width=\\"1.25\\" stroke-linecap=\\"round\\" stroke-linejoin=\\"round\\"/>\\n</svg>\\n"
"""
    
    static let svgSample1 = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M17.8808 6H9.99969C9.46934 6 8.96071 6.21074 8.58569 6.58586C8.21068 6.96098 8 7.46975 8 8.00025V24.0023C8 24.5327 8.21068 25.0415 8.58569 25.4166C8.96071 25.7918 9.46934 26.0025 9.99969 26.0025H21.9978C22.5282 26.0025 23.0368 25.7918 23.4118 25.4166C23.7868 25.0415 23.9975 24.5327 23.9975 24.0023V12.1184M17.8808 6L23.9975 12.1184M17.8808 6V12.1184H23.9975" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M10.9404 19.5313H15.4775M10.9404 21.2962H15.4775M12.6418 17.7664L12.0746 23.0611M14.3432 17.7664L13.7761 23.0611" stroke="#999999" stroke-linecap="round" stroke-linejoin="round"/>
</svg>

"""
    
    static let svgSample2 = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M25 14C25 21 16 27 16 27C16 27 7 21 7 14C7 11.6131 7.94821 9.32387 9.63604 7.63604C11.3239 5.94821 13.6131 5 16 5C18.3869 5 20.6761 5.94821 22.364 7.63604C24.0518 9.32387 25 11.6131 25 14Z" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16 17C17.6569 17 19 15.6569 19 14C19 12.3431 17.6569 11 16 11C14.3431 11 13 12.3431 13 14C13 15.6569 14.3431 17 16 17Z" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
</svg>

"""
    
    static let svgSample3 = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M16.2512 26.2525C21.7748 26.2525 26.2525 21.7748 26.2525 16.2512C26.2525 10.7277 21.7748 6.25 16.2512 6.25C10.7277 6.25 6.25 10.7277 6.25 16.2512C6.25 21.7748 10.7277 26.2525 16.2512 26.2525Z" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M11.4673 11.3586L9.64894 9.61293" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M21.11 11.3586L22.9285 9.61293" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M6.69214 16.2512L9.21288 16.2483" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M23.2896 16.2545L25.8103 16.2516" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.2838 9.25842L16.2324 6.73821" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M18.3184 22.2816L14.1909 22.2752" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.2576 12.6445L16.2576 14.7685" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.251 17.6154L16.251 18.5973" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.2511 17.6151C17.0043 17.6151 17.6149 17.0045 17.6149 16.2513C17.6149 15.498 17.0043 14.8875 16.2511 14.8875C15.4979 14.8875 14.8873 15.498 14.8873 16.2513C14.8873 17.0045 15.4979 17.6151 16.2511 17.6151Z" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
</svg>

"""
    
    static let svgSample4 = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M16.2512 26.2525C21.7748 26.2525 26.2525 21.7748 26.2525 16.2512C26.2525 10.7277 21.7748 6.25 16.2512 6.25C10.7277 6.25 6.25 10.7277 6.25 16.2512C6.25 21.7748 10.7277 26.2525 16.2512 26.2525Z" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M11.4673 11.3586L9.64894 9.61293" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M21.11 11.3586L22.9285 9.61293" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M6.69214 16.2512L9.21288 16.2483" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M23.2896 16.2545L25.8103 16.2516" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.2838 9.25842L16.2324 6.73821" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M18.3184 22.2816L14.1909 22.2752" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.2576 12.6445L16.2576 14.7685" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.251 17.6154L16.251 18.5973" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.2511 17.6151C17.0043 17.6151 17.6149 17.0045 17.6149 16.2513C17.6149 15.498 17.0043 14.8875 16.2511 14.8875C15.4979 14.8875 14.8873 15.498 14.8873 16.2513C14.8873 17.0045 15.4979 17.6151 16.2511 17.6151Z" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
</svg>

"""
    static let svgSample5 = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M19.673 9.95C19.0815 9.95 18.508 10.0259 17.962 10.1674C17.4158 10.0259 16.8424 9.95 16.2509 9.95C15.6595 9.95 15.086 10.0259 14.5399 10.1674C13.9938 10.0259 13.4203 9.95 12.8289 9.95C9.17491 9.95 6.19963 12.8301 6.19963 16.3735C6.19963 19.917 9.17491 22.7971 12.8288 22.7971C13.4203 22.7971 13.9937 22.7212 14.5398 22.5797C15.0859 22.7212 15.6594 22.7971 16.2508 22.7971C16.8423 22.7971 17.4158 22.7212 17.9619 22.5797C18.508 22.7212 19.0815 22.7971 19.6729 22.7971C23.3269 22.7971 26.3021 19.917 26.3021 16.3735C26.3021 12.8301 23.3269 9.95 19.673 9.95ZM12.8288 21.5617C9.87342 21.5617 7.47166 19.2328 7.47166 16.3735C7.47166 13.5143 9.87338 11.1854 12.8288 11.1854C15.7842 11.1854 18.1859 13.5143 18.1859 16.3735C18.1859 19.2328 15.7842 21.5617 12.8288 21.5617ZM21.608 16.3735C21.608 19.0644 19.4808 21.2851 16.7668 21.5374C18.3978 20.3666 19.458 18.4882 19.458 16.3735C19.458 14.2589 18.3978 12.3805 16.7668 11.2096C19.4808 11.4619 21.608 13.6827 21.608 16.3735ZM25.0301 16.3735C25.0301 19.0644 22.9029 21.2851 20.1889 21.5374C21.8199 20.3666 22.88 18.4882 22.88 16.3735C22.88 14.2589 21.8199 12.3805 20.1889 11.2097C22.9029 11.462 25.0301 13.6827 25.0301 16.3735Z" fill="#999999" stroke="#999999" stroke-width="0.1"/>
</svg>

"""
    
    static let svgSample6 = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M17.8808 6H9.99969C9.46934 6 8.96071 6.21074 8.58569 6.58586C8.21068 6.96098 8 7.46975 8 8.00025V24.0023C8 24.5327 8.21068 25.0415 8.58569 25.4166C8.96071 25.7918 9.46934 26.0025 9.99969 26.0025H21.9978C22.5282 26.0025 23.0368 25.7918 23.4118 25.4166C23.7868 25.0415 23.9975 24.5327 23.9975 24.0023V12.1184M17.8808 6L23.9975 12.1184M17.8808 6V12.1184H23.9975" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M10.9404 19.5313H15.4775M10.9404 21.2962H15.4775M12.6418 17.7664L12.0746 23.0611M14.3432 17.7664L13.7761 23.0611" stroke="#999999" stroke-linecap="round" stroke-linejoin="round"/>
</svg>

"""
    
    static let svgSample7 = """
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M16.2512 26.2525C21.7748 26.2525 26.2525 21.7748 26.2525 16.2512C26.2525 10.7277 21.7748 6.25 16.2512 6.25C10.7277 6.25 6.25 10.7277 6.25 16.2512C6.25 21.7748 10.7277 26.2525 16.2512 26.2525Z" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M11.4673 11.3586L9.64894 9.61293" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M21.11 11.3586L22.9285 9.61293" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M6.69214 16.2512L9.21288 16.2483" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M23.2896 16.2545L25.8103 16.2516" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.2838 9.25842L16.2324 6.73821" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M18.3184 22.2816L14.1909 22.2752" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.2576 12.6445L16.2576 14.7685" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.251 17.6154L16.251 18.5973" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
<path d="M16.2511 17.6151C17.0043 17.6151 17.6149 17.0045 17.6149 16.2513C17.6149 15.498 17.0043 14.8875 16.2511 14.8875C15.4979 14.8875 14.8873 15.498 14.8873 16.2513C14.8873 17.0045 15.4979 17.6151 16.2511 17.6151Z" stroke="#999999" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round"/>
</svg>

"""
    
    static let withSumSTrs = """
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
    
    static let selectorConstant = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "parameterListForNextStep": [
      {
        "id": "1",
        "title": "Селектор c viewType = CONSTANT",
        "viewType": "CONSTANT",
        "dataType": "=;ПАСПОРТ РФ=ПАСПОРТ РФ;СВИД О РОЖДЕНИИ=СВИД О РОЖДЕНИИ",
        "type": "Select",
        "isRequired": false,
        "readOnly": false,
        "visible": true
      },
      {
        "id": "##ID##",
        "viewType": "OUTPUT",
        "content": "7e2fbb3f-680b-484e-97be-31a1cd03b74e",
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
