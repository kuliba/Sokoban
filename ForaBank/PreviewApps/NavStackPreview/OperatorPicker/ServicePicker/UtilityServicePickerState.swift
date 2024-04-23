//
//  UtilityServicePickerState.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

struct UtilityServicePickerState: Equatable {
    
    let `operator`: Operator
    let services: [UtilityService]
}

extension UtilityServicePickerState {
    
    struct Operator: Equatable {
 
        let name: String
        let inn: String
        let icon: String
    }
}
