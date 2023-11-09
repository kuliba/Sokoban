//
//  SelectView.swift
//  
//
//  Created by Дмитрий Савушкин on 10.10.2023.
//

import Foundation
import SwiftUI
//import TextFieldComponent
//import TextFieldModel

struct SelectView: View {
    
    let viewModel: SelectViewModel
    let config: PaymentSelectViewConfig.PaymentSelectConfig
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            switch viewModel.parameter.state {
            case let .idle(idleViewModel):
                IdleView(
                    viewModel: idleViewModel,
                    chevronButtonTapped: viewModel.chevronButtonTapped,
                    config: config.selectOptionConfig
                )
                
            case let .selected(selectedOptionViewModel):
                SelectedOptionView(
                    viewModel: selectedOptionViewModel,
                    chevronButtonTapped: viewModel.chevronButtonTapped,
                    config: config.selectOptionConfig
                )
                
            case let .list(optionsListViewModel):
                OptionsListView(
                    viewModel: optionsListViewModel,
                    config: config,
                    chevronButtonTapped: viewModel.chevronButtonTapped,
                    selected: viewModel.select
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

extension SelectView {
    
    struct IdleView: View {
        
        let viewModel: SelectViewModel.Parameter.State.IdleViewModel
        let chevronButtonTapped: () -> Void
        let config: PaymentSelectViewConfig.SelectedOptionConfig
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 16) {
                
                Image(viewModel.iconName)
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
                
                Text(viewModel.title)
                    .lineLimit(1)
                    .font(config.titleFont)
                    .foregroundColor(config.titleForeground)
                    .padding(.vertical, 7)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24, alignment: .center)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: chevronButtonTapped)
        }
    }
    
    struct SelectedOptionView: View {
        
        let viewModel: SelectViewModel.Parameter.State.SelectedOptionViewModel
        let chevronButtonTapped: () -> Void
        let config: PaymentSelectViewConfig.SelectedOptionConfig
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 16) {
                
                Image(viewModel.iconName)
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
            .onTapGesture(perform: chevronButtonTapped)
        }
    }
    
    struct OptionsListView: View {
        
        let viewModel: SelectViewModel.Parameter.State.OptionsListViewModel
        let config: PaymentSelectViewConfig.PaymentSelectConfig
        let chevronButtonTapped: () -> Void
        let selected: (SelectViewModel.Parameter.State.OptionsListViewModel.OptionViewModel.ID) -> Void
        
        var body: some View {
            
            VStack {
                
                select(viewModel.options.first)
                
                ScrollView(.vertical) {
                    
                    VStack(spacing: 16) {
                        
                        ForEach(viewModel.options, content: option(option:))
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 350)
            }
        }
        
        @ViewBuilder
        private func select(_ option: SelectViewModel.Parameter.State.OptionsListViewModel.OptionViewModel?) -> some View {
            
            HStack(alignment: .center, spacing: 16) {
                
                Image(viewModel.iconName)
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(viewModel.title)
                        .lineLimit(1)
                        .font(config.selectOptionConfig.titleFont)
                        .foregroundColor(config.selectOptionConfig.titleForeground)
                    
                    Text(viewModel.placeholder)
                        .lineLimit(1)
                        .font(config.selectOptionConfig.placeholderFont)
                        .foregroundColor(config.selectOptionConfig.placeholderForeground)
                }
                
                Spacer()
                
                Image(systemName: "chevron.up")
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24, alignment: .center)
            }
        }
        
        @ViewBuilder
        private func option(option: SelectViewModel.Parameter.State.OptionsListViewModel.OptionViewModel) -> some View {
            
            SelectView.OptionView(
                viewModel: option,
                select: {
                    
                    selected(option.id)
                    
                },
                config: config.optionConfig
            )
            
            if option.id != viewModel.options.last?.id {
                
                Divider()
                    .padding(.leading, 46)
                    .padding(.trailing, 10)
            }
        }
    }
    
    struct OptionView: View {
        
        let viewModel: SelectViewModel.Parameter.State.OptionsListViewModel.OptionViewModel
        let select: () -> Void
        let config: PaymentSelectViewConfig.OptionConfig
        
        var body: some View {
            
            VStack {
                
                HStack(alignment: .center, spacing: 12) {
                    
                    Image(viewModel.iconName)
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

struct ParameterSelectView_Previews: PreviewProvider {
    
//    private static func textField() -> TextFieldView {
//
//        let textFieldConfig: TextFieldView.TextFieldConfig = .init(
//            font: .systemFont(ofSize: 19, weight: .regular),
//            textColor: .orange,
//            tintColor: .black,
//            backgroundColor: .clear,
//            placeholderColor: .gray
//        )
//
//        return .init(
//            state: .constant(.placeholder("Выберите значение")),
//            keyboardType: .default,
//            toolbar: nil,
//            send: { _ in },
//            textFieldConfig: textFieldConfig
//        )
//    }
    
    static var previews: some View {
        
        SelectView(
            viewModel: .init(parameter: .init(
                id: "id",
                value: "value",
                title: "Выберите способ доставки",
                placeholder: "Выберите значение",
                options: [
                    .init(id: "option1", name: "option1", iconName: ""),
                    .init(id: "option2", name: "option2", iconName: "")
                ],
                state: .idle(.init(iconName: "", title: "Выберите значение"))), chevronButtonTapped: {}, select: { id in }),
            config: .default
        )
    }
}

struct PaymentSelectViewConfig {
    
    struct PaymentSelectConfig {
        
        let selectOptionConfig: SelectedOptionConfig
        let optionsListConfig: OptionsListConfig
        let optionConfig: OptionConfig
    }
    
    struct SelectedOptionConfig {
        
        let titleFont: Font
        let titleForeground: Color
        let placeholderForeground: Color
        let placeholderFont: Font
    }
    
    struct OptionsListConfig {
        
        let titleFont: Font
        let titleForeground: Color
    }
    
    struct OptionConfig {
        
        let nameFont: Font
        let nameForeground: Color
    }
}

extension PaymentSelectViewConfig.PaymentSelectConfig {
    
    static let `default`: Self = .init(
        selectOptionConfig: .init(
            titleFont: .body,
            titleForeground: .accentColor,
            placeholderForeground: .gray,
            placeholderFont: .footnote
        ),
        optionsListConfig: .init(
            titleFont: .body,
            titleForeground: .accentColor
        ),
        optionConfig: .init(
            nameFont: .body,
            nameForeground: .accentColor
        )
    )
}
