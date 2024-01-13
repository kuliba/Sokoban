//
//  FastPaymentsSettingsViewModel.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import Combine
import Foundation

final class FastPaymentsSettingsViewModel: ObservableObject {
    
    @Published private(set) var state: State?
    
    private let reduce: Reduce
    
    init(
        state: State? = nil,
        reduce: @escaping Reduce
    ) {
        self.state = state
        self.reduce = reduce
    }
}

extension FastPaymentsSettingsViewModel {
    
    func event(_ event: Event) {
        
        reduce(state, event) { [weak self] in self?.state = $0 }
    }
}

extension FastPaymentsSettingsViewModel {
    
    struct State {
        
        #warning("combine inflight, informer, alert into one field?")
        var isInflight = false
        var userPaymentSettings: UserPaymentSettings?
        var alert: Alert?
        
        enum Alert {
            
            case serverError(String)
            case connectivityError
            case missingProduct
            case updateContractFailure
            case confirmSetBankDefault
        }
    }
    
    enum Event {
        
        case appear
        case activateContract
        case deactivateContract
        case resetError
        case setBankDefault
    }
}

extension FastPaymentsSettingsViewModel {
    
    typealias Reduce = (State?, Event, @escaping (State?) -> Void) -> Void
}
