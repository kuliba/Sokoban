//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 28.09.2023.
//

import Foundation
import SwiftUI
import TextFieldComponent

extension PaymentSelectView {
    
    class ViewModel: ObservableObject {
        
        let state: State
        
        init(state: State) {
            
            self.state = state
        }
        
        enum State {
            
            case idle(IdleViewModel)
            case selected(SelectedOptionViewModel)
            case list(OptionsListViewModel)
        }
    }
}

extension PaymentSelectView.ViewModel {
    
    struct IdleViewModel {
        
        let icon: Image
        let title: String
        
        init(
            icon: Image,
            title: String
        ) {
            
            self.icon = icon
            self.title = title
        }
    }
    
    struct SelectedOptionViewModel {
        
        let icon: Image
        let title: String
        let name: String
        
        init(
            icon: Image,
            title: String,
            name: String
        ) {
            
            self.icon = icon
            self.title = title
            self.name = name
        }
    }
    
    class OptionsListViewModel: ObservableObject {
        
        let icon: Image
        let title: String
        let textField: TextFieldView
        @Published var filtered: [OptionViewModel]
        let selected: OptionViewModel.ID?
        
        private let options: [OptionViewModel]
        
        init(
            icon: Image,
            title: String,
            textField: TextFieldView,
            filtered: [OptionViewModel],
            options: [OptionViewModel],
            selected: OptionViewModel.ID?
        ) {
            
            self.icon = icon
            self.title = title
            self.textField = textField
            self.filtered = filtered
            self.options = options
            self.selected = selected
        }
    }
    
    struct OptionViewModel: Identifiable, Equatable {
        
        let id: String
        let icon: Image
        let name: String
        
        init(
            id: String,
            icon: Image,
            name: String
        ) {
            
            self.id = id
            self.icon = icon
            self.name = name
        }
    }
}

public struct PaymentSelectViewConfig {
    
    public struct PaymentSelectConfig {
        
        let selectOptionConfig: SelectedOptionConfig
        let optionsListConfig: OptionsListConfig
        let optionConfig: OptionConfig
    }
    
    public struct SelectedOptionConfig {
        
        public let titleFont: Font
        public let titleForeground: Color
        
        public init(
            titleFont: Font,
            titleForeground: Color
        ) {
            self.titleFont = titleFont
            self.titleForeground = titleForeground
        }
    }
    
    public struct OptionsListConfig {
        
        public let titleFont: Font
        public let titleForeground: Color
        
        public init(
            titleFont: Font,
            titleForeground: Color
        ) {
            self.titleFont = titleFont
            self.titleForeground = titleForeground
        }
    }
    
    public struct OptionConfig {
        
        public let nameFont: Font
        public let nameForeground: Color
        
        public init(
            nameFont: Font,
            nameForeground: Color
        ) {
            self.nameFont = nameFont
            self.nameForeground = nameForeground
        }
    }
}

struct PaymentSelectView: View {
    
    @ObservedObject var viewModel: ViewModel
    let config: PaymentSelectViewConfig.PaymentSelectConfig
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            switch viewModel.state {
            case let .idle(idleViewModel):
                IdleView(
                    viewModel: idleViewModel,
                    toggle: {},
                    config: config.selectOptionConfig
                )
                
            case let .selected(selectedOptionViewModel):
                SelectedOptionView(
                    viewModel: selectedOptionViewModel,
                    toggle: {},
                    config: config.selectOptionConfig
                )
                
            case let .list(optionsListViewModel):
                OptionsListView(
                    viewModel: optionsListViewModel,
                    config: config
                ) {
                    
                } selected: { optionId in
                    
                    //optionSelectedAction
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

extension PaymentSelectView {
    
    struct IdleView: View {
        
        let viewModel: PaymentSelectView.ViewModel.IdleViewModel
        let toggle: () -> Void
        let config: PaymentSelectViewConfig.SelectedOptionConfig
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 16) {
                
                viewModel.icon
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 7) {
                    
                    Text(viewModel.title)
                        .lineLimit(1)
                        .font(config.titleFont)
                        .foregroundColor(config.titleForeground)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24, alignment: .center)
            }
            .contentShape(Rectangle())
            .onTapGesture { toggle() }
        }
    }
    
    struct SelectedOptionView: View {
        
        let viewModel: PaymentSelectView.ViewModel.SelectedOptionViewModel
        let toggle: () -> Void
        let config: PaymentSelectViewConfig.SelectedOptionConfig
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 16) {
                
                viewModel.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 7) {
                    
                    Text(viewModel.title)
                        .lineLimit(1)
                        .font(config.titleFont)
                        .foregroundColor(config.titleForeground)
                    
                    Text(viewModel.name)
                        .lineLimit(1)
                        .font(config.titleFont)
                        .foregroundColor(config.titleForeground)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24, alignment: .center)
            }
            .contentShape(Rectangle())
            .onTapGesture { toggle() }
        }
    }
    
    struct OptionsListView: View {
        
        @ObservedObject var viewModel: PaymentSelectView.ViewModel.OptionsListViewModel
        let config: PaymentSelectViewConfig.PaymentSelectConfig
        let toggle: () -> Void
        let selected: (PaymentSelectView.ViewModel.OptionViewModel.ID) -> Void
        
        var body: some View {
            
            VStack {
                
                HStack(alignment: .center, spacing: 16) {
                    
                    viewModel.icon
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text(viewModel.title)
                            .foregroundColor(config.optionsListConfig.titleForeground)
                            .font(config.optionsListConfig.titleFont)
                        
                        viewModel.textField
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                        .foregroundColor(.gray)
                        .frame(width: 24, height: 24, alignment: .center)
                }
                
                ScrollView(.vertical) {
                    
                    VStack(spacing: 16) {
                        
                        ForEach(viewModel.filtered) { optionViewModel in
                            
                            PaymentSelectView.OptionView(
                                viewModel: optionViewModel,
                                isSelected: optionViewModel.id == viewModel.selected,
                                select: {
                                    
                                    selected(optionViewModel.id)
                                    
                                },
                                config: config.optionConfig
                            )
                            
                            if optionViewModel.id != viewModel.filtered.last?.id {
                                
                                Divider()
                                    .padding(.leading, 46)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 350)
            }
        }
    }
    
    struct OptionView: View {
        
        let viewModel: PaymentSelectView.ViewModel.OptionViewModel
        let isSelected: Bool
        let select: () -> Void
        let config: PaymentSelectViewConfig.OptionConfig
        
        var body: some View {
            
            VStack {
                
                HStack(alignment: .center, spacing: 12) {
                    
                    viewModel.icon
                        .resizable()
                        .frame(width: 32, height: 32)
                    
                    Text(viewModel.name)
                        .font(config.nameFont)
                        .foregroundColor(config.nameForeground)
                        .lineLimit(3)
                    
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { select() }
        }
    }
}

//MARK: - Preview

struct PaymentSelectView_Previews: PreviewProvider {
    
    private static func textField() -> TextFieldView {
        
        let textFieldConfig: TextFieldView.TextFieldConfig = .init(
            font: .systemFont(ofSize: 19, weight: .regular),
            textColor: .orange,
            tintColor: .black,
            backgroundColor: .clear,
            placeholderColor: .gray
        )
        
        return TextFieldView(
            state: .constant(.placeholder("Выберите значение")),
            keyboardType: .default,
            toolbar: nil,
            send: { action in
                
            },
            textFieldConfig: textFieldConfig
        )
    }
    
    static var previews: some View {
        
        Group {
            
            PaymentSelectView(viewModel: .init(state: .list(.init(
                icon: Image(systemName: "arrow.down.circle"),
                title: "Выберите способ доставки",
                textField: textField(),
                filtered: [
                    .init(
                        id: "1",
                        icon: Image(systemName: "bolt.horizontal.circle.fill"),
                        name: "Получить в офисе"),
                    .init(
                        id: "2",
                        icon: Image(systemName: "bolt.horizontal.circle.fill"),
                        name: "Доставка курьером")
                ],
                options: [.init(
                    id: "1",
                    icon: Image(systemName: "bolt.horizontal.circle.fill"),
                    name: "Получить в офисе")
                ],
                selected: nil
            ))), config: .init(selectOptionConfig: .init(
                titleFont: .body,
                titleForeground: .accentColor
            ), optionsListConfig: .init(
                titleFont: .body,
                titleForeground: .accentColor
            ), optionConfig: .init(
                nameFont: .body,
                nameForeground: .accentColor
            )))
            .padding()
        }
    }
}
