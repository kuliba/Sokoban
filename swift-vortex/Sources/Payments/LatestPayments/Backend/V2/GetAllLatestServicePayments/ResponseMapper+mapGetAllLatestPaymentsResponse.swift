//
//  ResponseMapper+mapGetAllLatestServicePaymentsResponse.swift
//
//
//  Created by Igor Malyarov on 28.06.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetAllLatestServicePaymentsResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<[LatestServicePayment]> {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        return map(
            data, httpURLResponse,
            dateDecodingStrategy: .formatted(dateFormatter),
            mapOrThrow: [LatestServicePayment].init
        )
    }
}

extension ResponseMapper {
    
    public struct LatestServicePayment: Equatable {
        
        public let date: Date
        public let amount: Decimal
        public let name: String
        public let md5Hash: String?
        public let puref: String
        public let type: String
        public let paymentFlow: String?
        public let additionalItems: [AdditionalItem]
        
        public init(
            date: Date,
            amount: Decimal,
            name: String,
            md5Hash: String?,
            paymentFlow: String?,
            puref: String,
            type: String,
            additionalItems: [AdditionalItem]
        ) {
            self.date = date
            self.amount = amount
            self.name = name
            self.md5Hash = md5Hash
            self.paymentFlow = paymentFlow
            self.puref = puref
            self.type = type
            self.additionalItems = additionalItems
        }
        
        public struct AdditionalItem: Equatable {
            
            public let fieldName: String
            public let fieldValue: String
            public let fieldTitle: String?
            public let svgImage: String?
            
            public init(
                fieldName: String,
                fieldValue: String,
                fieldTitle: String?,
                svgImage: String?
            ) {
                self.fieldName = fieldName
                self.fieldValue = fieldValue
                self.fieldTitle = fieldTitle
                self.svgImage = svgImage
            }
        }
    }
}

private extension Array where Element == ResponseMapper.LatestServicePayment {
    
    init(_ data: [ResponseMapper._Data]) throws {
        
        self = try data.map(ResponseMapper.LatestServicePayment.init)
    }
}

private extension ResponseMapper.LatestServicePayment {
    
    init(_ data: ResponseMapper._Data) throws {
        
        guard data.type == "service"
        else {
            struct NonServiceLatestPayment: Error {}
            throw NonServiceLatestPayment()
        }
        
        self.init(
            date: data.paymentDate,
            amount: data.amount,
            name: data.name,
            md5Hash: data.md5hash,
            paymentFlow: data.payment_flow,
            puref: data.puref,
            type: data.type,
            additionalItems: data.additionalList.map(AdditionalItem.init)
        )
    }
}

private extension ResponseMapper.LatestServicePayment.AdditionalItem {
    
    init(_ data: ResponseMapper._Data._AdditionalItem) {
        
        self.init(
            fieldName: data.fieldName,
            fieldValue: data.fieldValue,
            fieldTitle: data.fieldTitle,
            svgImage: data.svgImage
        )
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let paymentDate: Date
        let date: Int
        let type: String
        let amount: Decimal
        let puref: String
        let payment_flow: String?
        let lpName: String?
        let md5hash: String
        let name: String
        let additionalList: [_AdditionalItem]
        
        struct _AdditionalItem: Decodable {
            
            let fieldName: String
            let fieldValue: String
            let fieldTitle: String?
            let svgImage: String?
            let recycle: String?
            let typeIdParameterList: String?
        }
    }
}
