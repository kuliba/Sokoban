//
//  UtilityServicePickerState.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

struct UtilityServicePickerState<Icon> {
    
    let `operator`: Operator
    let services: [UtilityService<Icon>]
}

extension UtilityServicePickerState {
    
    struct Operator {
 
        let name: String
        let inn: String
        let icon: Icon
    }
}

extension UtilityServicePickerState.Operator: Equatable where Icon: Equatable {}
extension UtilityServicePickerState: Equatable where Icon: Equatable {}
