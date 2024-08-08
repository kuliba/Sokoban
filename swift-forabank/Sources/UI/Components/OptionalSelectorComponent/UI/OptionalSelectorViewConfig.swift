//
//  SwiftUIView.swift
//  
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SharedConfigs

public struct OptionalSelectorViewConfig: Equatable {
    
    let title: TitleConfig
    let search: TextConfig
    let searchPlaceholder: String
    
    public init(
        title: TitleConfig,
        search: TextConfig,
        searchPlaceholder: String
    ) {
        self.title = title
        self.search = search
        self.searchPlaceholder = searchPlaceholder
    }
}
