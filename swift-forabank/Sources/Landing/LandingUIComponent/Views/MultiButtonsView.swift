//
//  MultiButtonsView.swift
//  UIComponentsForFB
//
//  Created by Andrew Kurdin on 2023-09-13.
//

import SwiftUI

// MARK: - View

struct MultiButtonsView: View {
    
    typealias Config = UILanding.Multi.Buttons.Config
    
    @ObservedObject var model: ViewModel
    private let config: Config
    
    init(
        model: ViewModel,
        config: Config
    ) {
        self.model = model
        self.config = config
    }
    
    var body: some View {
        
        VStack(spacing: config.settings.spacing) {
            ForEach(model.data.list, content: itemView)
        }
        .padding(.horizontal, config.settings.padding.horiontal)
        .padding(.top, config.settings.padding.top)
        .padding(.bottom, config.settings.padding.bottom)
        .accessibilityIdentifier("MultiButtonsBody")
    }
    
    private func itemView (
        item: UILanding.Multi.Buttons.Item
    ) -> some View {
        
        ItemView(
            item: item,
            config: config,
            action: { model.itemAction(item: item) }
        )
    }
}

extension MultiButtonsView {
    
    struct ItemView: View {
        let item: UILanding.Multi.Buttons.Item
        let config: Config
        let action: () -> Void
        
        public var body: some View {
            
            Button(action: action) {
                
                Text(item.text)
                    .font(config.buttons.font)
                    .padding(.vertical, config.buttons.padding.vertical)
                    .padding(.horizontal, config.buttons.padding.horiontal)
                    .frame(maxWidth: .infinity)
                    .background(config.backgroundColor(style: item.style))
                    .foregroundColor(config.textColor(style: item.style))
                    .cornerRadius(config.buttons.cornerRadius)
                    .accessibilityIdentifier("MultiButtonsButton")
            }
            .frame(height: config.buttons.height)
        }
    }
}

struct MultiButtons_Previews: PreviewProvider {
    
    public static var previews: some View {
        
        MultiButtonsView(
            model: .init(
                data: .defaultModel,
                selectDetail: { _ in },
                action: { _ in }
            ),
            config: .default
        )
        .padding(.vertical)
        .background(Color.black.opacity(0.25))
    }
}

// MARK: - For Preview MultiButtonsView
extension UILanding.Multi.Buttons {
    
    static let defaultModel: Self = .init(list: [
        .init(
            text: "Заказать карту Detail",
            style: "blackWhite",
            detail: .some(.init(groupId: "cardsLanding", viewId: "twoColorsLanding")),
            link: "",
            action: .none),
        .init(
            text: "Заказать карту Link",
            style: "blackWhite",
            detail: .some(.init(groupId: "cardsLanding", viewId: "twoColorsLanding")),
            link: "yandex.ru",
            action: .none),
        .init(
            text: "Войти и перевести action",
            style: "whiteRed",
            detail: .none,
            link: "",
            action: .some(.init(type: "goToMain")))
    ])
}
