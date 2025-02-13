//
//  RootViewModelFactory+makeTrailingToolbarItems.swift
//  Vortex
//
//  Created by Igor Malyarov on 11.02.2025.
//

extension RootViewModelFactory {
    
    func makeTrailingToolbarItems(
        _ flag: C2GFlag
    ) -> (@escaping (MainViewModelAction.Toolbar) -> Void) -> [NavigationBarButtonViewModel] {
        
        return { action in
            
            let notificationsButton = NavigationBarButtonViewModel(
                icon: .ic24Bell, 
                action: { action(.notifications) }
            )
            let scanQRButton = flag.isActive ? NavigationBarButtonViewModel(
                title: "Сканировать",
                icon: .ic24BarcodeScanner2,
                action: { action(.scanQR) }
            ) : nil
            
            return [scanQRButton, notificationsButton].compactMap { $0 }
        }
    }
}
