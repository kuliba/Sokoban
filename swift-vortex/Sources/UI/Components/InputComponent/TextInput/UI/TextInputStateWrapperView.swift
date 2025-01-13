//
//  TextInputStateWrapperView.swift
//  
//
//  Created by Igor Malyarov on 07.08.2024.
//

import SwiftUI

public struct TextInputStateWrapperView<IconView: View>: View {
    
    @StateObject private var model: Model
    
    private let config: Config
    private let iconView: () -> IconView
    
    public init(
        model: Model,
        config: Config,
        iconView: @escaping () -> IconView
    ) {
        self._model = .init(wrappedValue: model)
        self.config = config
        self.iconView = iconView
    }
    
    public var body: some View {
        
        TextInputWrapperView(
            model: model,
            config: config,
            iconView: iconView
        )
    }
}

public extension TextInputStateWrapperView {
    
    typealias Model = TextInputModel
    typealias Config = TextInputConfig
}
