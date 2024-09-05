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
    
    enum GetServiceCategoryListError: Error {
        
        case emptyCategoryList
    }
}

private extension ResponseMapper.GetServiceCategoryListResponse {
    
    init(_ data: ResponseMapper._Data) throws {
        
        guard !data.categoryGroupList.isEmpty
        else {
            throw ResponseMapper.GetServiceCategoryListError.emptyCategoryList
        }
        
        self.init(
            categoryGroupList: data.categoryGroupList.map(Category.init),
            serial: data.serial
        )
    }
}

private extension ResponseMapper.GetServiceCategoryListResponse.Category {
    
    init(_ category: ResponseMapper._Data._Category) {

        self.init(
            latestPaymentsCategory: category.latestPaymentsCategory.map { .init($0) },
            md5Hash: category.md5hash,
            name: category.name,
            ord: category.ord,
            paymentFlow: .init(category.paymentFlow),
            search: category.search,
            type: .init(category.type)
        )
    }
}

private extension ResponseMapper.GetServiceCategoryListResponse.Category.CategoryType {
    
    init(_ paymentFlow: ResponseMapper._Data._Category.CategoryType) {
        
        switch paymentFlow {
        case .charity:                   self = .charity
        case .digitalWallets:            self = .digitalWallets
        case .education:                 self = .education
        case .housingAndCommunalService: self = .housingAndCommunalService
        case .internet:                  self = .internet
        case .mobile:                    self = .mobile
        case .networkMarketing:          self = .networkMarketing
        case .qr:                        self = .qr
        case .repaymentLoansAndAccounts: self = .repaymentLoansAndAccounts
        case .security:                  self = .security
        case .socialAndGames:            self = .socialAndGames
        case .transport:                 self = .transport
        case .taxAndStateService:        self = .taxAndStateService
        }
    }
}

private extension ResponseMapper.GetServiceCategoryListResponse.Category.LatestPaymentsCategory {
    
    init(_ category: ResponseMapper._Data._Category.LatestPaymentsCategory) {
        
        switch category {
        case .isCharityPayments:                   self = .charity
        case .isEducationPayments:                 self = .education
        case .isDigitalWalletsPayments:            self = .digitalWallets
        case .isInternetPayments:                  self = .internet
        case .isMobilePayments:                    self = .mobile
        case .isNetworkMarketingPayments:          self = .networkMarketing
        case .isRepaymentLoansAndAccountsPayments: self = .repaymentLoansAndAccounts
        case .isServicePayments:                   self = .service
        case .isSecurityPayments:                  self = .security
        case .isSocialAndGamesPayments:            self = .socialAndGames
        case .isTaxAndStateServicePayments:        self = .taxAndStateService
        case .isTransportPayments:                 self = .transport
        }
    }
}

private extension ResponseMapper.GetServiceCategoryListResponse.Category.PaymentFlow {
    
    init(_ paymentFlow: ResponseMapper._Data._Category.PaymentFlow) {
        
        switch paymentFlow {
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
            let paymentFlow: PaymentFlow
            let latestPaymentsCategory: LatestPaymentsCategory?
            let search: Bool
            
            enum CategoryType: String, Decodable {
                
                case charity
                case digitalWallets
                case education
                case housingAndCommunalService
                case internet
                case mobile
                case networkMarketing
                case qr
                case repaymentLoansAndAccounts
                case security
                case socialAndGames
                case transport
                case taxAndStateService
            }
            
            enum LatestPaymentsCategory: String, Decodable {
                
                case isCharityPayments
                case isEducationPayments
                case isDigitalWalletsPayments
                case isInternetPayments
                case isMobilePayments
                case isNetworkMarketingPayments
                case isRepaymentLoansAndAccountsPayments
                case isServicePayments
                case isSecurityPayments
                case isSocialAndGamesPayments
                case isTaxAndStateServicePayments
                case isTransportPayments
            }
            
            enum PaymentFlow: String, Decodable {
                
                case mobile              = "MOBILE"
                case qr                  = "QR"
                case standard            = "STANDARD_FLOW"
                case taxAndStateServices = "TAX_AND_STATE_SERVICE"
                case transport           = "TRANSPORT"
            }
        }
    }
}
