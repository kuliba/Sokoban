//
//  AnywayElementModelMapper+makeSelectorViewModel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.08.2024.
//

import AnywayPaymentDomain
import OptionalSelectorComponent
import SwiftUI

extension AnywayElementModelMapper {
    
    func makeSelectorViewModel(
        initialState: OptionalSelectorState<Option>,
        and parameter: AnywayElement.UIComponent.Parameter,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> ObservingSelectorViewModel {
        
        let reducer = OptionalSelectorReducer<Option>(
            predicate: { $0.value.localizedCaseInsensitiveContains($1) }
        )
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: { _,_ in },
            observe: {
                
                if let key = $0.selected?.key {
                    
                    event(.setValue(key, for: parameter.id))
                }
            }
        )
    }
    
    typealias Option = AnywayElement.UIComponent.Parameter.ParameterType.Option
}
