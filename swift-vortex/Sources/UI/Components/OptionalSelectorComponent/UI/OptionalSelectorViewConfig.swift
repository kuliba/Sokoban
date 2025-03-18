//
//  SwiftUIView.swift
//  
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SharedConfigs
import UIKit

public struct OptionalSelectorViewConfig: Equatable {
    
    let title: TitleConfig
    let search: TextConfig
    let searchPlaceholder: String
    let keyboardType: UIKeyboardType?
    
    public init(
        title: TitleConfig,
        search: TextConfig,
        searchPlaceholder: String,
        keyboardType: UIKeyboardType? = nil
    ) {
        self.title = title
        self.search = search
        self.searchPlaceholder = searchPlaceholder
        self.keyboardType = keyboardType
    }
}
