//
//  PaymentsSuccessViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 03.03.2022.
//

import SwiftUI
import Combine

class PaymentsSuccessViewModel: ObservableObject {
    
    let header: HeaderViewModel
    @Published var optionButtons: [PaymentsSuccessOptionButtonViewModel]
    let actionButton: ButtonSimpleView.ViewModel
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    internal init(header: HeaderViewModel,
                  optionButtons: [PaymentsSuccessOptionButtonViewModel],
                  actionButton: ButtonSimpleView.ViewModel, model: Model = .emptyMock) {
        
        self.header = header
        self.optionButtons = optionButtons
        self.actionButton = actionButton
        self.model = model
    }
    
    convenience init(_ model: Model, paymentSuccess: Payments.Success, dismissAction: @escaping () -> Void) {
        
        self.init(header: .init(with: paymentSuccess), optionButtons: [], actionButton: .init(title: "На главную", style: .red, action: dismissAction), model: model)
    }
}

extension PaymentsSuccessViewModel {
    
    struct HeaderViewModel {
        
        let stateIcon: Image
        let title: String
        let description: String
        let operatorIcon: Image?
        
        internal init(stateIcon: Image, title: String, description: String, operatorIcon: Image?) {
            
            self.stateIcon = stateIcon
            self.title = title
            self.description = description
            self.operatorIcon = operatorIcon
        }
        
        init(with paymentSuccess: Payments.Success) {
            
            //TODO: real implementation required
            let formatter: NumberFormatter = .currency(with: "₽")
            let amount = formatter.string(from: NSNumber(value: paymentSuccess.amount)) ?? "\(paymentSuccess.amount)"
            
            self.init(stateIcon: Image("OkOperators"), title: paymentSuccess.status.description, description: amount, operatorIcon: paymentSuccess.icon?.image)
        }
    }
}

class PaymentsSuccessOptionButtonViewModel: Identifiable {
    
    let id: UUID
    let icon: Image
    let title: String
    let action: () -> Void
    
    internal init(id: UUID, icon: Image, title: String, action: @escaping () -> Void) {
        self.id = id
        self.icon = icon
        self.title = title
        self.action = action
    }
}
