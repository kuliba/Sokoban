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
            return .init(
                fastPaymentsViewModel: .new({ _ in .init(
                    reduce: { state, event, completion in
                        
                        switch event {
                        case .appear:
                            
                            completion(true)
                            
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 2,
                                execute: { completion(false) }
                            )
                        }
                    }
                )})
            )
            
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
