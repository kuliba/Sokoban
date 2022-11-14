//
//  ContactsSectionViewModel.swift
//  ForaBank
//
//  Created by Max Gribov on 11.11.2022.
//

import Foundation
import Combine

class ContactsSectionViewModel: Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    var id: String { type.rawValue }
    var type: Kind { fatalError("imlement in subclass") }
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

extension ContactsSectionViewModel {
    
    enum Kind: String {
        
        case latestPayments
        case contacts
        case banksPreferred
        case banks
        case countries
    }
}

//MARK: - Action

enum ContactsSectionViewModelAction {}
