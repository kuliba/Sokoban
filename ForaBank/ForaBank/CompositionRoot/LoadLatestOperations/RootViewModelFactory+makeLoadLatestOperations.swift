//
//  RootViewModelFactory+makeLoadLatestOperations.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import Foundation
import RemoteServices
import PayHubUI

extension RootViewModelFactory {
    
    typealias LoadLatestOperationsCompletion = (Result<[Latest], Error>) -> Void
    typealias LoadLatestOperations = (@escaping LoadLatestOperationsCompletion) -> Void
    
    static func makeLoadLatestOperations(
        getAllLoadedCategories: @escaping (@escaping LoadServiceCategoriesCompletion) -> Void,
        getLatestPayments: @escaping ([ServiceCategory], @escaping LoadLatestOperationsCompletion) -> Void
    ) -> (CategorySet) -> LoadLatestOperations {
        
        return { categorySet in
            
            return { completion in
                
                switch categorySet {
                case .all:
                    getAllLoadedCategories { getLatestPayments($0, completion) }
                    
                case let .list(list):
                    getLatestPayments(list, completion)
                }
            }
        }
    }
    
    typealias LatestPaymentServiceCategoryName = String
    
    typealias LoadServiceCategoriesCompletion = ([ServiceCategory]) -> Void
    typealias LoadServiceCategories = (@escaping LoadServiceCategoriesCompletion) -> Void
    
    @available(*, deprecated, message: "Use RootViewModelFactory.makeLoadLatestOperations with strong `getLatestPayments` API after hard-code for `isOutsidePayments` and `isPhonePayments` deprecation")
    func makeLoadLatestOperations(
        getAllLoadedCategories: @escaping (@escaping LoadServiceCategoriesCompletion) -> Void,
        getLatestPayments: @escaping ([LatestPaymentServiceCategoryName], @escaping LoadLatestOperationsCompletion) -> Void,
        hardcoded: [String] = ["isOutsidePayments", "isPhonePayments"]
    ) -> (CategorySet) -> LoadLatestOperations {
        
        return { categorySet in
            
            return { completion in
                
                switch categorySet {
                case .all:
                    getAllLoadedCategories { categories in
                        
#warning("add hardcoded: В данный момент блок “Перевести” не динамичен, поэтому последние операции для него, пока вызываем с фронта по типам: isOutsidePayments (за рубеж) и isPhonePayments (По номеру телефона)")
                        getLatestPayments(categories.latestPaymentsCategoryNames + hardcoded, completion)
                    }
                    
                case let .list(categories):
                    getLatestPayments(categories.latestPaymentsCategoryNames, completion)
                }
            }
        }
    }
}

private extension Array where Element == RemoteServices.ResponseMapper.ServiceCategory {
    
    var latestPaymentsCategoryNames: [String] {
        
        compactMap(\.latestPaymentsCategoryName)
    }
}

private extension RemoteServices.ResponseMapper.ServiceCategory {
    
    var latestPaymentsCategoryName: String? {
        
        switch latestPaymentsCategory {
        case .none:
            return .none
            
        case .charity:
            return "isCharityPayments"
            
        case .education:
            return "isEducationPayments"
            
        case .digitalWallets:
            return "isDigitalWalletsPayments"
            
        case .internet:
            return "isInternetPayments"
            
        case .mobile:
            return "isMobilePayments"
            
        case .networkMarketing:
            return "isNetworkMarketingPayments"
            
        case .repaymentLoansAndAccounts:
            return "isRepaymentLoansAndAccountsPayments"
            
        case .security:
            return "isServicePayments"
            
        case .service:
            return "isSecurityPayments"
            
        case .socialAndGames:
            return "isSocialAndGamesPayments"
            
        case .taxAndStateService:
            return "isTaxAndStateServicePayments"
            
        case .transport:
            return "isTransportPayments"
        }
    }
}
