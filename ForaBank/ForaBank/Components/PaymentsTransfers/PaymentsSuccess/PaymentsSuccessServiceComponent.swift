//
//  PaymentsSuccessServiceComponent.swift
//  Vortex
//
//  Created by Max Gribov on 23.06.2023.
//

import SwiftUI

extension PaymentsSuccessServiceView {
    
    final class ViewModel: PaymentsParameterViewModel {
        
        let title: String
        let description: String
        
        init(title: String, description: String, source: PaymentsParameterRepresentable) {
            
            self.title = title
            self.description = description
            super.init(source: source)
        }
        
        convenience init(_ source: Payments.ParameterSuccessService) {
            
            self.init(title: source.value ?? "", description: source.description, source: source)
        }
    }
}

struct PaymentsSuccessServiceView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            Text(viewModel.title)
                .font(.textBodyMR14200())
                .foregroundColor(.mainColorsGray)
            
            Text(viewModel.description)
                .font(.textH3Sb18240())
                .foregroundColor(.mainColorsBlack)
        }
    }
}
