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
    
    @Published private(set) var state: State
    
    private let reduce: Reduce
    
    init(
        initialState: State = false,
        reduce: @escaping Reduce
    ) {
        self.state = initialState
        self.reduce = reduce
    }
}

extension FastPaymentsSettingsViewModel {
    
    func event(_ event: Event) {
        
        reduce(state, event) { [weak self] in self?.state = $0 }
    }
}

extension FastPaymentsSettingsViewModel {
    
    typealias Reduce = (State, Event, @escaping (State) -> Void) -> Void
    typealias State = Bool
    
    enum Event {
        
        case appear
    }
}
