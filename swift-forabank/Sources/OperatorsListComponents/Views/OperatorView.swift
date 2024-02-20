//
//  OperatorView.swift
//  
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

public struct OperatorView: View {
    
    let `operator`: Operator
    let config: OperatorViewConfig
    
    public init(
        `operator`: Operator,
        config: OperatorViewConfig
    ) {
        self.`operator` = `operator`
        self.config = config
    }
    
    public var body: some View {
        
        Button(action: { `operator`.action(`operator`.id) }) {
            
            HStack(spacing: 20) {
                 
                `operator`.image
                    .resizable()
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(`operator`.title)
                        .lineLimit(1)
                        .font(config.titleFont)
                        .foregroundColor(config.titleColor)
                    
                    if let description = `operator`.subtitle {
                        
                        Text(description)
                            .lineLimit(1)
                            .font(config.descriptionFont)
                            .foregroundColor(config.descriptionColor)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

public struct OperatorViewConfig {
    
    let titleFont: Font
    let titleColor: Color
    
    let descriptionFont: Font
    let descriptionColor: Color
    
    public init(
        titleFont: Font,
        titleColor: Color,
        descriptionFont: Font,
        descriptionColor: Color
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.descriptionFont = descriptionFont
        self.descriptionColor = descriptionColor
    }
}

struct OperatorView_Previews: PreviewProvider {
   
    static var previews: some View {
        
        OperatorView(
            operator: .init(
                id: "id",
                title: "ЖКУ Москвы (ЕИРЦ)",
                subtitle: "ИНН 7702070139",
                image: .init(systemName: ""),
                action: { _ in }
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
