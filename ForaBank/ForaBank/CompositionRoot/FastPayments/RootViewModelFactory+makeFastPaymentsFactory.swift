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
                
                let reducer = MainQueueReducerDecorator(
                    reducer: FastPaymentsSettingsReducer()
                )
                
                return .init(reduce: reducer.reduce(_:_:_:))
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
final class FastPaymentsSettingsReducer {}

extension FastPaymentsSettingsReducer: Reducer {
    
    func reduce(
        _ state: State,
        _ event: Event,
        _ completion: @escaping (State) -> Void
    ) {
        switch event {
        case .appear:
            
            completion(true)
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 2,
                execute: { completion(false) }
            )
        }
    }
}
 
extension FastPaymentsSettingsReducer {
    
    typealias State = FastPaymentsSettingsViewModel.State
    typealias Event = FastPaymentsSettingsViewModel.Event
}
