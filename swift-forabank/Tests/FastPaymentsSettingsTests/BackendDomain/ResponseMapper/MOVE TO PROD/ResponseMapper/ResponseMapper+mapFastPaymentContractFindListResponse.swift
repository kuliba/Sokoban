//
//  ResponseMapper+mapFastPaymentContractFindListResponse.swift
//  
//
//  Created by Igor Malyarov on 28.12.2023.
//

import FastPaymentsSettings
import Foundation

extension ResponseMapper {
    
    typealias FastPaymentContractFindListResult = Result<FastPaymentContractFullInfo?, MappingError>
    
    static func mapFastPaymentContractFindListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> FastPaymentContractFindListResult {
        
        map(data, httpURLResponse, map: map)
    }
    
    private static func map(
        _ data: _Data
    ) throws -> FastPaymentContractFullInfo? {
        
        data.first?.dto
    }
}

private extension ResponseMapper {
    
    typealias _Data = [_DTO]
}

private extension ResponseMapper._DTO {
    
    var dto: FastPaymentContractFullInfo? {
        
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
    
    var dto: FastPaymentContractFullInfo.AccountAttribute {
        
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
    
    var dto: FastPaymentContractFullInfo.ContractAttribute {
        
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

