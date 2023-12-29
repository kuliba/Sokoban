//
//  RootViewModelFactory+makeFastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

extension RootViewModelFactory {
    
    static func makeFastPaymentsFactory(
        model: Model
    ) -> FastPaymentsFactory {
        
        .init(
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
