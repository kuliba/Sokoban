//
//  FastPaymentsSettingsReducer.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

final class FastPaymentsSettingsReducer {
    
    private let getContractConsentAndDefault: GetContractConsentAndDefault
    
    init(
        getContractConsentAndDefault: @escaping GetContractConsentAndDefault
    ) {
        self.getContractConsentAndDefault = getContractConsentAndDefault
    }
}

extension FastPaymentsSettingsReducer {
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ completion: @escaping (State) -> Void
    ) {
        switch event {
        case .appear:
            switch state {
            case .none:
                completion(.init(
                    inflight: true
                ))
                
                getContractConsentAndDefault {
                    
                    completion(.init(
                        contractConsentAndDefault: $0
                    ))
                }
                
            default:
                completion(state)
            }
        }
    }
}

extension FastPaymentsSettingsReducer {
    
    typealias GetContractConsentAndDefault = (@escaping (ContractConsentAndDefault) -> Void) -> Void
    
    typealias State = FastPaymentsSettingsViewModel.State?
    typealias Event = FastPaymentsSettingsViewModel.Event
}
