//
//  ResponseMapper+mapGetServiceCategoryListResponse.swift
//
//
//  Created by Igor Malyarov on 13.08.2024.
//

import Foundation
import RemoteServices

public extension ResponseMapper {
    
    static func mapGetServiceCategoryListResponse(
        _ data: Data,
        _ httpURLResponse: HTTPURLResponse
    ) -> MappingResult<GetServiceCategoryListResponse> {
        
        map(data, httpURLResponse, mapOrThrow: GetServiceCategoryListResponse.init)
    }
}

private extension ResponseMapper.GetServiceCategoryListResponse {
    
    init(_ data: ResponseMapper._Data) throws {
        
        self.init(
            list: data.categoryGroupList.map(ResponseMapper.ServiceCategory.init),
            serial: data.serial
        )
    }
}

private extension ResponseMapper.ServiceCategory {
    
    init(_ category: ResponseMapper._Data._Category) {
        
        self.init(
            latestPaymentsCategory: category.latestPaymentsCategory.map { .init($0) },
            md5Hash: category.md5hash,
            name: category.name,
            ord: category.ord,
            paymentFlow: .init(category.paymentFlow),
            hasSearch: category.search,
            type: .init(category.type)
        )
    }
}

private extension ResponseMapper.ServiceCategory.PaymentFlow {
    
    init(_ flow: ResponseMapper._Data._Category._PaymentFlow) {
        
        switch flow {
        case .mobile:              self = .mobile
        case .qr:                  self = .qr
        case .standard:            self = .standard
        case .taxAndStateServices: self = .taxAndStateServices
        case .transport:           self = .transport
        }
    }
}

private extension ResponseMapper {
    
    struct _Data: Decodable {
        
        let categoryGroupList: [_Category]
        let serial: String
        
        struct _Category: Decodable {
            
            let type: CategoryType
            let name: String
            let ord: Int
            let md5hash: String
            let paymentFlow: _PaymentFlow
            let latestPaymentsCategory: LatestPaymentsCategory?
            let search: Bool
            
            typealias CategoryType = String
            typealias LatestPaymentsCategory = String
            
            enum _PaymentFlow: String, Decodable {
                
                case mobile              = "MOBILE"
                case qr                  = "QR"
                case standard            = "STANDARD_FLOW"
                case taxAndStateServices = "TAX_AND_STATE_SERVICE"
                case transport           = "TRANSPORT"
            }
        }
    }
}
