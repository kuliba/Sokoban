//
//  AppState.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 27.04.2024.
//

struct AppState: Equatable {
    
    let rootState: RootState
    let tabState: MainTabState
    let paymentsState: PaymentsState
}
