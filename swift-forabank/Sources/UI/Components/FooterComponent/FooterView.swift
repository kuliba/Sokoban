//
//  FooterView.swift
//
//
//  Created by Дмитрий Савушкин on 07.02.2024.
//

import SwiftUI
import SharedConfigs

public struct FooterView: View {
    
    let state: FooterState
    let event: (FooterEvent) -> Void
    let config: FooterView.Config
    
    public init(
        state: FooterState,
        event: @escaping (FooterEvent) -> Void,
        config: FooterView.Config
    ) {
        self.state = state
        self.event = event
        self.config = config
    }
    
    public var body: some View {
        
        switch state {
        case let .footer(footer):
            footerView(footer)
            
        case let .failure(failure):
            failureView(failure)
        }
    }
    
    private func footerView(
        _ footer: FooterState.Footer
    ) -> some View {
        
        VStack(spacing: 24) {
            
            VStack(spacing: 16) {
                
                footer.title.text(withConfig: config.titleConfig)
                
                descriptionView(footer.description)
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                
                VStack(spacing: 8) {
                    
                    Group {
                        
                        addCompanyButton()
                        
                        payByInstructionButton()
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 16)
                }
                
                footer.subtitle.text(withConfig: config.subtitleConfig)
                    .padding(.horizontal, 16)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func failureView(
        _ failure: FooterState.Failure
    ) -> some View {
        
        VStack(spacing: 24) {
            
            Image.defaultIcon(
                backgroundColor: config.backgroundIcon,
                icon: failure.image
            )
            
            descriptionView(failure.description)
                .padding(.horizontal, 16)
            
            addCompanyButton()
                .frame(height: 56)
                .padding(.horizontal, 16)
        }
    }
    
    private func descriptionView(
        _ description: String
    ) -> some View {
        
        description.text(withConfig: config.descriptionConfig)
            .multilineTextAlignment(.center)
    }
    
    private func addCompanyButton() -> some View {
        
        ButtonSimpleView(
            viewModel: .init(
                title: config.requisitesButtonTitle,
                buttonConfiguration: config.requisitesButtonConfig,
                action: { event(.addCompany) }
            ))
    }
    
    private func payByInstructionButton() -> some View {
        
        ButtonSimpleView(
            viewModel: .init(
                title: config.requisitesButtonTitle,
                buttonConfiguration: config.requisitesButtonConfig,
                action: { event(.payByInstruction) }
            ))
    }
}

private extension FooterView.Config {
    
    static let previewConfig: Self = .init(
        titleConfig: .init(textFont: .title3, textColor: .black),
        descriptionConfig: .init(textFont: .body, textColor: .gray),
        subtitleConfig: .init(textFont: .body, textColor: .black),
        backgroundIcon: .gray,
        requisitesButtonTitle: "Оплатить по реквизитам",
        requisitesButtonConfig: .init(titleFont: .body, titleForeground: .black, backgroundColor: .gray),
        addCompanyButtonTitle: "Добавить организацию",
        addCompanyButtonConfiguration: .init(
            titleFont: .body,
            titleForeground: .blue,
            backgroundColor: .gray
        )
    )
}

struct FooterView_Previews: PreviewProvider {
    static var previews: some View {
        
        FooterView(
            state: .failure(.init(
                image: .init(systemName: "magnifyingglass"),
                description: "Что-то пошло не так.\n Попробуйте позже или воспользуйтесь\n другим способом оплаты."
            )),
            event: { _ in },
            config: .previewConfig
        )
        
        FooterView(
            state: .footer(.init(
                title: "Нет компании в списке?",
                description: "Воспользуйтесь другими способами оплаты",
                subtitle: "Сообщите нам, и мы подключим новую организацию"
            )),
            event: { _ in },
            config: .previewConfig
        )
    }
}
