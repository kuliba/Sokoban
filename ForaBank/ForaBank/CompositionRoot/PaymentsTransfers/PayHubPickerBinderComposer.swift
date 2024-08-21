//
//  PayHubPickerBinderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

import CombineSchedulers
import Foundation
import PayHub

final class PayHubPickerBinderComposer {
    
    private let makeContent: MakeContent
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(
        makeContent: @escaping MakeContent,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.makeContent = makeContent
        self.scheduler = scheduler
    }
    
    typealias MakeContent = () -> PayHubPickerContent
}

extension PayHubPickerBinderComposer {
    
    func compose() -> PayHubPickerBinder {
        
        let content = makeContent()
        let flow = makeFlow()
        
        return .init(
            content: content,
            flow: flow,
            bind: { content, flow in content.$state.sink { _ in _ = flow }}
//            bind: { content, flow in
//                
//                content.$state
//                    .map(\.selected)
//                    .sink { flow.event(.select($0)) }
//            }
        )
    }
}

// MARK: - Flow

private extension PayHubPickerBinderComposer {
    
    func makeFlow() -> PayHubPickerFlow {
        
    }
}
