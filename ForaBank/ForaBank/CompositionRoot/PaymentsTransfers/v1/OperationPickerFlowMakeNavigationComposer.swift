//
//  OperationPickerFlowMakeNavigationComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.09.2024.
//

import PayHub

final class OperationPickerFlowMakeNavigationComposer {
    
    private let model: Model
    
    init(model: Model) {
        
        self.model = model
    }
}

extension OperationPickerFlowMakeNavigationComposer {
    
    func compose() -> MakeNavigation {
        
        return { element, dispatch, completion in
            
            switch element {
            case .exchange:
                let composer = CurrencyWalletViewModelComposer(model: self.model)
                let exchange = composer.compose(dismiss: { dispatch(.dismiss) })
                
                if let exchange {
                    completion(.exchange(exchange))
                } else {
                    completion(.status(.exchangeFailure))
                }
                
            case let .latest(latest):
                completion(.latest(.init(latest: latest)))
                
            case .templates:
                completion(.templates(.init()))
            }
        }
    }
    
    typealias MakeNavigation = (OperationPickerElement, @escaping Dispatch, @escaping (OperationPickerNavigation) -> Void) -> Void
    typealias Dispatch = (Event) -> Void
    typealias Event = PickerFlowEvent<OperationPickerElement, OperationPickerNavigation>
}
