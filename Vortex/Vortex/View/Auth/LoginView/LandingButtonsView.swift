//
//  LandingButtonsView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.09.2023.
//

import SwiftUI

struct LandingButtonsView: View {

    @ObservedObject private var viewModel: AuthLoginViewModel
    
    init(viewModel: AuthLoginViewModel) {
        
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            VStack(spacing: 8) {
                
                ForEach(viewModel.buttons, content: ButtonAuthView.init)
            }
            .bottomSheet(item: $viewModel.bottomSheet) { sheet in
                
                switch sheet.type {
                case let .orderProduct(viewModel):
                    OrderProductView(viewModel: viewModel)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct LandingButtonsView_Previews: PreviewProvider {
    static var previews: some View {
        LandingButtonsView(viewModel: .preview)
    }
}
