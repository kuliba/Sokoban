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
    let config: SelectViewConfiguration
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            switch viewModel.parameter.state {
            case .idle:
                IdleView(
                    viewModel: viewModel,
                    tapAction: viewModel.tapAction,
                    config: config.selectOptionConfig
                )
                .padding(.vertical, 24)
                
            case let .selected(selectedOptionViewModel):
                SelectedOptionView(
                    icon: .init(viewModel.icon.name ?? ""),
                    viewModel: selectedOptionViewModel,
                    tapAction: viewModel.tapAction,
                    config: config.selectOptionConfig
                )
                .padding(.vertical, 15)
                
            case let .list(optionsListViewModel):
                OptionsListView(
                    icon: .init(viewModel.icon.name ?? ""),
                    viewModel: optionsListViewModel,
                    config: config,
                    selected: viewModel.select
                )
                .padding(.vertical, 15)
            }
        }
        .padding(.horizontal, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

extension SelectView {
    
    struct IdleView: View {
        
        let viewModel: SelectViewModel
        let tapAction: () -> Void
        let config: SelectViewConfiguration.SelectedOptionConfig
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 16) {
                
                if let iconName = viewModel.icon.name {
                    
                    Image(iconName)
                        .resizable()
                        .foregroundColor(config.placeholderForeground)
                        .frame(width: 24, height: 24)
                }
                
                Text(viewModel.parameter.title)
                    .lineLimit(1)
                    .font(config.placeholderFont)
                    .foregroundColor(config.placeholderForeground)
                    .padding(.vertical, 7)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(config.placeholderForeground)
                    .frame(width: 24, height: 24, alignment: .center)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: tapAction)
        }
    }
    
    struct SelectedOptionView: View {
        
        let icon: Image
        let viewModel: SelectViewModel.ParameterSelect.State.SelectedOptionViewModel
        let tapAction: () -> Void
        let config: SelectViewConfiguration.SelectedOptionConfig
        
        var body: some View {
            
            HStack(alignment: .center, spacing: 16) {
                
                icon
                    .resizable()
                    .foregroundColor(config.placeholderForeground)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 7) {
                    
                    Text(viewModel.title)
                        .lineLimit(1)
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.6))
                    
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
            .onTapGesture(perform: tapAction)
        }
    }
    
    struct OptionsListView: View {
        
        let icon: Image
        let viewModel: SelectViewModel.ParameterSelect.State.OptionsListViewModel
        let config: SelectViewConfiguration
        let selected: (SelectViewModel.ParameterSelect.State.OptionsListViewModel.OptionViewModel) -> Void
        
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
        private func select(_ option: SelectViewModel.ParameterSelect.State.OptionsListViewModel.OptionViewModel?
        ) -> some View {
            
            HStack(alignment: .center, spacing: 16) {
                
                icon
                    .resizable()
                    .foregroundColor(config.selectOptionConfig.placeholderForeground)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text(viewModel.title)
                        .lineLimit(1)
                        .font(config.selectOptionConfig.placeholderFont)
                        .foregroundColor(config.selectOptionConfig.placeholderForeground)
                    
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
        private func option(
            option: SelectViewModel.ParameterSelect.State.OptionsListViewModel.OptionViewModel
        ) -> some View {
            
            SelectView.OptionView(
                viewModel: option,
                select: {
                    
                    selected(option)
                    
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
        
        let viewModel: SelectViewModel.ParameterSelect.State.OptionsListViewModel.OptionViewModel
        let select: () -> Void
        let config: SelectViewConfiguration.OptionConfig
        
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
                id: .transferTypeSticker,
                value: "value",
                title: "Выберите способ доставки",
                placeholder: "Выберите значение",
                options: [
                    .init(id: "option1", name: "option1", iconName: ""),
                    .init(id: "option2", name: "option2", iconName: "")
                ],
                state: .idle(.init(iconName: "", title: "Выберите значение"))),
                             icon: .named(""),
                             tapAction: { },
                             select: { id in }
            ),
            config: .default
        )
    }
}

extension SelectViewConfiguration {
    
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
