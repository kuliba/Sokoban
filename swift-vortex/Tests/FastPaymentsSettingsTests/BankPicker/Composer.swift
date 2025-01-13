//
//  Composer.swift
//
//
//  Created by Igor Malyarov on 31.12.2023.
//

import Combine

final class Composer {
    
    let store: Store<State, Event>
    let banksStore: BanksStore
    
    init(
        store: Store<State, Event>,
        factory: BanksStoreFactory
    ) {
        self.store = store
        
        self.banksStore = factory(
            store.state.banks,
            store.$state.map(\.banks).eraseToAnyPublisher(),
            { [weak store] in
                
                store?.event(.banks(.applySelection($0)))
            }
        )
    }
}

extension Composer {
    
    typealias BanksStoreFactory = (BanksStore.State, BanksStore.ExternalStateUpdate, @escaping BanksReducer.ApplySelection) -> BanksStore
}
