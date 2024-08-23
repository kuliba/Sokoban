//
//  PaymentsTransfersToolbarContentInterface.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import Combine

public protocol PaymentsTransfersToolbarContentInterface {
    
    var selectionPublisher: AnyPublisher<PaymentsTransfersToolbarState.Selection, Never> { get }
    
    func dismiss()
}
