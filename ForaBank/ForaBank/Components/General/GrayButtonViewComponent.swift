//
//  GrayButtonViewComponent.swift
//  ForaBank
//
//  Created by Mikhail on 29.05.2022.
//

import SwiftUI

//MARK: - ViewModel

extension GrayButtonView {
    
    class ViewModel: ObservableObject {
        
        @Published var title: String
        @Published var isEnabled: Bool
        let action: () -> Void

        internal init(title: String, isEnabled: Bool = true, action: @escaping () -> Void) {

            self.title = title
            self.action = action
            self.isEnabled = isEnabled
        }
        
    }
}

//MARK: - View

struct GrayButtonView: View {
    
    @ObservedObject var viewModel: GrayButtonView.ViewModel
    
    var body: some View {
        
        if viewModel.isEnabled {
            
            Button {
                
                viewModel.action()
                
            } label: {
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.buttonSecondary)
                    
                    Text(viewModel.title)
                        .font(.buttonLargeSB16180())
                        .foregroundColor(.textSecondary)
                }
            }

        } else {

            ZStack {
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.buttonSecondary)
                
                Text(viewModel.title)
                    .font(.buttonLargeSB16180())
                    .foregroundColor(Color(hex: "#898989"))
            }
        }
    }
}

//MARK: - Preview

struct ButtonGrayView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            GrayButtonView(viewModel: .init(title: "Скопировать все", isEnabled: true, action: {}))
                .previewLayout(.fixed(width: 375, height: 70))
            
            GrayButtonView(viewModel: .init(title: "Скопировать все", isEnabled: false, action: {} ))
                .previewLayout(.fixed(width: 375, height: 70))
            
        }
    }
}
