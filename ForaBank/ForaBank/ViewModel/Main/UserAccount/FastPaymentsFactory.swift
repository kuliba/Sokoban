//
//  FastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

struct FastPaymentsFactory {
    
    let fastPaymentsViewModel: FastPaymentsViewModel
}

extension FastPaymentsFactory {
    
    enum FastPaymentsViewModel {
        
        typealias CloseAction = () -> Void
        typealias MakeLegacyFastPaymentsViewModel = ([FastPaymentContractFindListDatum]?, @escaping CloseAction) -> MeToMeSettingView.ViewModel
        
        typealias MakeNewFastPaymentsViewModel = ([FastPaymentContractFindListDatum]) -> FastPaymentsSettingsViewModel
        
        case legacy(MakeLegacyFastPaymentsViewModel)
        case new(MakeNewFastPaymentsViewModel)
    }
}

#warning("extract to module")
struct FastPaymentsSettingsViewModel {}
