//
//  SelectState.swift
//
//
//  Created by Дмитрий Савушкин on 13.03.2024.
//

import Foundation
import SwiftUI

public struct SelectUIState: Equatable {

    let image: Image
    public var state: SelectState
    
    public init(image: Image, state: SelectState) {
        self.image = image
        self.state = state
    }
}

public enum SelectState: Equatable {
    
    case collapsed(option: Option?, options: [Option]?)
    case expanded(selectOption: Option?, options: [Option], searchText: String?)
    
    init(state: SelectState) {
        self = state
    }
    
    public struct Option: Equatable, Identifiable {
        
        public let id: String
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
