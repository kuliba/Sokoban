//
//  PaymentsTransfersToolbarFlowInterface.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import Combine

public protocol PaymentsTransfersToolbarFlowInterface {
    
    var dismissEventPublisher: AnyPublisher<Void, Never> { get }
    
    func receive(selection: PaymentsTransfersToolbarState.Selection)
}
