//
//  InputView.swift
//
//
//  Created by Дмитрий Савушкин on 28.02.2024.
//

import SwiftUI

struct InputView: View {
    
    @State private var text: String = ""
    let viewModel: InputViewModel
    
    let config: InputConfigView
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 16) {
                
                viewModel.image
                    .resizable()
                    .frame(width: viewModel.icon == .small ? 24 : 32, height: viewModel.icon == .small ? 24 : 32, alignment: .center)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(viewModel.title)
                        .font(config.titleFont)
                        .foregroundColor(config.titleColor)
                    
                    TextField(viewModel.placeholder, text: $text)
                }
            }
            
            if let hint = viewModel.hint {
                
                HStack(alignment: .center, spacing: 16) {
                    
                    Color.clear
                        .frame(width: viewModel.icon == .small ? 24 : 32, height: viewModel.icon == .small ? 24 : 32, alignment: .leading)
                    
                    Text(hint)
                        .font(config.hintFont)
                        .foregroundColor(config.hintColor)
                }
            }
        }
        .padding(.horizontal, viewModel.icon == .small ? 16 : 12)
        .padding(.vertical, 13)
        .background(config.backgroundColor)
        .cornerRadius(12)
    }
    
    struct InputConfigView {
        
        let titleFont: Font
        let titleColor: Color
        
        let textFieldFont: Font
        
        let hintFont: Font
        let hintColor: Color
        
        let backgroundColor: Color
    }
}

private extension InputView.InputConfigView {

    static let preview: Self = .init(
        titleFont: .system(size: 12),
        titleColor: .gray.opacity(0.8),
        textFieldFont: .system(size: 14),
        hintFont: .system(size: 10),
        hintColor: .gray.opacity(0.7),
        backgroundColor: .gray.opacity(0.1)
    )
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            InputView(
                viewModel: .init(
                    icon: .large,
                    image: .init(systemName: "photo.artframe"),
                    title: "Лицевой счет",
                    placeholder: "Введите лицевой счет",
                    hint: nil
                ),
                config: .preview
            )
            .padding(20)
            
            InputView(
                viewModel: .init(
                    icon: .small,
                    image: .init(systemName: "photo.artframe"),
                    title: "Лицевой счет",
                    placeholder: "Введите лицевой счет",
                    hint: "Сумма пени (в руб.) либо 0 если нет, если только копейки, то писать через 0, например: 0.30 - 30 копеек"
                ),
                config: .preview
            )
            .padding(20)
        }
    }
}
