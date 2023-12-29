//
//  FastPaymentsFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.12.2023.
//

struct FastPaymentsFactory {
    
    let makeFastPaymentsViewModel: MakeFastPaymentsViewModel
}

extension FastPaymentsFactory {
    
    typealias CloseAction = () -> Void
    typealias FastPaymentsViewModel = MeToMeSettingView.ViewModel
    // TODO: remove unnecessary details
    typealias MakeFastPaymentsViewModel = ([FastPaymentContractFindListDatum]?, @escaping CloseAction) -> FastPaymentsViewModel
}
