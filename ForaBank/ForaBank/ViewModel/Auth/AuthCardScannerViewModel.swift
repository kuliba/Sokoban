//
//  AuthCardScannerViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import Foundation

class AuthCardScannerViewModel: ObservableObject, Identifiable {

    let id = UUID()
    let scannedAction: (String) -> Void
    let dismissAction: () -> Void
    
    internal init(scannedAction: @escaping (String) -> Void, dismissAction: @escaping () -> Void) {
        self.scannedAction = scannedAction
        self.dismissAction = dismissAction
        
        //TODO: remove after tests
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            
            scannedAction("1111111111111111")
        }
    }
}
