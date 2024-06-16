//
//  AnywayTransactionViewModel+ext.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import CombineSchedulers
import ForaTools

public extension AnywayTransactionViewModel
where DocumentStatus: Equatable,
      Response: Equatable {
    
    convenience init(
        transaction: State.Transaction,
        mapToModel: @escaping MapToModel,
        reduce: @escaping Reduce,
        handleEffect: @escaping HandleEffect,
        observe: @escaping Observe,
        scheduler: AnySchedulerOfDispatchQueue = .main
    ) {
        self.init(
            transaction: transaction,
            mapToModel: mapToModel,
            reduce: reduce,
            handleEffect: handleEffect,
            observe: observe,
            predicate: ==,
            scheduler: scheduler
        )
    }
}
