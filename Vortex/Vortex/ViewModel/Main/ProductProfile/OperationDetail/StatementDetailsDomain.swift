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
    
    struct State {
        
        let content: Content
        var detailsState: DetailsState
        
        typealias DetailsState = StateMachines.LoadState<Details, Failure>
    }
    
    typealias Event = StateMachines.LoadEvent<Details, Failure>
    typealias Effect = StateMachines.LoadEffect
    
    // MARK: - Logic
    
    typealias Reducer = StateMachines.LoadReducer<Details, Failure>
    typealias EffectHandler = StateMachines.LoadEffectHandler<Details, Failure>
    
    // MARK: - Types
    
    struct Content {
        
        let logo: String? // Лого- md5hash из getCardStatementForPeriod_V3/getAccountStatementForPeriod_V3
        let name: String? // Наименование получателя-    foreignName из getCardStatementForPeriod_V3/getAccountStatementForPeriod_V3
    
        let details: OperationDetailDomain.Model
    }
    
    struct Details {
        
        let details: OperationDetailDomain.Model
        let document: C2GDocumentButtonDomain.Binder?
    }
    
    typealias Failure = Error
}
