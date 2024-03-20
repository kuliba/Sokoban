//
//  SelectView.swift
//
//
//  Created by Дмитрий Савушкин on 13.03.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

struct SelectView: View {
    
    let state: SelectState
    let event: (SelectEvent) -> Void
    let config: Config
    
    var searchText: String
    
    var body: some View {
        
        switch state {
        case let .collapsed(option):
            
            horizontalView(option)
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)
            
        case let .expanded(options):
            
            VStack(spacing: 20) {
                
                horizontalView(nil)
                
                scrollOptionView(options)
            }
            .padding(.top, 13)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(12)
        }
    }
    
    private func scrollOptionView(
        _ options: [SelectState.Option]
    ) -> some View {
        
        ScrollView(.vertical) {
            
            VStack(spacing: 20) {
                
                ForEach(options, id: \.id) { option in
                    
                    optionView(option)
                    
                }
            }
        }
        .frame(height: 200)
    }
    
    private func horizontalView(
        _ option: SelectState.Option?
    ) -> some View {
        
        HStack(spacing: 16) {
            
            if let option {
                
                circleIcon(option, option.config)
                    .cornerRadius(20)
                
            } else {
                
                config.icon
                    .resizable()
                    .frame(width: 24, height: 24, alignment: .center)
                    .foregroundColor(config.foregroundIcon)
                    .background(config.backgroundIcon)
                    .cornerRadius(20)
            }
            
            switch state {
            case let .collapsed(option):
                
                Text(option?.title ?? config.title)
                    .foregroundColor(option?.title != nil ? .black : Color.gray.opacity(0.6))
                
            case .expanded:
            
                VStack(spacing: 4) {
                    
                    HStack {
                        
                        config.title.text(
                            withConfig: config.titleConfig
                        )
                        .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    
                    HStack {
                    
                        if config.isSearchable {
                            
                            textField()
                                .frame(height: 24)
                            
                        } else {
                            
                            Text(config.placeholder)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        
                        Spacer()
                    }
                }
            }
            
            Spacer()
            
            chevronButton()
        }
    }
    
    private func textField() -> some View {
        
        TextField(
            "Начните ввод для поиска",
            text: .init(
                get: { searchText },
                set: { _ in event(.search) }
            )
        )
    }
    
    private func optionView(
        _ option: SelectState.Option
    ) -> some View {
        
        Button(action: { event(.optionTapped) }) {
            
            HStack(alignment: .top, spacing: 20) {
                
                circleIcon(option, option.config)
                    .cornerRadius(20)
                    .frame(height: 50, alignment: .top)
            }
            
            VStack(spacing: 20) {
                
                HStack(spacing: 20) {
                    
                    Text(option.title)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                
                Color.gray
                    .frame(width: .infinity, height: 1, alignment: .center)
                    .opacity(0.2)
            }
        }
    }
    
    private func chevronButton() -> some View {
        
        Button(action: { event(.chevronTapped) }, label: {
            
            switch state {
            case .collapsed:
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                
            case .expanded:
                Image(systemName: "chevron.up")
                    .foregroundColor(.gray)
            }
        })
    }
    
    private func circleIcon(
        _ option: SelectState.Option,
        _ config: SelectState.Option.Config
    ) -> some View {
        
        ZStack {
            
            Circle()
                .frame(width: 32, height: 32)
                .foregroundColor(config.mainBackground)
                .background(config.mainBackground)
            
            (option.isSelected ? config.icon : config.selectIcon)
                .resizable()
                .renderingMode(.template)
                .frame(width: CGFloat(config.kind.rawValue), height: CGFloat(config.kind.rawValue))
                .foregroundColor(option.isSelected ? config.selectForeground : config.foreground)
        }
    }
}

extension SelectView {
    
    struct Config {
        
        let title: String
        let titleConfig: TextConfig
        
        let placeholder: String
        let placeholderConfig: TextConfig
        
        let backgroundIcon: Color
        let foregroundIcon: Color
        let icon: Image
        
        let isSearchable: Bool
    }
}

struct SelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        selectView(configPreview(), .collapsed(option: nil))
            .previewDisplayName("collapse")
        
        selectView(configPreview(), .collapsed(option: .init(
            id: UUID().description,
            title: "Имущественный налог",
            isSelected: false,
            config: randomConfig()
        )))
        .previewDisplayName("collapse with Option")
        
        
        selectView(configPreview(), .expanded(options: previewOptions()))
            .previewDisplayName("expanded")
        
        selectView(
            configPreview2(isSearchable: false),
            .expanded(options: previewOptionsWithCircleIcon())
        )
        .previewDisplayName("preview Option with Circle icon")
        
        selectView(
            configPreview2(isSearchable: true),
            .expanded(options: previewOptionsWithCircleIcon())
        )
        .previewDisplayName("preview with searchable")
    }
    
    private static func selectView(
        _ config: SelectView.Config,
        _ state: SelectState
    ) -> some View {
        
        SelectView(
            state: state,
            event: { _ in },
            config: config,
            searchText: ""
        )
        .padding(.all, 20)
    }
    
    private static func configPreview() -> SelectView.Config {
        
        .init(
            title: "Тип услуги",
            titleConfig: .init(textFont: .title3, textColor: .black),
            placeholder: "Выберите услугу",
            placeholderConfig: .init(textFont: .body, textColor: .gray),
            backgroundIcon: .clear,
            foregroundIcon: .gray.opacity(0.6),
            icon: .init(systemName: "photo.artframe"),
            isSearchable: false
        )
    }
    
    private static func configPreview2(
        isSearchable: Bool
    ) -> SelectView.Config {
        
        .init(
            title: "Вид платежа",
            titleConfig: .init(textFont: .title3, textColor: .black),
            placeholder: isSearchable ? "Начните ввод для поиска" : "Выберите услугу",
            placeholderConfig: .init(textFont: .body, textColor: .gray),
            backgroundIcon: .clear,
            foregroundIcon: .gray.opacity(0.4),
            icon: .init(systemName: "doc"), 
            isSearchable: isSearchable
        )
    }
    
    private static func previewOptions() -> [SelectState.Option] {
        
        [
            .init(
                id: UUID().uuidString,
                title: "Имущественный налог",
                isSelected: false,
                config: randomConfig()
            ),
            .init(
                id: UUID().uuidString,
                title: "Транспортный налог",
                isSelected: false,
                config: randomConfig()
            ),
            .init(
                id: UUID().uuidString,
                title: "Земельный налог",
                isSelected: false,
                config: randomConfig()
            ),
            .init(
                id: UUID().uuidString,
                title: "Водный налог",
                isSelected: false,
                config: randomConfig()
            )
        ]
    }
    
    private static func randomConfig() -> SelectState.Option.Config {
        
        let icons = [
            Image(systemName: "house"),
            Image(systemName: "car"),
            Image(systemName: "square.dashed"),
            Image(systemName: "drop.degreesign")
            
        ]
        
        return .init(
            icon: icons.randomElement() ?? Image(systemName: "house"),
            foreground: .white,
            background: .blue,
            selectIcon: icons.randomElement() ?? Image(systemName: "house"),
            selectForeground: .blue,
            selectBackground: .blue,
            mainBackground: .green,
            kind: .small
        )
    }
    
    private static func circleConfig() -> SelectState.Option.Config {
        
        return .init(
            icon: Image(systemName: "circle"),
            foreground: .gray.opacity(0.3),
            background: .clear,
            selectIcon: Image(systemName: "record.circle"),
            selectForeground: .red,
            selectBackground: .clear,
            mainBackground: .clear,
            kind: .normal
        )
    }
    
    private static func previewOptionsWithCircleIcon() -> [SelectState.Option] {
        
        [
            .init(
                id: UUID().uuidString,
                title: "Оплата пакета МАТЧ! Футбол месяц",
                isSelected: false,
                config: circleConfig()
            ),
            .init(
                id: UUID().uuidString,
                title: "Оплата пакета Новый год",
                isSelected: false,
                config: circleConfig()
            ),
            .init(
                id: UUID().uuidString,
                title: "Оплата пакета Детский год",
                isSelected: false,
                config: circleConfig()
            ),
            .init(
                id: UUID().uuidString,
                title: "Триколор ТВ - Ночной месяц",
                isSelected: true,
                config: circleConfig()
            ),
            .init(
                id: UUID().uuidString,
                title: "Оплата пакета Единый/Единый\n UND/Экстра/Триколор Онлайн.",
                isSelected: false,
                config: circleConfig()
            )
        ]
    }
}
