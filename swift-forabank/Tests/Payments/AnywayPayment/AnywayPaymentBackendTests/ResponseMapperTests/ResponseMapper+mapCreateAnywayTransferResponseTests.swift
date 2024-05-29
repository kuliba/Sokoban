//
//  ResponseMapper+mapCreateAnywayTransferResponseTests.swift
//
//
//  Created by Igor Malyarov on 25.03.2024.
//

import AnywayPaymentBackend
import RemoteServices
import XCTest

final class ResponseMapper_mapCreateAnywayTransferResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidFailureOnEmptyData() {
        
        let emptyData: Data = .empty
        
        XCTAssertNoDiff(
            map(emptyData),
            .failure(.invalid(statusCode: 200, data: emptyData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnInvalidData() {
        
        let invalidData: Data = .invalidData
        
        XCTAssertNoDiff(
            map(invalidData),
            .failure(.invalid(statusCode: 200, data: invalidData))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyJSON() {
        
        let emptyJSON: Data = .emptyJSON
        
        XCTAssertNoDiff(
            map(emptyJSON),
            .failure(.invalid(statusCode: 200, data: emptyJSON))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnEmptyDataResponse() {
        
        let emptyDataResponse: Data = .emptyDataResponse
        
        XCTAssertNoDiff(
            map(emptyDataResponse),
            .failure(.invalid(statusCode: 200, data: emptyDataResponse))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNullServerResponse() {
        
        let nullServerResponse: Data = .nullServerResponse
        
        XCTAssertNoDiff(
            map(.nullServerResponse),
            .failure(.invalid(statusCode: 200, data: nullServerResponse))
        )
    }
    
    func test_map_shouldDeliverServerErrorOnServerError() {
        
        XCTAssertNoDiff(
            map(.serverError),
            .failure(.server(
                statusCode: 102,
                errorMessage: "Возникла техническая ошибка"
            ))
        )
    }
    
    func test_map_shouldDeliverInvalidFailureOnNonOkHTTPResponse() {
        
        for statusCode in [199, 201, 399, 400, 401, 404] {
            
            let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
            
            XCTAssertNoDiff(
                map(.validData, nonOkResponse),
                .failure(.invalid(statusCode: statusCode, data: .validData))
            )
        }
    }
    
    func test_map_shouldDeliverResponse() throws {
        
        try assert(.validData, .init(
            additional: [],
            finalStep: false,
            needMake: false,
            needOTP: false,
            needSum: false,
            parametersForNextStep: [
                makeParameter(
                    dataType: .string,
                    id: "1",
                    inputFieldType: .account,
                    order: 1,
                    regExp: "^.{1,250}$",
                    svgImage: "svgImage",
                    title: "Лицевой счет",
                    type: .input,
                    viewType: .input
                )
            ],
            paymentOperationDetailID: 54321
        ))
    }
    
    func test_map_shouldNotThrowOnRealLifeData() throws {
        
        for string in [String.valid_sber01, .valid_sber02, .valid_sber03, .valid_sber04, .valid_sber05] {
            
            try XCTAssertNoThrow(map(.init(string.utf8)).get())
        }
    }
    
    func test_map_shouldDeliverResponse_e1_samples() throws {
        
        for string in [String.e1_sample_step1, .e1_sample_step2, .e1_sample_step3, .e1_sample_step4, .e1_sample_step5] {
            
            try XCTAssertNoThrow(map(.init(string.utf8)).get())
        }
    }
    
    func test_map_shouldDeliverResponse_e1_sample_step1() throws {
        
        try assert(string: .e1_sample_step1, .init(
            additional: [],
            finalStep: false,
            needMake: false,
            needOTP: false,
            needSum: false,
            parametersForNextStep: [
                makeParameter(
                    dataType: .number,
                    id: "1",
                    inputFieldType: .account,
                    isPrint: false,
                    regExp: "^.{1,250}$",
                    svgImage: nil,
                    title: "Лицевой счет",
                    type: .input,
                    viewType: .input
                ),
                makeParameter(
                    content: "ffc84724-8976-4d37-8af8-be84a4386126",
                    dataType: ._backendReserved,
                    id: "##ID##",
                    isPrint: false,
                    isRequired: false,
                    type: .missing,
                    viewType: .output
                ),
                makeParameter(
                    content: "1",
                    dataType: ._backendReserved,
                    id: "##STEP##",
                    isPrint: false,
                    isRequired: false,
                    type: .missing,
                    viewType: .output
                )
            ],
            paymentOperationDetailID: nil
        ))
    }
    
    func test_map_shouldDeliverResponse_withAdditional() throws {
        
        try assert(string: .withAdditional, .init(
            additional: [
                makeAdditional(
                    fieldName: "n1",
                    fieldValue: "v1",
                    fieldTitle: "t1"
                ),
                makeAdditional(
                    fieldName: "n2",
                    fieldValue: "v2",
                    fieldTitle: "t2",
                    md5Hash: "md5hash2"
                ),
                makeAdditional(
                    fieldName: "n3",
                    fieldValue: "v3",
                    fieldTitle: "t3",
                    svgImage: "svgImage3"
                ),
                makeAdditional(
                    fieldName: "n4",
                    fieldValue: "v4",
                    fieldTitle: "t4",
                    md5Hash: "md5hash4",
                    svgImage: "svgImage4"
                ),
            ],
            finalStep: false,
            needMake: false,
            needOTP: true,
            needSum: false,
            parametersForNextStep: []
        ))
    }
    
    func test_map_shouldDeliverResponse_multiSum() throws {
        #warning("add field `visible: Bool`")
        try assert(string: .multiSum, .init(
            additional: [
                makeAdditional(
                    fieldName: "4",
                    fieldValue: "МОСКВА,АМУРСКАЯ УЛ.,2А К2,108",
                    fieldTitle: "Адрес",
                    md5Hash: "87f2fad4a6997e1d3ae634c551c50f14"
                ),
                makeAdditional(
                    fieldName: "8",
                    fieldValue: "253.650",
                    fieldTitle: "ПРЕД. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504"
                ),
            ],
            finalStep: false,
            needMake: false,
            needOTP: false,
            needSum: false,
            parametersForNextStep: [
                makeParameter(
                    content:  "042024",
                    dataType: .string,
                    id: "5",
                    isPrint: false,
                    isRequired: false,
                    regExp: "^.{1,250}$",
                    title: "Период(ММГГГГ)",
                    type: .input,
                    viewType: .input
                ),
                makeParameter(
                    content: " ",
                    dataType: .string,
                    id: "9",
                    isPrint: false,
                    isRequired: false,
                    regExp: "^.{1,250}$",
                    title: "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-НОЧЬ №11696183741504",
                    type: .input,
                    viewType: .input
                ),
                makeParameter(
                    content: " ",
                    dataType: .string,
                    id: "13",
                    isPrint: false,
                    isRequired: false,
                    regExp: "^.{1,250}$",
                    title: "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПИК №11696183741504",
                    type: .input,
                    viewType: .input
                ),
                makeParameter(
                    content: " ",
                    dataType: .string,
                    id: "17",
                    isPrint: false,
                    isRequired: false,
                    regExp: "^.{1,250}$",
                    title: "ТЕК. ПОКАЗАНИЯ ЭЛЕКТРОЭНЕРГИЯ-ПОЛУПИК №11696183741504",
                    type: .input,
                    viewType: .input
                ),
                makeParameter(
                    content: " ",
                    dataType: .string,
                    id: "21",
                    isPrint: false,
                    isRequired: false,
                    regExp: "^.{1,250}$",
                    title: "ТЕК. ПОКАЗАНИЯ ХВС №1012018234307",
                    type: .input,
                    viewType: .input
                ),
                makeParameter(
                    content: " ",
                    dataType: .string,
                    id: "25",
                    isPrint: false,
                    isRequired: false,
                    regExp: "^.{1,250}$",
                    title: "ТЕК. ПОКАЗАНИЯ ХВ_ГВС №1012018015708",
                    type: .input,
                    viewType: .input
                ),
                makeParameter(
                    content: " ",
                    dataType: .string,
                    id: "29",
                    inputFieldType: .counter,
                    isPrint: false,
                    isRequired: false,
                    regExp: "^.{1,250}$",
                    title: "ТЕК. ПОКАЗАНИЯ ОТОПЛЕНИЕ №7745213",
                    type: .input,
                    viewType: .input
                ),
                makeParameter(
                    content: "4273.87",
                    dataType: .number,
                    id: "65",
                    isPrint: false,
                    isRequired: false,
                    rawLength: 2,
                    regExp: "^.{1,250}$",
                    title: "УСЛУГИ_ЖКУ",
                    type: .input,
                    viewType: .input
                ),
                makeParameter(
                    content: "0.00",
                    dataType: .number,
                    id: "143",
                    inputFieldType: .penalty,
                    isPrint: false,
                    isRequired: false,
                    rawLength: 2,
                    regExp: "^.{1,250}$",
                    title: "Сумма пени",
                    type: .input,
                    viewType: .input
                ),
            ]
        ))
    }
    
    // MARK: - Helpers
    
    private typealias Response = ResponseMapper.CreateAnywayTransferResponse
    private typealias MappingResult = ResponseMapper.MappingResult<Response>
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> MappingResult {
        
        ResponseMapper.mapCreateAnywayTransferResponse(data, httpURLResponse)
    }
    
    private func assert(
        string: String,
        _ response: Response,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        try assert(.init(string.utf8), response, file: file, line: line)
    }
    
    private func assert(
        _ data: Data,
        _ response: Response,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        
        do {
            let receivedResponse = try map(data).get()
            XCTAssertNoDiff(receivedResponse, response, file: file, line: line)
        } catch {
            XCTFail("Mapping failed with error: \(error)", file: file, line: line)
        }
    }
    
    private func makeParameter(
        content: String? = nil,
        dataDictionary: String? = nil,
        dataDictionaryРarent: String? = nil,
        dataType: Response.Parameter.DataType,
        group: String? = nil,
        id: String,
        inputFieldType: Response.Parameter.InputFieldType? = nil,
        inputMask: String? = nil,
        isPrint: Bool = true,
        isRequired: Bool = true,
        maxLength: Int? = nil,
        mask: String? = nil,
        minLength: Int? = nil,
        order: Int? = nil,
        phoneBook: Bool = false,
        rawLength: Int = 0,
        isReadOnly: Bool = false,
        regExp: String = "",
        subGroup: String? = nil,
        subTitle: String? = nil,
        svgImage: String? = nil,
        title: String = "",
        type: Response.Parameter.FieldType,
        viewType: Response.Parameter.ViewType
    ) -> Response.Parameter {
        
        .init(
            content: content,
            dataDictionary: dataDictionary,
            dataDictionaryРarent: dataDictionaryРarent,
            dataType: dataType,
            group: group,
            id: id,
            inputFieldType: inputFieldType,
            inputMask: inputMask,
            isPrint: isPrint,
            isRequired: isRequired,
            maxLength: maxLength,
            mask: mask,
            minLength: minLength,
            order: order,
            phoneBook: phoneBook,
            rawLength: rawLength,
            isReadOnly: isReadOnly,
            regExp: regExp,
            subGroup: subGroup,
            subTitle: subTitle,
            svgImage: svgImage,
            title: title,
            type: type,
            viewType: viewType
        )
    }
    
    private func makeAdditional(
        fieldName: String = UUID().uuidString,
        fieldValue: String = UUID().uuidString,
        fieldTitle: String = UUID().uuidString,
        md5Hash: String? = nil,
        recycle: Bool = false,
        svgImage: String? = nil,
        typeIdParameterList: String? = nil
    ) -> Response.Additional {
        
        .init(
            fieldName: fieldName,
            fieldValue: fieldValue,
            fieldTitle: fieldTitle,
            md5Hash: md5Hash,
            recycle: recycle,
            svgImage: svgImage,
            typeIdParameterList: typeIdParameterList
        )
    }
}

private extension Data {
    
    static let empty: Data = .init()
    static let invalidData: Data = String.invalidData.json
    static let emptyJSON: Data = String.emptyJSON.json
    static let emptyDataResponse: Data = String.emptyDataResponse.json
    static let nullServerResponse: Data = String.nullServerResponse.json
    static let serverError: Data = String.serverError.json
    static let validData: Data = String.validData.json
}

private extension String {
    
    var json: Data { .init(self.utf8) }
    
    static let invalidData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""
    
    static let emptyJSON = "{}"
    
    static let emptyDataResponse = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": {}
}
"""
    
    static let nullServerResponse = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": null
}
"""
    
    static let serverError = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
    
    static let withAdditional = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "needOTP": true,
        "additionalList": [
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
        "parameterListForNextStep": []    }
}
"""
    
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
    
    static let e1_sample_step2 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "additionalList": [],
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
                "content": "2",
                "visible": false
            }
        ]
    }
}
"""
    
    static let e1_sample_step3 = """
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
                "content": "ffe1aac2-67aa-47bc-be7b-33c5fbb08b2b",
                "visible": false
            },
            {
                "id": "##STEP##",
                "viewType": "OUTPUT",
                "content": "3",
                "visible": false
            }
        ],
        "options": [
            "MULTI_SUM"
        ]
    }
}
"""
    
    static let e1_sample_step4 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": {
        "amount": 4374.48,
        "needSum": true,
        "additionalList": [
            {
                "fieldName": "SumSTrs",
                "fieldValue": "4374.48",
                "fieldTitle": "Сумма"
            }
        ],
        "parameterListForNextStep": [
            {
                "id": "##ID##",
                "viewType": "OUTPUT",
                "content": "ffc84724-8976-4d37-8af8-be84a4386126",
                "visible": false
            },
            {
                "id": "##STEP##",
                "viewType": "OUTPUT",
                "content": "4",
                "visible": false
            }
        ]
    }
}
"""
    
    static let e1_sample_step5 = """
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
                "fieldValue": "4374.48",
                "fieldTitle": "Рекомендованная сумма"
            }
        ],
        "parameterListForNextStep": [
            {
                "id": "##ID##",
                "viewType": "OUTPUT",
                "content": "ffc84724-8976-4d37-8af8-be84a4386126",
                "visible": false
            },
            {
                "id": "##STEP##",
                "viewType": "OUTPUT",
                "content": "5",
                "visible": false
            }
        ],
        "finalStep": true,
        "scenario": "OK"
    }
}
"""
    
    static let multiSum = """
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
}
