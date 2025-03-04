//
//  RootViewModelFactory+makeTrailingToolbarItems.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.02.2025.
//

extension RootViewModelFactory {
    
    func makeTrailingToolbarItems(
        action: @escaping (MainViewModelAction.Toolbar) -> Void
    ) -> [NavigationBarButtonViewModel] {
        
        return [.init(icon: .ic24Bell) { action(.notifications) }]
    }
}
