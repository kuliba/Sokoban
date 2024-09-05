//
//  OperationPickerFlowMakeNavigationComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.09.2024.
//

import PayHub

final class OperationPickerFlowMakeNavigationComposer {}

extension OperationPickerFlowMakeNavigationComposer {
    
    func compose() -> MakeNavigation {
        
        return { element, dispatch, completion in
            
            switch element {
            case .exchange:
                completion(.exchange(.init()))
            
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
