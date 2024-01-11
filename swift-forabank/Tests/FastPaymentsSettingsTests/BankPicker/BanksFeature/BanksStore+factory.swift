//
//  BanksStore+factory.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

// factory
extension BanksStore {
    
    static func makeBanksReducerBanksStore(
        initialState: State,
        externalStateUpdate: ExternalStateUpdate,
        applySelection: @escaping BanksReducer.ApplySelection
    ) -> BanksStore {
        
        let reducer = BanksReducer(
            applySelection: applySelection
        )
        
        return .init(
            initialState: initialState,
            externalStateUpdate: externalStateUpdate,
            reduce: reducer.reduce
        )
    }
}
