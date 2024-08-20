//
//  PayHubPickerItem.swift
//
//
//  Created by Igor Malyarov on 15.08.2024.
//

public enum PayHubPickerItem<Latest> {
    
    case exchange
    case latest(Latest)
    case templates
}

extension PayHubPickerItem: Equatable where Latest: Equatable {}
