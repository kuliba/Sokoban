//
//  PayHubBinder.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Combine

final class PayHubBinder {
    
    let content: PayHubContent
    let flow: PayHubFlow
    
    private let cancellable: AnyCancellable
    
    init(
        content: PayHubContent,
        flow: PayHubFlow
    ) {
        self.content = content
        self.flow = flow
        
        cancellable = content.$state
            .map(\.?.selected)
            .sink { flow.event(.select($0)) }
    }
}
