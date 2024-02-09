//
//  NoCompanyInListView.swift
//  
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

struct NoCompanyInListView: View {
    
    let title: String
    let description: String
    let subtitle: String
    let buttons: [ButtonSimpleView.ViewModel]
    
    let config: NoCompanyInListViewConfig
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            VStack(spacing: 16) {
                
                Text(title)
                    .font(config.titleFont)
                    .foregroundColor(config.titleColor)
                
                Text(description)
                    .font(config.descriptionFont)
                    .foregroundColor(config.descriptionColor)
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                
                VStack(spacing: 8) {
                    
                    ForEach(buttons) { button in
                        
                        ButtonSimpleView(viewModel: button)
                            .frame(height: 56)
                            .padding(.horizontal, 16)
                    }
                }
                
                Text(subtitle)
                    .font(config.subtitleFont)
                    .foregroundColor(config.subtitleColor)
                    .padding(.horizontal, 16)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

extension NoCompanyInListView {
    
    static let title = "Нет компании в списке?"
    static let description = "Воспользуйтесь другими способами оплаты"
    static let subtitle = "Сообщите нам, и мы подключим новую организацию"
    
    struct NoCompanyInListViewConfig {
        
        let titleFont: Font
        let titleColor: Color
        
        let descriptionFont: Font
        let descriptionColor: Color
        
        let subtitleFont: Font
        let subtitleColor: Color
    }
}

struct NoCompanyInListView_Previews: PreviewProvider {
    static var previews: some View {
        
        NoCompanyInListView(
            title: "Нет компании в списке?",
            description: "Воспользуйтесь другими способами оплаты",
            subtitle: "Сообщите нам, и мы подключим новую организацию",
            buttons: [
                .init(
                    title: "Оплатить по реквизитам",
                    buttonConfiguration: .init(
                        titleFont: .body,
                        titleForeground: .red
                    ),
                    action: {}
                ),
                .init(
                    title: "Добавить организацию",
                    buttonConfiguration: .init(
                        titleFont: .body,
                        titleForeground: .blue
                    ),
                    action: {}
                )
            ],
            config: .init(
                titleFont: .title3,
                titleColor: .black,
                descriptionFont: .body,
                descriptionColor: .gray,
                subtitleFont: .body,
                subtitleColor: .gray
            )
        )
    }
}
