//
//  OperatorView.swift
//  
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

public struct OperatorView: View {
    
    let `operator`: Operator
    let event: (Operator) -> Void
    let config: OperatorViewConfig
    
    public init(
        `operator`: Operator,
        event: @escaping (Operator) -> Void,
        config: OperatorViewConfig
    ) {
        self.`operator` = `operator`
        self.config = config
        self.event = event
    }
    
    public var body: some View {
        
        Button(action: { event(`operator`) }) {
            
            HStack(spacing: 16) {
                 
                if let image = `operator`.image {
                    
                    image
                        .resizable()
                        .frame(width: 40, height: 40)
                } else {
                    
                    Image.defaultIcon(
                        backgroundColor: config.defaultIconBackgroundColor,
                        foregroundColor: .white,
                        icon: config.defaultIcon
                    )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    
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
            .padding(.vertical, 8)
            .frame(height: 46)
            .contentShape(Rectangle())
        }
    }
}

public extension OperatorView {
    
    struct OperatorViewConfig {
        
        let titleFont: Font
        let titleColor: Color
        
        let descriptionFont: Font
        let descriptionColor: Color
        
        let defaultIconBackgroundColor: Color
        let defaultIcon: Image
        
        public init(
            titleFont: Font,
            titleColor: Color,
            descriptionFont: Font,
            descriptionColor: Color,
            defaultIconBackgroundColor: Color,
            defaultIcon: Image
        ) {
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.descriptionFont = descriptionFont
            self.descriptionColor = descriptionColor
            self.defaultIconBackgroundColor = defaultIconBackgroundColor
            self.defaultIcon = defaultIcon
        }
    }
}

struct OperatorView_Previews: PreviewProvider {
   
    static var previews: some View {
        
        OperatorView(
            operator: .init(
                id: "id",
                title: "ЖКУ Москвы (ЕИРЦ)",
                subtitle: "ИНН 7702070139",
                image: .init(systemName: "")
            ),
            event: { _ in },
            config: .init(
                titleFont: .title3,
                titleColor: .black,
                descriptionFont: .body,
                descriptionColor: .gray,
                defaultIconBackgroundColor: .black,
                defaultIcon: .init(systemName: "photo.artframe")
            )
        )
    }
}
