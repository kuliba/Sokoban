//
//  FastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

import UserAccountNavigationComponent

struct FastPaymentsFactory {
    
    let fastPaymentsViewModel: FastPaymentsViewModel
}

extension FastPaymentsFactory {
    
    enum FastPaymentsViewModel {
        
        typealias CloseAction = () -> Void
        typealias MakeLegacyFastPaymentsViewModel = ([FastPaymentContractFindListDatum]?, @escaping CloseAction) -> MeToMeSettingView.ViewModel
        
        typealias MakeNewFastPaymentsViewModel = (AnySchedulerOfDispatchQueue) -> FastPaymentsSettingsViewModel
        
        case legacy(MakeLegacyFastPaymentsViewModel)
        case new(MakeNewFastPaymentsViewModel)
    }
}
