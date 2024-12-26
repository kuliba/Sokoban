//
//  ButtonSimpleView.swift
//  
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

//MARK: - View

struct ButtonSimpleView: View {
    
    let viewModel: ButtonSimpleViewModel
    
    var body: some View {
        
        Button {
            
            viewModel.action()
            
        } label: {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(viewModel.buttonConfig.backgroundColor)
                
                Text(viewModel.title)
                    .font(viewModel.buttonConfig.titleFont)
                    .foregroundColor(viewModel.buttonConfig.titleForeground)
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
                    titleForeground: .black,
                    backgroundColor: .gray
                ),
                action: {}
            ))
            .previewLayout(.fixed(width: 375, height: 70))
        }
    }
}
