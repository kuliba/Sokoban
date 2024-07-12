//
//  InputWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.06.2024.
//

import PaymentComponents
import SwiftUI

struct InputWrapperView<IconView: View>: View {
    
    @ObservedObject var viewModel: ViewModel
    
    let makeIconView: () -> IconView
    
    var body: some View {
        
        InputView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: .iFora(keyboard: .default, limit: viewModel.state.settings.limit),
            iconView: makeIconView,
            commit: { viewModel.event(.edit($0)) },
            isValid: { text in InputWrapperView<IconView>.isValidate(text, regExp: viewModel.state.settings.regExp) }
        )
    }
}

extension InputWrapperView {
    
    typealias ViewModel = ObservingInputViewModel
    
    public static func isValidate(_ text: String, regExp: String?) -> Bool {
        if let pattern = regExp {
            
            let value = text
            let isMatching = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
            return isMatching ? true : false
            
        } else {
            
            return true
        }
    }
}
