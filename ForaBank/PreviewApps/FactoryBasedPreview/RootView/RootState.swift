//
//  RootState.swift
//  FactoryBasedPreview
//
//  Created by Igor Malyarov on 24.04.2024.
//

struct RootState {
    
    var payments: PaymentsState = .init()
    var spinner: SpinnerState = .off
    var tab: MainTabState = .main
}
