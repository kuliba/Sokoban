//
//  RootViewModelFactory+makeFastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

import Foundation

extension RootViewModelFactory {
    
    static func makeFastPaymentsFactory(
        model: Model,
        fastPaymentsSettingsFlag: FastPaymentsSettingsFlag
    ) -> FastPaymentsFactory {
        
        switch fastPaymentsSettingsFlag.rawValue {
        case .active:
            return .init(fastPaymentsViewModel: .new({ _ in
                
                // let getContractConsentAndDefaultService = ...
                let reducer = FastPaymentsSettingsReducer(
                    getContractConsentAndDefault: { completion in
                        
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + 2,
                            execute: { completion(.init()) }
                        )
                    }
                )
                
                let decorated = MainQueueReducerDecorator(
                    reducer: reducer
                )
                
                return .init(reduce: decorated.reduce(_:_:_:))
            }))
            
        case .inactive:
            return .init(
                fastPaymentsViewModel: .legacy({
                    
                    MeToMeSettingView.ViewModel(
                        model: $0,
                        newModel: model,
                        closeAction: $1
                    )
                })
            )
        }
    }
}

#warning("move to module")
final class FastPaymentsSettingsReducer {
    
    // abc: a service with 3 endpoints under the hood
    private let getContractConsentAndDefault: GetContractConsentAndDefault
    
    init(
        getContractConsentAndDefault: @escaping GetContractConsentAndDefault
    ) {
        self.getContractConsentAndDefault = getContractConsentAndDefault
    }
}

extension FastPaymentsSettingsReducer: Reducer {
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ completion: @escaping (State) -> Void
    ) {
        switch event {
        case .appear:
            
            completion(true)
            
            getContractConsentAndDefault { response in
                
                completion(false)
            }
        }
    }
}
 
extension FastPaymentsSettingsReducer {
    
    struct ContractConsentAndDefaultResponse {}
    typealias GetContractConsentAndDefault = (@escaping (ContractConsentAndDefaultResponse) -> Void) -> Void
    
    typealias State = FastPaymentsSettingsViewModel.State
    typealias Event = FastPaymentsSettingsViewModel.Event
}
