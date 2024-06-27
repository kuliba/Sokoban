//
//  TimedOTPInputWrapperView+ext.swift
//  
//
//  Created by Igor Malyarov on 26.06.2024.
//

import SwiftUI

public extension TimedOTPInputWrapperView where WarningView == EmptyView {
    
    init(
        viewModel: ViewModel,
        config: Config,
        iconView: @escaping () -> IconView
    ) {
        self.init(viewModel: viewModel, config: config, iconView: iconView, warningView: EmptyView.init )
    }
}
