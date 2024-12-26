// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let fastPaymentContractFindListDO = try? newJSONDecoder().decode(FastPaymentContractFindListDO.self, from: jsonData)

import Foundation

// MARK: - FastPaymentContractFindListDO
struct FastPaymentContractFindListDO: NetworkModelProtocol, Codable {
    
    init(data: Data) throws {
        self = try newJSONDecoder().decode(FastPaymentContractFindListDO.self, from: data)
    }
    
    let statusCode: Int?
    let errorMessage: String?
    let data: [Datum2]?
}

// MARK: - Datum
struct Datum2 : Codable {
    let fastPaymentContractAccountAttributeList: [FastPaymentContractAccountAttributeList2]?
    let fastPaymentContractAttributeList: [FastPaymentContractAttributeList2]?
    let fastPaymentContractClAttributeList: [FastPaymentContractClAttributeList2]?
}

// MARK: - FastPaymentContractAccountAttributeList
struct FastPaymentContractAccountAttributeList2 : Codable {
    let accountID: Int?
    let flagPossibAddAccount: String?
    let maxAddAccount, minAddAccount: Int?
    let accountNumber: String?
}

// MARK: - FastPaymentContractAttributeList
struct FastPaymentContractAttributeList2 : Codable {
    let accountID, branchID, clientID: Int?
    let flagBankDefault, flagClientAgreementIn, flagClientAgreementOut, phoneNumber: String?
    let branchBIC: String?
    let fpcontractID: Int?
}

// MARK: - FastPaymentContractClAttributeList
struct FastPaymentContractClAttributeList2 : Codable {
    let clientInfo: ClientInfo2?
}

// MARK: - ClientInfo
struct ClientInfo2 : Codable {
    let clientID: Int?
    let inn, name, nm, clientSurName: String?
    let clientPatronymicName, clientName, docType, regSeries: String?
    let regNumber, address: String?
}

