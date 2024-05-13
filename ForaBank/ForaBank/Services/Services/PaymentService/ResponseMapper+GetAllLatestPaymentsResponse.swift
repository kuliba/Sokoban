//
//  ResponseMapper+GetAllLatestPaymentsResponse.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 13.05.2024.
//

import Foundation
import OperatorsListComponents

extension ResponseMapper {
    
    typealias Mapper = OperatorsListComponents.ResponseMapper
    
    static func mapGetAllLatestPaymentsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> Mapper.MappingResult<[LatestPayment]?> {
        
        Mapper.map(data, httpURLResponse, mapOrThrow: map)
    }
    
    private static func map(
        _ data: [LatestPaymentCodable]
    ) throws -> [LatestPayment]? {
        
        data.map { LatestPayment(
            title: $0.name,
            amount: .double($0.amount)
        )}
    }
}

//TODO: move to module
extension ResponseMapper {
 
    struct LatestPayment: Identifiable {
        
        var id: String { title }
        let title: String
        let amount: Amount
    }
}

enum LatestPaymentKind: String, Codable {
    
    case phone
    case service
    case mobile
    case internet
    case transport
    case taxAndStateService
    case outside
}

extension LatestPaymentKind {

    func parameterService() -> (String, String) {
        
        switch self {
        case .internet:
            return ("isInternetPayments", "true")
        case .mobile:
            return ("isMobilePayments", "true")
        case .phone:
            return ("isPhonePayments", "true")
        case .transport:
            return ("isTransportPayments", "true")
        case .taxAndStateService:
            return ("isTaxAndStateServicePayments", "true")
        case .outside:
            return ("isOutsidePayments", "true")
        case .service:
            return ("isServicePayments", "true")
        }
    }
}


private extension ResponseMapper {
    
    struct LatestPaymentCodable: Codable {
        
        let name: String
        let paymentDate: String
        let type: LatestPaymentKind
        let additionalList: [AdditionalListData]
        let amount: Double
        let puref: String
        let lastPaymentName: String?
        let md5hash: String
        let date: Int
        
        enum CodingKeys: String, CodingKey {
            case date, paymentDate, type, additionalList, amount, puref, md5hash, name
            case lastPaymentName = "lpName"

        }
        
        struct AdditionalListData: Codable, Equatable {
            
            let fieldTitle: String?
            let fieldName: String
            let fieldValue: String
            let svgImage: String?
            let recycle: String?
            let typeIdParameterList: String?
        }
    }
}

