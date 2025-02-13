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
            list: data.categoryGroupList.compactMap(ResponseMapper.ServiceCategory.init),
            serial: data.serial
        )
    }
}

private extension ResponseMapper.ServiceCategory {
    
    init?(_ category: ResponseMapper._Data._Category) {
        
        guard let paymentFlow = category.paymentFlow.flow
        else { return nil }
        
        self.init(
            latestPaymentsCategory: category.latestPaymentsCategory.map { .init($0) },
            md5Hash: category.md5hash,
            name: category.name,
            ord: category.ord,
            paymentFlow: paymentFlow,
            hasSearch: category.search,
            type: .init(category.type)
        )
    }
}

private extension ResponseMapper._Data._Category._PaymentFlow {
    
    var flow: ResponseMapper.ServiceCategory.PaymentFlow? {
        
        switch self {
        case "MOBILE":                return .mobile
        case "QR":                    return .qr
        case "STANDARD_FLOW":         return .standard
        case "TAX_AND_STATE_SERVICE": return .taxAndStateServices
        case "TRANSPORT":             return .transport
        default:                      return nil
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
            typealias _PaymentFlow = String
        }
    }
}
