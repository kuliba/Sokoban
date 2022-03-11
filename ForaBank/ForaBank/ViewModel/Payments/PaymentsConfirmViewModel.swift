//
//  PaymentsConfirmViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 10.03.2022.
//

import Foundation
import SwiftUI
import Combine

class PaymentsConfirmViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()

    @Published var header: HeaderViewModel
    @Published var items: [PaymentsParameterViewModel]
    
    var operation: Payments.Operation
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(header: HeaderViewModel, items: [PaymentsParameterViewModel], operation: Payments.Operation = .emptyMock, model: Model = .emptyMock) {
        
        self.header = header
        self.items = items
        self.operation = operation
        self.model = model
    }
    
//    internal init(_ model: Model, operation: Payments.Operation, dismissAction: @escaping () -> Void) throws {
//
//        self.model = model
//        self.header = .init(title: operation.service.name, action: dismissAction)
//        self.items = []
//        self.operation = operation
//
//    }
    
}

extension PaymentsConfirmViewModel {
    
    struct HeaderViewModel {
        
        let title: String
        let backButtonIcon = Image("back_button")
        let action: () -> Void
    }
}
