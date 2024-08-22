//
//  OperationPickerFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import CombineSchedulers
import Foundation

final class OperationPickerFlowComposer {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(scheduler: AnySchedulerOf<DispatchQueue>) {
     
        self.scheduler = scheduler
    }
}

extension OperationPickerFlowComposer {
    
    func compose() -> OperationPickerFlow {
        
    }
}
