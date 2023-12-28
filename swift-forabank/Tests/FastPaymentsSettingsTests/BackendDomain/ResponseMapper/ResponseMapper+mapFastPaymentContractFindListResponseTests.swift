//
//  ResponseMapper+mapFastPaymentContractFindListResponseTests.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation

struct FastPaymentContractFullInfoTypeDTO: Equatable {
    
    let accountAttribute: AccountAttribute
    let clientInfo: ClientInfo
    let contractAttribute: ContractAttribute
    
    struct AccountAttribute: Equatable {
        
        let accountID: Int
        let flagPossibAddAccount: Flag
        let maxAddAccount: Int
        let minAddAccount: Int
        let accountNumber: String
    }
    
    struct ClientInfo: Equatable {
        
        let clientID: Int
        let inn: String
        let name: String
        let nm: String
        let clientSurName: String
        let clientPatronymicName: String
        let clientName: String
        let docType: String
        let regSeries: String
        let regNumber: String
        let address: String
    }
    
    struct ContractAttribute: Equatable {
        
        let accountID: Int
        let branchID: Int
        let clientID: Int
        let flagBankDefault: Flag
        let flagClientAgreementIn: Flag
        let flagClientAgreementOut: Flag
        let fpcontractID: Int
        let phoneNumber: String
        let phoneNumberMask: String
        let branchBIC: String
    }

    enum Flag: Equatable {
        
        case yes, no, empty
    }
}

extension ResponseMapper {
    
    typealias FastPaymentContractFindListResult = Result<FastPaymentContractFullInfoTypeDTO?, MappingError>
    
    static func mapFastPaymentContractFindListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> FastPaymentContractFindListResult {
        
        map(data, httpURLResponse, map: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> FastPaymentContractFullInfoTypeDTO? {
        
        data.first?.dto
    }
}

private extension ResponseMapper {
    
    typealias _Data = [_DTO]
}

private extension ResponseMapper._DTO {
    
    var dto: FastPaymentContractFullInfoTypeDTO? {
        
        guard
            let accountAttribute = fastPaymentContractAccountAttributeList.first?.dto,
            let contractAttribute = fastPaymentContractAttributeList.first?.dto,
            let clientInfo = fastPaymentContractClAttributeList.first?.dto
        else { return nil }
        
        return .init(
            accountAttribute: accountAttribute,
            clientInfo: clientInfo,
            contractAttribute: contractAttribute
        )
    }
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let fastPaymentContractAccountAttributeList: [_AccountAttribute]
        let fastPaymentContractAttributeList: [_ContractAttribute]
        let fastPaymentContractClAttributeList: [_ClientAttribute]
        
        struct _AccountAttribute: Decodable {
            
            let accountID: Int
            let flagPossibAddAccount: Flag
            let maxAddAccount: Int
            let minAddAccount: Int
            let accountNumber: String
        }
        
        struct _ContractAttribute: Decodable {
            
            let accountID: Int
            let branchID: Int
            let clientID: Int
            let flagBankDefault: Flag
            let flagClientAgreementIn: Flag
            let flagClientAgreementOut: Flag
            let fpcontractID: Int
            let phoneNumber: String
            let phoneNumberMask: String?
            let branchBIC: String
        }
        
        struct _ClientAttribute: Decodable {
            
            let clientInfo: ClientInfo
            
            struct ClientInfo: Decodable {
                
                let clientID: Int
                let inn: String
                let name: String
                let nm: String
                let clientSurName: String
                let clientPatronymicName: String
                let clientName: String
                let docType: String
                let regSeries: String
                let regNumber: String
                let address: String
            }
        }

        enum Flag: String, Decodable {
            
            case yes = "YES"
            case no = "NO"
            case empty = "EMPTY"
        }
    }
}

private extension ResponseMapper._DTO._AccountAttribute {
    
    var dto: FastPaymentContractFullInfoTypeDTO.AccountAttribute {
        
        .init(
            accountID: accountID,
            flagPossibAddAccount: flagPossibAddAccount.dto,
            maxAddAccount: maxAddAccount,
            minAddAccount: minAddAccount,
            accountNumber: accountNumber
        )
    }
}

private extension ResponseMapper._DTO._ContractAttribute {
    
    var dto: FastPaymentContractFullInfoTypeDTO.ContractAttribute {
        
        .init(
            accountID: accountID,
            branchID: branchID,
            clientID: clientID,
            flagBankDefault: flagBankDefault.dto,
            flagClientAgreementIn: flagClientAgreementIn.dto,
            flagClientAgreementOut: flagClientAgreementOut.dto,
            fpcontractID: fpcontractID,
            phoneNumber: phoneNumber,
            phoneNumberMask: phoneNumberMask ?? "",
            branchBIC: branchBIC
        )
    }
}

private extension ResponseMapper._DTO._ClientAttribute {
    
    var dto: FastPaymentContractFullInfoTypeDTO.ClientInfo {
        
        .init(
            clientID: clientInfo.clientID,
            inn: clientInfo.inn,
            name: clientInfo.name,
            nm: clientInfo.nm,
            clientSurName: clientInfo.clientSurName,
            clientPatronymicName: clientInfo.clientPatronymicName,
            clientName: clientInfo.clientName,
            docType: clientInfo.docType,
            regSeries: clientInfo.regSeries,
            regNumber: clientInfo.regNumber,
            address: clientInfo.address
        )
    }
}

private extension ResponseMapper._DTO.Flag {
    
    var dto: FastPaymentContractFullInfoTypeDTO.Flag {
        
        switch self {
        case .yes:   return .yes
        case .no:    return .no
        case .empty: return .empty
        }
    }
}

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
    
    func test_DTO() throws {
        
        let data = Data(a2.utf8)
        _ = try JSONDecoder().decode(ResponseMapper._DTO.self, from: data)
    }
    
    // MARK: - Helpers
    
    private func map(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse = anyHTTPURLResponse()
    ) -> ResponseMapper.FastPaymentContractFindListResult {
        
        ResponseMapper.mapFastPaymentContractFindListResponse(data, httpURLResponse)
    }
}

private extension FastPaymentContractFullInfoTypeDTO {
    
    static let a1: Self = .init(
        accountAttribute: .init(
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
        contractAttribute: .init(
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
        accountAttribute: .init(
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
        contractAttribute: .init(
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

private let a2 = """
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
"""
