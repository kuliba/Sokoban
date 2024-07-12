//
//  InputStateWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import PaymentComponents
import SwiftUI

struct InputStateWrapperView<IconView: View>: View {
    
    @StateObject var viewModel: ViewModel
    
    let makeIconView: () -> IconView
    
    var body: some View {
        
        InputView(
            state: viewModel.state,
            event: viewModel.event(_:),
            config: .iFora(keyboard: .default, limit: viewModel.state.settings.limit),
            iconView: makeIconView, 
            commit: { viewModel.event(.edit($0)) },
            isValid: { text in isValidate(text) }
        )
    }
}

extension InputStateWrapperView {
    
    typealias ViewModel = ObservingInputViewModel
    
    fileprivate func isValidate(_ text: String) -> Bool {
        if let pattern = viewModel.state.settings.regExp {
            
            let value = text
            let isMatching = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: value)
            return isMatching ? true : false
            
        } else {
            
            return true
        }
    }
}
