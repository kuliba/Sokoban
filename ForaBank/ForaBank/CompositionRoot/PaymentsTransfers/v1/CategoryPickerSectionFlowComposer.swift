//
//  CategoryPickerSectionFlowComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.08.2024.
//

import CombineSchedulers
import Foundation

final class CategoryPickerSectionFlowComposer {
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    
    init(scheduler: AnySchedulerOf<DispatchQueue>) {
     
        self.scheduler = scheduler
    }
}

extension CategoryPickerSectionFlowComposer {
    
    func compose() -> CategoryPickerSectionFlow {
        
    }
}
