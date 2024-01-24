//
//  FastPaymentsSettingsState+projection.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 24.01.2024.
//

import FastPaymentsSettings

extension FastPaymentsSettingsState {
    
    var projection: FPSStateProjection {
        
        .init(
            state: .init(settings: userPaymentSettings),
            status: status.map(FPSStateProjection.Status.init(status:))
        )
    }
}

private extension FPSStateProjection.State {
    
    init(settings: UserPaymentSettings?) {
        
        switch settings {
        case .contracted:
            self = .contracted
            
        case .missingContract:
            self = .missingContract
            
        case let .failure(failure):
            switch failure {
            case .connectivityError:
                self = .failure(.connectivityError)
                
            case let .serverError(message):
                self = .failure(.serverError(message))
            }
            
        case nil:
            self = .notLoaded
        }
    }
}

private extension FPSStateProjection.Status {
    
    init(status: FastPaymentsSettingsState.Status) {
        
        switch status {
        case .inflight:
            self = .inflight
            
        case let .serverError(message):
            self = .failure(.serverError(message))
            
        case .connectivityError:
            self = .failure(.connectivityError)
            
        case .missingProduct:
            self = .missingProduct
            
        case .updateContractFailure:
            self = .updateContractFailure
            
        case .setBankDefault:
            self = .setBankDefault
            
        case .setBankDefaultSuccess:
            self = .setBankDefaultSuccess
            
        case .confirmSetBankDefault:
            self = .confirmSetBankDefault
        }
    }
}
