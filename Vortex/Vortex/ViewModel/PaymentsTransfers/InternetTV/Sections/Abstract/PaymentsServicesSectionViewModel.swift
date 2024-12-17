//
//  PaymentsServicesSectionViewModel.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 24.03.2023.
//

import Foundation
import Combine

class PaymentsServicesSectionViewModel: Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    var id: String { type.rawValue }
    var type: Kind { fatalError("implement in subclass") }
    let mode: Mode
    
    internal let model: Model
    internal var bindings = Set<AnyCancellable>()
    
    enum Mode {
        
        case fastPayment
        case select
    }
    
    init(model: Model, mode: Mode) {
        
        self.model = model
        self.mode = mode
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "init type: \(type)")
    }
    
    deinit {
        
        LoggerAgent.shared.log(level: .debug, category: .ui, message: "deinit type: \(type)")
    }
}

//MARK: - Types

extension PaymentsServicesSectionViewModel {
    
    enum Kind: String {
        
        case latestPayments
    }
}

//MARK: - Action

enum PaymentsServicesSectionViewModelAction {}
