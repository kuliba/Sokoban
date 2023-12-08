//
//  File.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

import Foundation

public final class SberQRConfirmPaymentViewModel: ObservableObject {
    
    public typealias State = SberQRConfirmPaymentState
    
    @Published public private(set) var state: State
    
    public init(
        initialState: State,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
    }
}
