//
//  ConfirmView.swift
//  
//
//  Created by Andryusina Nataly on 18.07.2023.
//

import SwiftUI

public struct ConfirmView: View {
    
    let config: ConfirmView.Config
    let viewModel: ConfirmViewModel
    
    public init(
        config: ConfirmView.Config = .defaultConfig,
        viewModel: ConfirmViewModel
    ) {
        self.config = config
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        HStack(alignment: .top) {
            
            VStack {
                
                Text("Введите код из сообщения")
                    .font(config.font)
                    .multilineTextAlignment(.center)
                    .foregroundColor(config.foregroundColor)
                PasscodeField(viewModel: viewModel)
                TimerView(
                    viewModel: .sample,
                    config: .defaultConfig
                )
                .padding(.top, 32)
            }
            .padding(.trailing, 20)
            .padding(.leading, 19)
            .padding(.top, 16)
            .frame(maxHeight: .infinity)
        }
    }
}

struct ConfirmView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ConfirmView(viewModel: .defaultViewModel)
    }
}

//MARK: - Preview Content

private extension ConfirmViewModel {
    
    static let defaultViewModel = ConfirmViewModel.init(handler: { _, _ in })
}

