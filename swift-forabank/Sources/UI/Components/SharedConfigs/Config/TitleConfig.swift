//
//  TitleConfig.swift
//
//
//  Created by Igor Malyarov on 15.06.2024.
//

public struct TitleConfig: Equatable {
    
    public let text: String
    public let config: TextConfig
    
    public init(
        text: String,
        config: TextConfig
    ) {
        self.text = text
        self.config = config
    }
}
