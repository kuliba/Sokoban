//
//  RootViewModelFactory+makeLoadLatestOperations.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import Foundation

extension RootViewModelFactory {
    
    static func makeLoadLatestOperations(
        getAllLoadedCategories: @escaping (@escaping ([ServiceCategory]) -> Void) -> Void,
        getLatestPayments: @escaping ([ServiceCategory], @escaping LoadLatestOperationsCompletion) -> Void
    ) -> (CategorySet) -> LoadLatestOperations {
        
        return { categorySet in
            
            return { completion in
                
                switch categorySet {
                case .all:
                    getAllLoadedCategories { list in
                        #warning("add hardcoded: В данный момент блок “Перевести” не динамичен, поэтому последние операции для него, пока вызываем с фронта по типам: isOutsidePayments (за рубеж) и isPhonePayments (По номеру телефона)")
                        getLatestPayments(list, completion)
                    }
                    
                case let .list(list):
                    getLatestPayments(list, completion)
                }
            }
        }
    }
}
