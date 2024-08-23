//
//  PaymentsTransfersToolbarBinder.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import Combine

public typealias PaymentsTransfersToolbarBinder = Binder

public extension PaymentsTransfersToolbarBinder
where Content: PaymentsTransfersToolbarContentInterface,
      Flow: PaymentsTransfersToolbarFlowInterface {
    
    convenience init(content: Content, flow: Flow) {
        
        self.init(content: content, flow: flow) { content, flow in
            
            let dismiss = flow.dismissEventPublisher
                .sink { _ in content.dismiss() }
            let select = content.selectionPublisher
                .sink { flow.receive(selection: $0) }
            
            return [dismiss, select]
        }
    }
}
