//
//  StatementDetailsDomain.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.03.2025.
//

import RxViewModel
import StateMachines

/// A namespace.
enum StatementDetailsDomain {}

extension StatementDetailsDomain {
    
    // MARK: - Model
    
    typealias Model = RxViewModel<State, Event, Effect>
    
    // MARK: - Domain
    
    typealias State = StateMachines.LoadState<Details, Error>
    typealias Event = StateMachines.LoadEvent<Details, Error>
    typealias Effect = StateMachines.LoadEffect
    
    // MARK: - Logic
    
    typealias Reducer = StateMachines.LoadReducer<Details, Error>
    typealias EffectHandler = StateMachines.LoadEffectHandler<Details, Error>
    
    // MARK: - Types
    
    struct Details {
        
        let content: Content
        let details: OperationDetailDomain.Model
        let document: C2GDocumentButtonDomain.Binder?
        
        struct Content: Equatable {
            
            let logo: String? // Лого- md5hash из getCardStatementForPeriod_V3/getAccountStatementForPeriod_V3
            let name: String? // Наименование получателя-    foreignName из getCardStatementForPeriod_V3/getAccountStatementForPeriod_V3
        }
    }
}
