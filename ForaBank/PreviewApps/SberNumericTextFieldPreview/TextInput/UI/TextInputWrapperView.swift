//
//  TextInputWrapperView.swift
//  
//
//  Created by Igor Malyarov on 07.08.2024.
//

import SwiftUI

struct TextInputWrapperView<IconView: View>: View {
    
    @ObservedObject private var model: Model
    
    private let config: Config
    private let iconView: () -> IconView
    
    init(
        model: Model,
        config: Config,
        iconView: @escaping () -> IconView
    ) {
        self.model = model
        self.config = config
        self.iconView = iconView
    }
    
    var body: some View {
        
        TextInputView(
            state: model.state,
            event: model.event(_:),
            config: config,
            iconView: iconView
        )
    }
}

extension TextInputWrapperView {
    
    typealias Model = TextInputModel
    typealias Config = TextInputConfig
}
