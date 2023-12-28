//
//  ResponseMapper+mapFastPaymentContractFindListResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import XCTest

final class ResponseMapper_mapFastPaymentContractFindListResponseTests: XCTestCase {
    
    func test_map_shouldDeliverInvalidErrorOnInvalidData() throws {
        
        let invalidData = anyData()
        
        let result = map(invalidData)
        
        assert(result, equals: .failure(.invalid(
            statusCode: 200,
            data: invalidData
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithOkHTTPURLResponseStatusCode() throws {
        
        let okResponse = anyHTTPURLResponse(statusCode: 200)
        let result = map(jsonWithServerError(), okResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_map_shouldDeliverServerErrorOnDataWithServerErrorWithNonOkHTTPURLResponseStatusCode() throws {
        
        let nonOkResponse = anyHTTPURLResponse(statusCode: 400)
        let result = map(jsonWithServerError(), nonOkResponse)
        
        assert(result, equals: .failure(.server(
            statusCode: 102,
            errorMessage: "Возникла техническая ошибка"
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCode() throws {
        
        let statusCode = 400
        let data = anyData()
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(data, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: data
        )))
    }
    
    func test_map_shouldDeliverInvalidOnNonOkHTTPURLResponseStatusCodeWithBadData() throws {
        
        let badData = Data(jsonStringWithBadData.utf8)
        let statusCode = 400
        let nonOkResponse = anyHTTPURLResponse(statusCode: statusCode)
        let result = map(badData, nonOkResponse)
        
        assert(result, equals: .failure(.invalid(
            statusCode: statusCode,
            data: badData
        )))
    }
    
    func test_map_shouldDeliverNilResponseOnOkHTTPURLResponseStatusCodeWithValidData() throws {
        
        let validData = Data(jsonStringWithEmpty.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(nil))
    }
    
    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidData_a1() throws {
        
        let validData = Data(jsonString_a1.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.a1))
    }
    
    func test_map_shouldDeliverResponseOnOkHTTPURLResponseStatusCodeWithValidData_a2() throws {
        
        let validData = Data(jsonString_a2.utf8)
        let result = map(validData)
        
        assert(result, equals: .success(.a2))
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.FastPaymentContractFindListResult {
        
        ResponseMapper.mapFastPaymentContractFindListResponse(data, httpURLResponse)
    }
}

private extension FastPaymentContractFullInfo {
    
    static let a1: Self = .init(
        account: .init(
            accountID: 10004203497,
            flagPossibAddAccount: .yes,
            maxAddAccount: 0,
            minAddAccount: 0,
            accountNumber: "40817810752005000662"
        ),
        clientInfo: .init(
            clientID: 10002076204,
            inn: "631226829894",
            name: "Иванова Юлия Александровна",
            nm: "Юлия Александровна В",
            clientSurName: "Иванова",
            clientPatronymicName: "Александровна",
            clientName: "Юлия",
            docType: "21",
            regSeries: "36 12",
            regNumber: "990428",
            address: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 443109, Самарская обл, Самара г, Ново-Садовая ,  д. 7Г,  кв. 5"
        ),
        contract: .init(
            accountID: 10004203497,
            branchID: 2000,
            clientID: 10002076204,
            flagBankDefault: .empty,
            flagClientAgreementIn: .yes,
            flagClientAgreementOut: .yes,
            fpcontractID: 10000084818,
            phoneNumber: "79171044913",
            phoneNumberMask: "",
            branchBIC: "044525341"
        )
    )
    
    static let a2: Self = .init(
        account: .init(
            accountID: 10004203497,
            flagPossibAddAccount: .no,
            maxAddAccount: 0,
            minAddAccount: 0,
            accountNumber: "40817810752005000662"
        ),
        clientInfo: .init(
            clientID: 10002076204,
            inn: "631226829894",
            name: "Ваняркина Юлия Александровна",
            nm: "Юлия Александровна В",
            clientSurName: "Ваняркина",
            clientPatronymicName: "Александровна",
            clientName: "Юлия",
            docType: "21",
            regSeries: "36 12",
            regNumber: "990428",
            address: "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 443109, Самарская обл, Самара г, Товарная ,  д. 7Г,  кв. 5"
        ),
        contract: .init(
            accountID: 10004203497,
            branchID: 2000,
            clientID: 10002076204,
            flagBankDefault: .empty,
            flagClientAgreementIn: .no,
            flagClientAgreementOut: .no,
            fpcontractID: 10000084818,
            phoneNumber: "79171044913",
            phoneNumberMask: "",
            branchBIC: "044525341"
        )
    )
}

private let jsonStringWithBadData = """
{
    "statusCode": 102,
    "errorMessage": null,
    "data": { "a": "junk" }
}
"""

private let jsonStringWithEmpty = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": []
}
"""

private let jsonString_a1 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": [
        {
            "fastPaymentContractAccountAttributeList": [
                {
                    "accountID": 10004203497,
                    "flagPossibAddAccount": "YES",
                    "maxAddAccount": 0E-10,
                    "minAddAccount": 0E-10,
                    "accountNumber": "40817810752005000662"
                }
            ],
            "fastPaymentContractAttributeList": [
                {
                    "accountID": 10004203497,
                    "branchID": 2000,
                    "clientID": 10002076204,
                    "flagBankDefault": "EMPTY",
                    "flagClientAgreementIn": "YES",
                    "flagClientAgreementOut": "YES",
                    "phoneNumber": "79171044913",
                    "branchBIC": "044525341",
                    "fpcontractID": 10000084818
                }
            ],
            "fastPaymentContractClAttributeList": [
                {
                    "clientInfo": {
                        "clientID": 10002076204,
                        "inn": "631226829894",
                        "name": "Иванова Юлия Александровна",
                        "nm": "Юлия Александровна В",
                        "clientSurName": "Иванова",
                        "clientPatronymicName": "Александровна",
                        "clientName": "Юлия",
                        "docType": "21",
                        "regSeries": "36 12",
                        "regNumber": "990428",
                        "address": "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 443109, Самарская обл, Самара г, Ново-Садовая ,  д. 7Г,  кв. 5"
                    }
                }
            ]
        }
    ]
}
"""

private let jsonString_a2 = """
{
    "statusCode": 0,
    "errorMessage": null,
    "data": [
        {
            "fastPaymentContractAccountAttributeList": [
                {
                    "accountID": 10004203497,
                    "flagPossibAddAccount": "NO",
                    "maxAddAccount": 0E-10,
                    "minAddAccount": 0E-10,
                    "accountNumber": "40817810752005000662"
                }
            ],
            "fastPaymentContractAttributeList": [
                {
                    "accountID": 10004203497,
                    "branchID": 2000,
                    "clientID": 10002076204,
                    "flagBankDefault": "EMPTY",
                    "flagClientAgreementIn": "NO",
                    "flagClientAgreementOut": "NO",
                    "phoneNumber": "79171044913",
                    "branchBIC": "044525341",
                    "fpcontractID": 10000084818
                }
            ],
            "fastPaymentContractClAttributeList": [
                {
                    "clientInfo": {
                        "clientID": 10002076204,
                        "inn": "631226829894",
                        "name": "Ваняркина Юлия Александровна",
                        "nm": "Юлия Александровна В",
                        "clientSurName": "Ваняркина",
                        "clientPatronymicName": "Александровна",
                        "clientName": "Юлия",
                        "docType": "21",
                        "regSeries": "36 12",
                        "regNumber": "990428",
                        "address": "РОССИЙСКАЯ ФЕДЕРАЦИЯ, 443109, Самарская обл, Самара г, Товарная ,  д. 7Г,  кв. 5"
                    }
                }
            ]
        }
    ]
}
"""
