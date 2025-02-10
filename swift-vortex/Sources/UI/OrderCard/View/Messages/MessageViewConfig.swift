//
//  MessageViewConfig.swift
//  
//
//  Created by Igor Malyarov on 09.02.2025.
//

import SharedConfigs
import SwiftUI
import LinkableText

public struct MessageViewConfig {
    
    public let icon: Image
    public let title: TitleConfig
    public let subtitle: TitleConfig
    public let description: TextConfig
    public let linkableText: LinkableTexts
    public let toggle: SharedConfigs.ToggleConfig
    
    public init(
        icon: Image,
        title: TitleConfig,
        subtitle: TitleConfig,
        description: TextConfig,
        linkableText: LinkableTexts,
        toggle: SharedConfigs.ToggleConfig
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.linkableText = linkableText
        self.toggle = toggle
    }
    
    public struct LinkableTexts {
        
        let text: String
        let tag: LinkableText.Tag
        let tariff: String
        
        public init(
            text: String,
            tag: LinkableText.Tag = ("<u>", "</u>"),
            tariff: String
        ) {
            self.text = text
            self.tag = tag
            self.tariff = tariff
        }
    }
}
