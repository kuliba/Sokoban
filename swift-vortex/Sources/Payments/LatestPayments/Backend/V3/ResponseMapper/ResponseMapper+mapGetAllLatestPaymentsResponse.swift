//
//  ResponseMapper+mapGetAllLatestPaymentsResponse.swift
//
//
//  Created by Igor Malyarov on 28.06.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetAllLatestPaymentsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<[LatestPayment]> {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        return map(
            data, httpURLResponse,
            dateDecodingStrategy: .formatted(dateFormatter),
            mapOrThrow: [LatestPayment].init
        )
    }
    
    struct LatestPaymentError: Error {}
}

// MARK: - Mapping

private extension Array where Element == ResponseMapper.LatestPayment {
    
    init(_ data: [ResponseMapper._Latest]) throws {
        
        guard !data.isEmpty else {
            
            throw ResponseMapper.LatestPaymentError()
        }
        
        self = data.compactMap(\.latest)
    }
}

private extension ResponseMapper._Latest {
    
    var latest: ResponseMapper.LatestPayment? {
        
        switch self {
        case let .service(service):
            return service.service.map { .service($0) }
            
        case let .withPhone(withPhone):
            return withPhone.withPhone.map { .withPhone($0) }
        }
    }
}

private extension ResponseMapper._Latest._Service {
    
    var service: ResponseMapper.LatestPayment.Service? {
        
        guard let puref,
              !puref.isEmpty,
              let type,
              !type.isEmpty,
              let paymentOperationDetailType,
              !paymentOperationDetailType.isEmpty
        else { return nil }
        
        return .init(
            additionalItems: (additionalList ?? []).map(\.item),
            amount: amount,
            currency: currencyAmount,
            date: date,
            detail: .init(paymentOperationDetailType),
            inn: inn,
            lpName: lpName,
            md5Hash: md5hash,
            name: name,
            paymentDate: paymentDate,
            paymentFlow: paymentFlow?.flow,
            puref: puref,
            type: .init(type == "service" ? "housingAndCommunalService" : type)
        )
    }
}

private extension ResponseMapper._Latest._WithPhone {
    
    var withPhone: ResponseMapper.LatestPayment.WithPhone? {
        
        guard let phoneNumber,
              !phoneNumber.isEmpty,
              let puref,
              !puref.isEmpty,
              let paymentOperationDetailType,
              !paymentOperationDetailType.isEmpty
        else { return nil }
        
        return .init(
            amount: amount?.value,
            bankID: bankId,
            bankName: bankName,
            currency: currencyAmount,
            date: date,
            detail: .init(paymentOperationDetailType),
            md5Hash: md5hash,
            name: name,
            paymentDate: paymentDate,
            paymentFlow: paymentFlow?.flow,
            phoneNumber: phoneNumber,
            puref: puref,
            type: .init(type == "service" ? "housingAndCommunalService" : type)
        )
    }
}

private extension ResponseMapper._Latest._Service._AdditionalItem {
    
    var item: ResponseMapper.LatestPayment.Service.AdditionalItem {
        
        return .init(
            fieldName: fieldName,
            fieldValue: fieldValue,
            fieldTitle: fieldTitle,
            svgImage: svgImage
        )
    }
}

private extension ResponseMapper._Latest._PaymentFlow {
    
    var flow: ResponseMapper.LatestPayment.PaymentFlow {
        
        switch self {
        case .mobile:              return .mobile
        case .qr:                  return .qr
        case .standard:            return .standard
        case .taxAndStateServices: return .taxAndStateServices
        case .transport:           return .transport
        }
    }
}

// MARK: - DTO

private extension ResponseMapper {
    
    enum _Latest: Decodable {
        
        case service(_Service)
        case withPhone(_WithPhone)
        
        init(from decoder: Decoder) throws {
            
            do {
                self = try .withPhone(_WithPhone(from: decoder))
            } catch {
                self = try .service(_Service(from: decoder))
            }
        }
    }
}

private extension ResponseMapper._Latest {
    
    struct _Service: Decodable {
        
        let paymentDate: Date
        let date: Int
        let paymentOperationDetailType: _PaymentOperationDetailType?
        let type: _LatestType?
        let currencyAmount: String?
        let puref: String?
        let md5hash: String?
        let name: String?
        let paymentFlow: _PaymentFlow?
        let amount: Decimal?
        let lpName: String?
        let inn: String?
        let additionalList: [_AdditionalItem]?
        
        struct _AdditionalItem: Decodable {
            
            let fieldName: String
            let fieldValue: String
            let fieldTitle: String?
            let svgImage: String?
            let recycle: String?
            let typeIdParameterList: String?
        }
    }
    
    struct _WithPhone: Decodable {
        
        let paymentDate: Date
        let date: Int
        let paymentOperationDetailType: _PaymentOperationDetailType?
        let type: _LatestType
        let currencyAmount: String?
        let puref: String?
        let md5hash: String?
        let name: String?
        let paymentFlow: _PaymentFlow?
        let phoneNumber: String?
        let bankName: String?
        let bankId: String?
        let amount: CustomDecimal?
    }
}

private extension ResponseMapper._Latest {
    
    typealias _LatestType = String
    
    enum _PaymentFlow: String, Decodable {
        
        case mobile              = "MOBILE"
        case qr                  = "QR"
        case standard            = "STANDARD_FLOW"
        case taxAndStateServices = "TAX_AND_STATE_SERVICE"
        case transport           = "TRANSPORT"
    }
    
    typealias _PaymentOperationDetailType = String
}
