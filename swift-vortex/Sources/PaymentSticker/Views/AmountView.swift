//
//  AmountView.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 11.10.2023.
//

import Foundation
import SwiftUI

// MARK: - View

struct AmountView: View {
    
    let viewModel: AmountViewModel
    let configuration: AmountViewConfiguration
    let text: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(alignment: .bottom, spacing: 28) {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    HStack {
                        
                        Text("\(text) ₽")
                            .foregroundColor(configuration.amountColor)
                            .font(configuration.amountFont)
                    }
                    
                    Divider()
                        .background(Color.gray)
                        .padding(.top, 4)
                    
                }
                
                TransferButtonView(
                    viewModel: viewModel.reduceState(
                        state: viewModel.parameter.state,
                        isCompleteOperation: viewModel.isCompleteOperation,
                        action: viewModel.continueButtonTapped
                    ),
                    configuration: configuration
                )
                .frame(width: 113, height: 40)
            }
            
            Text("Включая стоимость доставки")
                .font(configuration.hintFont)
                .foregroundColor(configuration.hintColor)
            
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .background(
            
            configuration.background
                .ignoresSafeArea(.container, edges: .bottom)
        )
    }
    
    struct TransferButtonView: View {
        
        let viewModel: TransferButtonViewModel
        let configuration: AmountViewConfiguration
        let title = "Продолжить"
        
        var body: some View {
            
            switch viewModel {
            case .inactive:
                inactiveView(with: title)
                
            case let .active(action):
                activeView(
                    title: title,
                    configuration: configuration,
                    action: action
                )
                
            case .loading:
                SpinnerRefreshView(
                    icon: .init("Logo Fora Bank"),
                    iconSize: .init(width: 32, height: 32)
                )
            }
        }
        
        enum TransferButtonViewModel {
            
            case inactive
            case active(action: () -> Void)
            case loading
        }
        
        @ViewBuilder
        private func activeView(
            title: String,
            configuration: AmountViewConfiguration,
            action: @escaping () -> Void
        ) -> some View {
        
            Button(action: action) {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(configuration.buttonColor)
                    
                    Text(title)
                        .font(configuration.buttonTextFont)
                        .foregroundColor(configuration.buttonTextColor)
                }
            }
        }
        
        @ViewBuilder
        private func inactiveView(with title: String) -> some View {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.gray.opacity(0.1))
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}
