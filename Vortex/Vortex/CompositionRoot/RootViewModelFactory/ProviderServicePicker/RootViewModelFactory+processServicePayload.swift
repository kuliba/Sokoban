//
//  RootViewModelFactory+processServicePayload.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.12.2024.
//

extension RootViewModelFactory {
    
    func process(
        payload: ProcessServicePayload,
        completion: @escaping AnywayFlowModelCompletion
    ) {
        initiateAnywayPayment(payload: payload.source, completion: completion)
    }
    
    struct ProcessServicePayload: Equatable {
        
        let item: ServicePickerItem
        let `operator`: UtilityPaymentProvider
    }
}

// MARK: - Adapters

private extension RootViewModelFactory.ProcessServicePayload {
    
    var source: AnywayPaymentSourceParser.Source {
        
        if item.isOneOf {
            return .oneOf(item.service, `operator`)
        } else {
            return .single(item.service, `operator`)
        }
    }
}
