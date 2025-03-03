//
//  RootViewModelFactory+makeSADetailsButton.swift
//  Vortex
//
//  Created by Andryusina Nataly on 28.02.2025.
//

import Foundation

extension RootViewModelFactory {
    
    @inlinable
    func makeDetailsButton(
        load: @escaping (@escaping (Result<OpenSavingsAccountCompleteDomain.Details, Error>) -> Void) -> Void
    ) -> OperationDetailSADomain.Model {
        
        return OperationDetailSADomain.Model.makeStateMachine(
            load: load,
            scheduler: schedulers.main
        )
    }
}

