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
    ) -> [LatestPayment] {
        
        do {
            switch httpURLResponse.statusCode {
            case 200:
                let operators = try JSONDecoder().decode([LatestPaymentCodable].self, from: data)
                return map(operators)
                
            default:
                return []
            }
        } catch {
            return []
        }
    }
    
    private static func map(
        _ data: [LatestPaymentCodable]
    ) -> [LatestPayment] {
        
        data.map { .init(
            title: $0.name,
            amount: .init($0.amount)
        )}
    }
}

//TODO: move to module
extension ResponseMapper {
 
    struct LatestPayment: Identifiable {
        
        var id: String { title }
        let title: String
        let amount: Decimal
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
        let md5hash: String
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

