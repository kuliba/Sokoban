//
//  OperatorView.swift
//  
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

struct OperatorView: View {
    
    let icon: Image
    let title: String
    let description: String?
    let action: () -> Void
    
    let config: OperatorViewConfig
    
    var body: some View {
        
        Button(action: action) {
            
            HStack(spacing: 20) {
                
                icon
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(title)
                        .font(config.titleFont)
                        .foregroundColor(config.titleColor)
                        .multilineTextAlignment(.leading)
                    
                    if let description = description {
                        
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
            icon: .init(systemName: ""),
            title: "ЖКУ Москвы (ЕИРЦ)",
            description: "ИНН 7702070139",
            action: {},
            config: .init(
                titleFont: .title3,
                titleColor: .black,
                descriptionFont: .body,
                descriptionColor: .gray
            )
        )
    }
}
