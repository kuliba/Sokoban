//
//  TextInputWrapperView.swift
//
//
//  Created by Igor Malyarov on 07.08.2024.
//

import InputComponent
import SwiftUI

struct TextInputWrapperView<IconView: View>: View {
    
    @ObservedObject var model: Model
    
    let config: Config
    let iconView: () -> IconView
    
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
    
    typealias Model = RxInputViewModel
    typealias Config = TextInputConfig
}
