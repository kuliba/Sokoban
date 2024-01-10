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

#warning("replace with implementation from module")
import Foundation

final class FastPaymentsSettingsViewModel: ObservableObject {
    
    @Published private(set) var inFlight: Bool
    
    init(isLoading: Bool = true) {
        
        self.inFlight = isLoading
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2,
            execute: { [weak self] in self?.inFlight = false }
        )
    }
}
