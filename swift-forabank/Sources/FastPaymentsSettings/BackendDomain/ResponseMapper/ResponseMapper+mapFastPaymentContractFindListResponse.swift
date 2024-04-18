//
//  ResponseMapper+mapFastPaymentContractFindListResponse.swift
//
//
//  Created by Igor Malyarov on 28.12.2023.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapFastPaymentContractFindListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<FastPaymentContractFullInfo?> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> FastPaymentContractFullInfo? {
        
        data.first?.info
    }
}

private extension ResponseMapper {
    
    typealias _Data = [_DTO]
}

private extension ResponseMapper._DTO {
    
    var info: FastPaymentContractFullInfo? {
        
        guard
            let accountAttribute = fastPaymentContractAccountAttributeList.first?.dto,
            let contractAttribute = fastPaymentContractAttributeList.first?.dto,
            let clientInfo = fastPaymentContractClAttributeList.first?.dto
        else { return nil }
        
        return .init(
            account: accountAttribute,
            clientInfo: clientInfo,
            contract: contractAttribute
        )
    }
}

private extension ResponseMapper {
    
    struct _DTO: Decodable {
        
        let fastPaymentContractAccountAttributeList: [_Account]
        let fastPaymentContractAttributeList: [_Contract]
        let fastPaymentContractClAttributeList: [_Client]
        
        struct _Account: Decodable {
            
            let accountID: Int
            let flagPossibAddAccount: Flag
            let maxAddAccount: Int
            let minAddAccount: Int
            let accountNumber: String
        }
        
        struct _Contract: Decodable {
            
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
        
        struct _Client: Decodable {
            
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

private extension ResponseMapper._DTO._Account {
    
    var dto: FastPaymentContractFullInfo.Account {
        
        .init(
            accountID: accountID,
            flagPossibAddAccount: flagPossibAddAccount.dto,
            maxAddAccount: maxAddAccount,
            minAddAccount: minAddAccount,
            accountNumber: accountNumber
        )
    }
}

private extension ResponseMapper._DTO._Contract {
    
    var dto: FastPaymentContractFullInfo.Contract {
        
        .init(
            accountID: accountID,
            branchID: branchID,
            clientID: clientID,
            flagBankDefault: flagBankDefault.dto,
            flagClientAgreementIn: flagClientAgreementIn.dto,
            flagClientAgreementOut: flagClientAgreementOut.dto,
            fpcontractID: fpcontractID,
            phoneNumber: phoneNumber,
            phoneNumberMask: phoneNumberMask,
            branchBIC: branchBIC
        )
    }
}

private extension ResponseMapper._DTO._Client {
    
    var dto: FastPaymentContractFullInfo.ClientInfo {
        
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
    
    var dto: FastPaymentContractFullInfo.Flag {
        
        switch self {
        case .yes:   return .yes
        case .no:    return .no
        case .empty: return .empty
        }
    }
}
