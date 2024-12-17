//
//  IconWithTitleLabelVertical.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

public struct IconWithTitleLabelVertical<Icon: View, Title: View>: View {
    
    private let icon: () -> Icon
    private let title: () -> Title
    private let config: IconWithTitleLabelVerticalConfig
    
    public init(
        @ViewBuilder icon: @escaping () -> Icon,
        @ViewBuilder title: @escaping () -> Title,
        config: IconWithTitleLabelVerticalConfig
    ) {
        self.icon = icon
        self.title = title
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            icon()
                .clipShape(Circle())
                .frame(width: config.circleSize, height: config.circleSize)
            
            title()
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(config.frame)
    }
}
