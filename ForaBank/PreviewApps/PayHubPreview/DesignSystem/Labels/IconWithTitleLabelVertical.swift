//
//  IconWithTitleLabelVertical.swift
//  PayHubPreview
//
//  Created by Igor Malyarov on 17.08.2024.
//

import SwiftUI

struct IconWithTitleLabelVertical<Icon: View, Title: View>: View {
    
    @ViewBuilder let icon: () -> Icon
    @ViewBuilder let title: () -> Title
    let config: IconWithTitleLabelVerticalConfig
    
    var body: some View {
        
        VStack(spacing: config.spacing) {
            
            icon()
                .clipShape(Circle())
                .frame(width: config.circleSize, height: config.circleSize)
            
            title()
        }
        .frame(config.frame)
    }
}
