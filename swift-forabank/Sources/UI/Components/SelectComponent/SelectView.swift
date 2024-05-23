//
//  SelectView.swift
//
//
//  Created by Дмитрий Савушкин on 13.03.2024.
//

import Foundation
import SwiftUI
import SharedConfigs

public struct SelectView: View {
    
    var state: SelectUIState
    let event: (SelectEvent) -> Void
    let config: SelectConfig
    
    var searchText: String
    
    public init(
        state: SelectUIState,
        event: @escaping (SelectEvent) -> Void,
        searchText: String,
        config: SelectConfig
    ) {
        self.state = state
        self.event = event
        self.searchText = searchText
        self.config = config
    }
    
    public var body: some View {
        
        switch state.state {
        case let .collapsed(selectOption, options):
            
            horizontalView(selectOption)
                .padding(.horizontal, 16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .onTapGesture {
                    event(.chevronTapped(options: options, selectOption: selectOption))
                }
            
        case let .expanded(_, options, _):
            
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
                
                ForEach(options, content: optionView)
            }
        }
        .frame(height: 200)
    }
    
    private func horizontalView(
        _ option: SelectState.Option?
    ) -> some View {
        
        HStack(spacing: 16) {
            
            if let option {
                
                circleIcon(option, config.optionConfig)
                    .cornerRadius(20)
                
            } else {
                
                config.icon
                    .resizable()
                    .frame(width: 24, height: 24, alignment: .center)
                    .foregroundColor(config.foregroundIcon)
                    .background(config.backgroundIcon)
                    .cornerRadius(20)
            }
            
            switch state.state {
            case let .collapsed(selectOption, options):
                
                Text(selectOption?.title ?? config.title)
                    .foregroundColor(selectOption?.title != nil ? .black : Color.gray.opacity(0.6))
                    .frame(height: 72, alignment: .center)
                
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
                .onTapGesture {
                    event(.chevronTapped(options: self.state.state.options, selectOption: option))
                }
        }
    }
    
    private func textField() -> some View {
        
        TextField(
            "Начните ввод для поиска",
            text: .init(
                get: { searchText },
                set: { _ in event(.search(searchText)) }
            )
        )
    }
    
    private func optionView(
        _ option: SelectState.Option
    ) -> some View {
        
        Button(action: { event(.optionTapped(option)) }) {
            
            HStack(alignment: .top, spacing: 20) {
                
                circleIcon(option, config.optionConfig)
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
        
        Button(action: { event(.chevronTapped(options: self.state.state.options, selectOption: nil)) }, label: {
            
            switch state.state {
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
        _ config: SelectConfig.OptionConfig
    ) -> some View {
        
        ZStack {
            
            Circle()
                .frame(width: 32, height: 32)
                .foregroundColor(config.mainBackground)
                .background(config.mainBackground)
            
            (option.isSelected ? config.icon : config.selectIcon)
                .resizable()
                .renderingMode(.template)
                .frame(width: config.size, height: config.size)
                .foregroundColor(option.isSelected ? config.selectForeground : config.foreground)
        }
    }
}

struct SelectView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        selectView(.preview, .collapsed(option: nil, options: []))
            .previewDisplayName("collapse")
        
        selectView(.preview, .collapsed(option: .init(
            id: UUID().description,
            title: "Имущественный налог",
            isSelected: false
        ), options: []))
        .previewDisplayName("collapse with Option")
        
        
        selectView(.preview, .expanded(selectOption: .init(id: "1", title: "title", isSelected: true), options: previewOptionsWithCircleIcon(), searchText: ""))
            .previewDisplayName("expanded")
        
        selectView(
            configPreview2(isSearchable: false),
            .expanded(selectOption: .init(id: "1", title: "title", isSelected: true), options: previewOptionsWithCircleIcon(), searchText: "")
        )
        .previewDisplayName("preview Option with Circle icon")
        
        selectView(
            configPreview2(isSearchable: true),
            .expanded(selectOption: .init(id: "1", title: "title", isSelected: true), options: previewOptionsWithCircleIcon(), searchText: "")
        )
        .previewDisplayName("preview with searchable")
    }
    
    private static func selectView(
        _ config: SelectConfig,
        _ state: SelectState
    ) -> some View {
        
        SelectView(
            state: .init(image: config.icon, state: state),
            event: { _ in },
            searchText: "",
            config: config
            
        )
        .padding(.all, 20)
    }
    
    private static func configPreview2(
        isSearchable: Bool
    ) -> SelectConfig {
        
        .init(
            title: "Вид платежа",
            titleConfig: .init(textFont: .title3, textColor: .black),
            placeholder: isSearchable ? "Начните ввод для поиска" : "Выберите услугу",
            placeholderConfig: .init(textFont: .body, textColor: .gray),
            backgroundIcon: .clear,
            foregroundIcon: .gray.opacity(0.4),
            icon: .init(systemName: "doc"),
            isSearchable: isSearchable,
            optionConfig: .preview
        )
    }
    
    private static func previewOptions() -> [SelectState.Option] {
        
        [
            .init(
                id: UUID().uuidString,
                title: "Имущественный налог",
                isSelected: false
            ),
            .init(
                id: UUID().uuidString,
                title: "Транспортный налог",
                isSelected: false
            ),
            .init(
                id: UUID().uuidString,
                title: "Земельный налог",
                isSelected: false
            ),
            .init(
                id: UUID().uuidString,
                title: "Водный налог",
                isSelected: false
            )
        ]
    }
    
    private static func circleConfig() -> SelectConfig.OptionConfig {
        
        return .init(
            icon: Image(systemName: "circle"),
            foreground: .gray.opacity(0.3),
            background: .clear,
            selectIcon: Image(systemName: "record.circle"),
            selectForeground: .red,
            selectBackground: .clear,
            mainBackground: .clear,
            size: 24
        )
    }
    
    private static func previewOptionsWithCircleIcon() -> [SelectState.Option] {
        
        [
            .init(
                id: UUID().uuidString,
                title: "Оплата пакета МАТЧ! Футбол месяц",
                isSelected: false
            ),
            .init(
                id: UUID().uuidString,
                title: "Оплата пакета Новый год",
                isSelected: false
            ),
            .init(
                id: UUID().uuidString,
                title: "Оплата пакета Детский год",
                isSelected: false
            ),
            .init(
                id: UUID().uuidString,
                title: "Триколор ТВ - Ночной месяц",
                isSelected: true
            ),
            .init(
                id: UUID().uuidString,
                title: "Оплата пакета Единый/Единый\n UND/Экстра/Триколор Онлайн.",
                isSelected: false
            )
        ]
    }
}

public extension SelectConfig.OptionConfig {
    
    static let preview: Self = .init(
        icon: Image(systemName: "house"),
        foreground: .white,
        background: .blue,
        selectIcon: Image(systemName: "house"),
        selectForeground: .blue,
        selectBackground: .blue,
        mainBackground: .green,
        size: 16
    )
}

public extension SelectConfig {
    
    static let preview: Self = .init(
        title: "Тип услуги",
        titleConfig: .init(textFont: .title3, textColor: .black),
        placeholder: "Выберите услугу",
        placeholderConfig: .init(textFont: .body, textColor: .gray),
        backgroundIcon: .clear,
        foregroundIcon: .gray.opacity(0.6),
        icon: .init(systemName: "photo.artframe"),
        isSearchable: false,
        optionConfig: .preview
    )
}
