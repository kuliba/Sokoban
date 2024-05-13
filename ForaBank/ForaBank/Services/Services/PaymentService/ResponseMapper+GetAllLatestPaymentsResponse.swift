//
//  ResponseMapper+GetAllLatestPaymentsResponse.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 13.05.2024.
//

import Foundation
import RemoteServices

extension ResponseMapper {
    
    static func mapGetAllLatestPaymentsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<[LatestPaymentCodable]?> {
        
        map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: [LatestPaymentCodable]
    ) throws -> [LatestPaymentService]? {
        
        data.map { LatestPaymentService(
            id: $0.id,
            title: $0.lastPaymentName ?? "",
            amount: .double($0.amount)
        )}
    }
}

//TODO: move to module
struct LatestPaymentService: Identifiable {
    
    let id: Int
    let title: String
    let amount: Amount
}

private extension ResponseMapper {
    
    struct LatestPaymentCodable: Codable {
        
        let id: Int
        let date: Date
        let paymentDate: String
        let type: Kind
        var additionalList: [AdditionalListData]
        var amount: Double
        var puref: String
        var lastPaymentName: String?
        
        private enum CodingKeys: String, CodingKey {
            
            case id, date, paymentDate, type, additionalList, amount, puref
            case lastPaymentName = "lpName"
        }
        
        struct AdditionalListData: Codable, Equatable {
            
            let fieldTitle: String?
            let fieldName: String
            let fieldValue: String
            let svgImage: String?
        }
        
        enum Kind: String, Codable {
            
            case phone
            case service
            case mobile
            case internet
            case transport
            case taxAndStateService
            case outside
            case unknown
        }
    }
}

