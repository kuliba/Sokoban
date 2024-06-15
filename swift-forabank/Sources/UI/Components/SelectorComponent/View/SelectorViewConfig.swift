//
//  SwiftUIView.swift
//  
//
//  Created by Igor Malyarov on 15.06.2024.
//

import SharedConfigs

public struct SelectorViewConfig: Equatable {
    
    let title: TitleConfig
    let search: TextConfig
    
    public init(
        title: TitleConfig,
        search: TextConfig
    ) {
        self.title = title
        self.search = search
    }
}
