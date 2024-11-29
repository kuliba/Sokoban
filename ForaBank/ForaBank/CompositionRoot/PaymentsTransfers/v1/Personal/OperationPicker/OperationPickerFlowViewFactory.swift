//
//  OperationPickerFlowViewFactory.swift
//
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub

struct OperationPickerFlowViewFactory<ContentView, DestinationView> {
    
    let makeContent: MakeContent
    let makeDestination: MakeDestination
    
    init(
        makeContent: @escaping MakeContent,
        makeDestination: @escaping MakeDestination
    ) {
        self.makeContent = makeContent
        self.makeDestination = makeDestination
    }
}

extension OperationPickerFlowViewFactory {
    
    typealias MakeContent = () -> ContentView
    
    typealias MakeDestination = (OperationPickerDomain.Navigation.Destination) -> DestinationView
}
