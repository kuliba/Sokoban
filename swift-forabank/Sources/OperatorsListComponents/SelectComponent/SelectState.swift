//
//  SelectState.swift
//
//
//  Created by Дмитрий Савушкин on 13.03.2024.
//

import Foundation
import SwiftUI

public struct SelectUIState {

    let image: Image
    var state: SelectState
}

public enum SelectState {
    
    case collapsed(option: Option?)
    case expanded(selectOption: Option?, options: [Option], searchText: String)
    
    public struct Option {
        
        let id: String
        let title: String
        let isSelected: Bool
        
        public init(
            id: String,
            title: String,
            isSelected: Bool
        ) {
            self.id = id
            self.title = title
            self.isSelected = isSelected
        }
    }
}
