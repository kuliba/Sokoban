//
//  PaymentsConfirmViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 10.03.2022.
//

import Foundation
import SwiftUI
import Combine

class PaymentsConfirmViewModel: PaymentsOperationViewModel {
    
    override func createFooter(from parameters: [ParameterRepresentable]) -> PaymentsOperationViewModel.FooterViewModel? {
        
        return .button(.init(title: "Продолжить", isEnabled: false, action: { [weak self] in
            self?.action.send(PaymentsOperationViewModelAction.Confirm())
        }))
    }
}
