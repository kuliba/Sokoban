//
//  ButtonSimpleView.swift
//  
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

//MARK: - ViewModel

extension ButtonSimpleView {
    
    class ViewModel: ObservableObject, Identifiable {
        
        let id = UUID()
        @Published var title: String
        let action: () -> Void

        let buttonConfiguration: ButtonConfiguration
        
        struct ButtonConfiguration {
        
            let titleFont: Font
            let titleForeground: Color
        }
        
        internal init(
            title: String,
            buttonConfiguration: ButtonConfiguration,
            action: @escaping () -> Void
        ) {

            self.title = title
            self.action = action
            self.buttonConfiguration = buttonConfiguration
        }
    }
}

//MARK: - View

struct ButtonSimpleView: View {
    
    @ObservedObject var viewModel: ButtonSimpleView.ViewModel
    
    var body: some View {
        
        Button {
            
            viewModel.action()
            
        } label: {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.black)
                
                Text(viewModel.title)
                    .font(viewModel.buttonConfiguration.titleFont)
                    .foregroundColor(viewModel.buttonConfiguration.titleForeground)
            }
        }
    }
}

//MARK: - Preview

struct ButtonSimpleView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ButtonSimpleView(viewModel: .init(
                title: "Оплатить",
                buttonConfiguration: .init(
                    titleFont: .title,
                    titleForeground: .black
                ),
                action: {}
            ))
            .previewLayout(.fixed(width: 375, height: 70))
        }
    }
}
