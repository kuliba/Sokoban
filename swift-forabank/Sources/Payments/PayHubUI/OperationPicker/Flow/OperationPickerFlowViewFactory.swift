//
//  OperationPickerFlowViewFactory.swift
//  
//
//  Created by Igor Malyarov on 26.08.2024.
//

import PayHub

public struct OperationPickerFlowViewFactory<ContentView, DestinationView, Exchange, LatestFlow, Status, Templates> {
    
    public let makeContent: MakeContent
    public let makeDestination: MakeDestination
    
    public init(
        makeContent: @escaping MakeContent,
        makeDestination: @escaping MakeDestination
    ) {
        self.makeContent = makeContent
        self.makeDestination = makeDestination
    }
}

public extension OperationPickerFlowViewFactory {
    
    typealias MakeContent = () -> ContentView
    
    typealias Destination = OperationPickerNavigation<Exchange, LatestFlow, Status, Templates>
    typealias MakeDestination = (Destination) -> DestinationView
}
