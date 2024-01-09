//
//  RootViewModelFactory+makeFastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

extension RootViewModelFactory {
    
    static func makeFastPaymentsFactory(
        model: Model,
        fastPaymentsSettingsFlag: FastPaymentsSettingsFlag
    ) -> FastPaymentsFactory {
        
        switch fastPaymentsSettingsFlag.rawValue {
        case .active:
            return .init(
                fastPaymentsViewModel: .new({ _ in .init() })
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
