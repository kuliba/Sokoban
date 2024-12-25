//
//  AnywayElementModelMapper+makeCheckboxViewModel.swift
//  Vortex
//
//  Created by Igor Malyarov on 25.12.2024.
//

import AnywayPaymentDomain
import Foundation

extension AnywayElementModelMapper {
    
    func makeCheckboxViewModel(
        with parameter: AnywayElement.Parameter,
        event: @escaping (AnywayPaymentEvent) -> Void
    ) -> Node<RxCheckboxViewModel> {
        
        let model = RxCheckboxViewModel(
            initialState: .init(
                isChecked: parameter.field.value == "1",
                text: parameter.uiAttributes.title
            ),
            reduce: {
                state, event in
                
                switch event {
                case .toggle:
                    return (state.toggled(), nil)
                }
            },
            handleEffect: { effect, _ in switch effect {}}
        )
        let cancellable = model.$state
            .map { $0.isChecked ? "1" : "0" }
        // TODO: - inject scheduler
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { event(.setValue($0, for: parameter.uiComponent.id)) }
        
        return .init(model: model, cancellable: cancellable)
    }
}

extension CheckboxState {
    
    func toggled() -> Self {
        
        return .init(isChecked: !isChecked, text: text)
    }
}
