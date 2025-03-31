//
//  HeaderView.swift
//
//
//  Created by Igor Malyarov on 30.03.2025.
//

import SwiftUI

/// A view that displays a header with title and optional subtitle along with a back button.
public struct HeaderView: View {
    
    private let header: Header
    private let action: () -> Void
    private let config: HeaderViewConfig
    
    /// Creates a `HeaderView` with the specified header model, back button action, and style configuration.
    public init(
        header: Header,
        action: @escaping () -> Void,
        config: HeaderViewConfig
    ) {
        self.header = header
        self.action = action
        self.config = config
    }
    
    /// Creates a `HeaderView` using a title and an optional subtitle.
    /// This convenience initializer constructs the header model from the provided title and subtitle,
    /// and configures the view with the specified back button action and style configuration.
    public init(
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void,
        config: HeaderViewConfig
    ) {
        self.header = .init(title: title, subtitle: subtitle)
        self.action = action
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: config.vSpacing) {
            
            header.title.text(withConfig: config.title, alignment: .center)
            header.subtitle?.text(withConfig: config.subtitle, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .height(config.height)
        .overlay(alignment: .leading, content: backButton)
        .padding(.horizontal, config.hPadding)
    }
}

private extension HeaderView {
    
    func backButton() -> some View {
        
        Button(action: action) { config.backImage.image }
            .foregroundColor(config.backImage.color)
            .frame(config.backImage.frame)
    }
}
