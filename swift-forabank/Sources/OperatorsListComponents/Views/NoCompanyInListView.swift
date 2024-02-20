//
//  NoCompanyInListView.swift
//  
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI

public struct NoCompanyInListView: View {
    
    let noCompanyListViewModel: NoCompanyInListViewModel
    let config: NoCompanyInListViewConfig
    
    public init(
        noCompanyListViewModel: NoCompanyInListViewModel,
        config: NoCompanyInListViewConfig
    ) {
        self.noCompanyListViewModel = noCompanyListViewModel
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: 24) {
            
            VStack(spacing: 16) {
                
                Text(noCompanyListViewModel.title)
                    .font(config.titleFont)
                    .foregroundColor(config.titleColor)
                
                Text(noCompanyListViewModel.description)
                    .multilineTextAlignment(.center)
                    .font(config.descriptionFont)
                    .foregroundColor(config.descriptionColor)
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                
                VStack(spacing: 8) {
                    
                    ForEach(noCompanyListViewModel.buttons) { button in
                        
                        ButtonSimpleView(viewModel: button)
                            .frame(height: 56)
                            .padding(.horizontal, 16)
                    }
                }
                
                Text(noCompanyListViewModel.subtitle)
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
}

public struct NoCompanyInListViewConfig {
    
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

public extension NoCompanyInListViewModel {
    
    static let sample: Self = .init(
        title: "Нет компании в списке?",
        description: "Воспользуйтесь другими способами оплаты",
        subtitle: "Сообщите нам, и мы подключим новую организацию",
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
        ])
}

struct NoCompanyInListView_Previews: PreviewProvider {
    static var previews: some View {
        
        NoCompanyInListView(
            noCompanyListViewModel: .sample,
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
