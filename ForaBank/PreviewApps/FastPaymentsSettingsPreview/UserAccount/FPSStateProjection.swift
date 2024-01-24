//
//  FPSStateProjection.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 24.01.2024.
//

struct FPSStateProjection: Equatable {
    
    let state: State
    let status: Status?
    
    enum State: Equatable {
        
        case notLoaded
        case contracted, missingContract
        case failure(Failure)
    }
    
    enum Status: Equatable {
        
        case inflight
        case failure(Failure)
        case missingProduct
        case confirmSetBankDefault
        case setBankDefault
        case setBankDefaultSuccess
        case updateContractFailure
    }
    
    enum Failure: Error, Equatable {
        
        case connectivityError
        case serverError(String)
    }
}
