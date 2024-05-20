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
    ) -> [LatestServicePayment] {
        
        switch httpURLResponse.statusCode {
        case 200:
            let operators = try? JSONDecoder().decode([LatestPaymentCodable].self, from: data)
            return (operators ?? []).map(LatestServicePayment.init)
            
        default:
            return []
        }
    }
}

private extension ResponseMapper.LatestServicePayment {
    
    init(_ last: ResponseMapper.LatestPaymentCodable) {
        
        self.init(
            title: last.name,
            amount: .init(last.amount),
            md5Hash: last.md5hash,
            puref: last.puref
        )
    }
}

//TODO: move to module
extension ResponseMapper {
    
    struct LatestServicePayment: Identifiable {
        
        var id: String { title }
        let title: String
        let amount: Decimal
        let md5Hash: String?
        let puref: String
    }
}

enum LatestPaymentKind: String, Decodable {
    
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
    
    struct LatestPaymentCodable: Decodable {
        
        let name: String
        let paymentDate: String
        let type: LatestPaymentKind
        let additionalList: [AdditionalListData]
        let amount: Double
        let puref: String
        let lastPaymentName: String?
        let md5hash: String?
        let date: Int
        
        enum CodingKeys: String, CodingKey {
            case date, paymentDate, type, additionalList, amount, puref, md5hash, name
            case lastPaymentName = "lpName"
        }
        
        struct AdditionalListData: Decodable, Equatable {
            
            let fieldTitle: String?
            let fieldName: String
            let fieldValue: String
            let svgImage: String?
            let recycle: String?
            let typeIdParameterList: String?
        }
    }
}

