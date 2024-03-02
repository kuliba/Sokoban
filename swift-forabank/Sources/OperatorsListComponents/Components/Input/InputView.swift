//
//  InputView.swift
//
//
//  Created by Дмитрий Савушкин on 28.02.2024.
//

import SwiftUI

struct InputView: View {
    
    @State private var text: String = ""
    let icon: Icon
    let image: Image
    
    let title: String
    let placeholder: String
    let hint: String?
    
    let config: InputConfigView
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack(alignment: .center, spacing: 16) {
                
                image
                    .resizable()
                    .frame(width: icon == .small ? 24 : 32, height: icon == .small ? 24 : 32, alignment: .center)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(title)
                        .font(config.titleFont)
                        .foregroundColor(config.titleColor)
                    
                    TextField(placeholder, text: $text)
                }
            }
            
            if let hint {
                
                HStack(alignment: .center, spacing: 16) {
                    
                    Color.clear
                        .frame(width: icon == .small ? 24 : 32, height: icon == .small ? 24 : 32, alignment: .leading)
                    
                    Text(hint)
                        .font(config.hintFont)
                        .foregroundColor(config.hintColor)
                }
            }
        }
        .padding(.horizontal, icon == .small ? 16 : 12)
        .padding(.vertical, 13)
        .background(config.backgroundColor)
        .cornerRadius(12)
    }
    
    enum Icon {
        
        case small
        case large
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

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            InputView(
                icon: .large,
                image: .init(systemName: "photo.artframe"),
                title: "Лицевой счет",
                placeholder: "Введите лицевой счет",
                hint: nil,
                config: .init(
                    titleFont: .system(size: 12),
                    titleColor: .gray.opacity(0.8),
                    textFieldFont: .system(size: 14),
                    hintFont: .system(size: 10),
                    hintColor: .gray.opacity(0.7),
                    backgroundColor: .gray.opacity(0.3)
                )
            )
            .padding(20)
            
            InputView(
                icon: .small,
                image: .init(systemName: "photo.artframe"),
                title: "Лицевой счет",
                placeholder: "Введите лицевой счет",
                hint: "Сумма пени (в руб.) либо 0 если нет, если только копейки, то писать через 0, например: 0.30 - 30 копеек",
                config: .init(
                    titleFont: .system(size: 12),
                    titleColor: .gray.opacity(0.8),
                    textFieldFont: .system(size: 14),
                    hintFont: .system(size: 10),
                    hintColor: .gray.opacity(0.7),
                    backgroundColor: .gray.opacity(0.3)
                )
            )
            .padding(20)
        }
    }
}
