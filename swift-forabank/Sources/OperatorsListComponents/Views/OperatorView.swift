//
//  OperatorView.swift
//  
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI
import UIKit

struct OperatorView: View {
    
    let operatorViewModel: OperatorViewModel
    
    let config: OperatorViewConfig
    
    var body: some View {
        
        Button(action: operatorViewModel.action) {
            
            HStack(spacing: 20) {
                
                if let uiImage = UIImage(data: operatorViewModel.icon) {
                 
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(operatorViewModel.title)
                        .font(config.titleFont)
                        .foregroundColor(config.titleColor)
                        .multilineTextAlignment(.leading)
                    
                    if let description = operatorViewModel.description {
                        
                        Text(description)
                            .font(config.descriptionFont)
                            .foregroundColor(config.descriptionColor)
                    }
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

struct OperatorViewConfig {
    
    let titleFont: Font
    let titleColor: Color
    
    let descriptionFont: Font
    let descriptionColor: Color
}

struct OperatorView_Previews: PreviewProvider {
   
    static var previews: some View {
        
        OperatorView(
            operatorViewModel: .init(
                icon: Data(),
                title: "ЖКУ Москвы (ЕИРЦ)",
                description: "ИНН 7702070139",
                action: {}
            ),
            config: .init(
                titleFont: .title3,
                titleColor: .black,
                descriptionFont: .body,
                descriptionColor: .gray
            )
        )
    }
}
