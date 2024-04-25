//
//  SelectEvent.swift
//
//
//  Created by Дмитрий Савушкин on 13.03.2024.
//

import Foundation

public enum SelectEvent {
    
    case chevronTapped(options: [SelectState.Option]?, selectOption: SelectState.Option?)
    case optionTapped(SelectState.Option)
    case search(String)
}
