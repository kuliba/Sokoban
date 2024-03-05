//
//  FooterView.swift
//
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

public struct FooterView: View {
    
    let footerState: FooterState
    let config: FooterViewConfig
    
    public init(
        footerState: FooterState,
        config: FooterViewConfig
    ) {
        self.footerState = footerState
        self.config = config
    }
    
    public var body: some View {
        
        switch footerState {
        case let .footer(title, description, buttons, subtitle):
         
            VStack(spacing: 24) {
                
                VStack(spacing: 16) {
                    
                    Text(title)
                        .font(config.titleFont)
                        .foregroundColor(config.titleColor)
                    
                    Text(description)
                        .multilineTextAlignment(.center)
                        .font(config.descriptionFont)
                        .foregroundColor(config.descriptionColor)
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 16) {
                    
                    if let buttons {
                     
                        VStack(spacing: 8) {
                            
                            ForEach(buttons) { button in
                                
                                ButtonSimpleView(viewModel: button)
                                    .frame(height: 56)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                    Text(subtitle)
                        .font(config.subtitleFont)
                        .foregroundColor(config.subtitleColor)
                        .padding(.horizontal, 16)
                        .multilineTextAlignment(.center)
                }
            }
            
        case let .failure(image, description, button):
            
            VStack(spacing: 24) {
                
                Image.defaultIcon(
                    backgroundColor: .gray.opacity(0.1),
                    icon: image
                )
                
                VStack(spacing: 16) {
                    
                    Text(description)
                        .multilineTextAlignment(.center)
                        .font(config.descriptionFont)
                        .foregroundColor(config.descriptionColor)
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 16) {
                    
                    VStack(spacing: 8) {
                        
                        ButtonSimpleView(viewModel: button)
                            .frame(height: 56)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

public struct FooterViewConfig {
    
    let titleFont: Font
    let titleColor: Color
    
    let descriptionFont: Font
    let descriptionColor: Color
    
    let subtitleFont: Font
    let subtitleColor: Color
    
    public init(
        titleFont: Font,
        titleColor: Color,
        descriptionFont: Font,
        descriptionColor: Color,
        subtitleFont: Font,
        subtitleColor: Color
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.descriptionFont = descriptionFont
        self.descriptionColor = descriptionColor
        self.subtitleFont = subtitleFont
        self.subtitleColor = subtitleColor
    }
}

private extension FooterViewConfig {

    static let previewConfig: Self = .init(
        titleFont: .title3, titleColor: .black, descriptionFont: .body, descriptionColor: .gray, subtitleFont: .body, subtitleColor: .black
    )
}

struct NoCompanyInListView_Previews: PreviewProvider {
    static var previews: some View {
        
        FooterView(
            footerState: .failure(
                image: .init(systemName: "magnifyingglass"),
                description: "Что-то пошло не так.\n Попробуйте позже или воспользуйтесь\n другим способом оплаты.",
                button: .init(
                    title: "Оплатить по реквизитам",
                    buttonConfiguration: .init(titleFont: .body, titleForeground: .black, backgroundColor: .gray),
                    action: {}
                )
            ),
            config: .previewConfig
        )
        
        FooterView(
            footerState: .footer(
                title: "Нет компании в списке?",
                description: "Воспользуйтесь другими способами оплаты",
                buttons: [
                    .init(
                        title: "Оплатить по реквизитам",
                        buttonConfiguration: .init(
                            titleFont: .body,
                            titleForeground: .red,
                            backgroundColor: .gray
                        ),
                        action: {}
                    ),
                    .init(
                        title: "Добавить организацию",
                        buttonConfiguration: .init(
                            titleFont: .body,
                            titleForeground: .blue,
                            backgroundColor: .gray
                        ),
                        action: {}
                    )
                ],
                subtitle: "Сообщите нам, и мы подключим новую организацию"
            ),
            config: .previewConfig
        )
    }
}
