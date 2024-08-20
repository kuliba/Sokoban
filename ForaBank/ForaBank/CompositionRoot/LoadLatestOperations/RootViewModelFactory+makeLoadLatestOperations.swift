//
//  RootViewModelFactory+makeLoadLatestOperations.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import Foundation

extension RootViewModelFactory {
        
    static func makeLoadLatestOperations(
        _ categorySet: CategorySet
    ) -> (@escaping LoadLatestOperationsCompletion) -> Void {
        
        switch categorySet {
        case .all:
            return { _ in }
        }
    }
}
