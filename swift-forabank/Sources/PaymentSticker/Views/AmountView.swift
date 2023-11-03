//
//  AmountView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 11.10.2023.
//

import Foundation
import SwiftUI
//import TextFieldComponent

// MARK: - View

struct AmountView: View {
    
    let viewModel: AmountViewModel
    @State var text: String
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .bottom, spacing: 28) {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    HStack {
                        
                        TextField("Сумма", text: $text)
                            .foregroundColor(.white)
                    }
                    
                    Divider()
                        .background(Color.gray)
                        .padding(.top, 4)
                    
                }
                
                TransferButtonView(
                    viewModel: .active(action: viewModel.continueButtonTapped )
                )
                    .frame(width: 113, height: 40)
            }
            
            Text("Включая стоимость доставки")
                .font(.body)
                .foregroundColor(.gray.opacity(0.5))
            
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .background(
            Color.black
                .ignoresSafeArea(.container, edges: .bottom)
        )
    }
    
    struct TransferButtonView: View {
        
        let viewModel: TransferButtonViewModel
        let title = "Продолжить"
        
        var body: some View {
            
            switch viewModel {
            case .inactive:
                inactiveView(with: title)
                
            case let .active(action):
                activeView(title: title, action: action)
                
            case .loading:
                SpinnerRefreshView(
                    icon: .init(systemName: "photo.artframe"),
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
        private func activeView(title: String, action: @escaping () -> Void) -> some View {
        
            Button(action: action) {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.red)
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
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
