//
//  PayHubPickerBinder.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 16.08.2024.
//

import Combine

final class PayHubPickerBinder {
    
    let content: PayHubPickerContent
    let flow: PayHubPickerFlow
    
    private let cancellable: AnyCancellable
    
    init(
        content: PayHubPickerContent,
        flow: PayHubPickerFlow
    ) {
        self.content = content
        self.flow = flow
        
        cancellable = content.$state
            .map(\.selected)
            .sink { flow.event(.select($0)) }
    }
}
