//
//  PayHubPickerBinderComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 20.08.2024.
//

final class PayHubPickerBinderComposer {}

extension PayHubPickerBinderComposer {
    
    func compose() -> PayHubPickerBinder {
        
        return .init(
            content: makeContent(),
            flow: makeFlow()
            //    bind: { content, flow in
            //
            //        content.$state
            //            .map(\.selected)
            //            .sink { flow.event(.select($0)) }
            //    }
        )
    }
}

// MARK: - Content

private extension PayHubPickerBinderComposer {
    
    func makeContent() -> PayHubPickerContent {
        
    }
}

// MARK: - Flow

private extension PayHubPickerBinderComposer {
    
    func makeFlow() -> PayHubPickerFlow {
        
    }
}
