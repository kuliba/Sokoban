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
}

private extension FooterView {
    
    func footerView(
        _ footer: FooterState.Footer
    ) -> some View {
        
        VStack(spacing: 24) {
            
            VStack(spacing: 16) {
                
                footer.title.text(withConfig: config.title)
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
                }
                
                footer.subtitle.text(withConfig: config.subtitle)
                    .padding(.horizontal, 16)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    func failureView(
        _ failure: FooterState.Failure
    ) -> some View {
        
        VStack(spacing: 24) {
            
            Image.defaultIcon(
                foregroundColor: .gray,
                backgroundColor: config.background,
                icon: failure.image
            )
            
            descriptionView(failure.description)
                .padding(.horizontal, 16)
            
            payByInstructionButton()
                .frame(height: 56)
                .padding(.horizontal, 16)
        }
    }
    
    func descriptionView(
        _ description: String
    ) -> some View {
        
        description.text(
            withConfig: config.description, 
            alignment: .center
        )
    }
    
    func addCompanyButton() -> some View {
        
        ButtonSimpleView(
            viewModel: .init(
                title: config.addCompanyButtonTitle,
                buttonConfiguration: config.addCompanyButtonConfiguration,
                action: { event(.addCompany) }
            )
        )
    }
    
    func payByInstructionButton() -> some View {
        
        ButtonSimpleView(
            viewModel: .init(
                title: config.requisitesButtonTitle,
                buttonConfiguration: config.requisitesButtonConfig,
                action: { event(.payByInstruction) }
            )
        )
    }
}

// MARK: - Previews

struct FooterView_Previews: PreviewProvider {
    static var previews: some View {
        
        FooterView(
            state: .failure(.preview),
            event: { print($0) },
            config: .preview
        )
        
        FooterView(
            state: .footer(.preview),
            event: { print($0) },
            config: .preview
        )
    }
}

private extension FooterState.Failure {
    
    static let preview: Self = .init(
        image: .init(systemName: "magnifyingglass"),
        description: "Что-то пошло не так.\n Попробуйте позже или воспользуйтесь\n другим способом оплаты."
    )
}

private extension FooterState.Footer {
    
    static let preview: Self = .init(
        title: "Нет компании в списке?",
        description: "Воспользуйтесь другими способами оплаты",
        subtitle: "Сообщите нам, и мы подключим новую организацию"
    )
}

private extension FooterView.Config {
    
    static let preview: Self = .init(
        title: .init(
            textFont: .title3,
            textColor: .black
        ),
        description: .init(
            textFont: .body,
            textColor: .gray
        ),
        subtitle: .init(
            textFont: .body,
            textColor: .black
        ),
        background: .gray,
        requisitesButtonTitle: "Оплатить по реквизитам",
        requisitesButtonConfig: .init(
            titleFont: .body,
            titleForeground: .black,
            backgroundColor: .gray
        ),
        addCompanyButtonTitle: "Добавить организацию",
        addCompanyButtonConfiguration: .init(
            titleFont: .body,
            titleForeground: .blue,
            backgroundColor: .gray
        )
    )
}
