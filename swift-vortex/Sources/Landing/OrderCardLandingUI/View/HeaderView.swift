//
//  HeaderView.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 03.12.2024.
//

import SwiftUI
//import DropDownTextListComponent

struct HeaderView: View {
    
    typealias Model = Header
    typealias Config = HeaderViewConfig
    
    let model: Model
    let config: Config
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            model.backgroundImage
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            textView()
                .padding(.leading, 16)
                .padding(.trailing, 15)
        }
    }
}

private extension HeaderView {
    
    func textView() -> some View {
        
        //TODO: constants extract to config
        VStack(spacing: 26) {
            
            model.title.text(withConfig: config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 20) {
                
                ForEach(model.options, id: \.self, content: optionView)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func optionView(
        _ option: String
    ) -> some View {
        
        //TODO: constants extract to config
        HStack(alignment: .center, spacing: 5) {
            
            Circle()
                .foregroundStyle(config.optionPlaceholder)
                .frame(width: 5, height: 5, alignment: .center)
            
            Text(option)
                .frame(maxWidth: 150, alignment: .leading)
        }
    }
}

struct Header {
    
    let title: String
    let options: [String]
    let backgroundImage: Image
}

#Preview {
    
    ScrollView(.vertical, showsIndicators: false) {
        
        LazyVStack(spacing: 16) {
            
            HeaderView(
                model: .init(
                    title: "Карта МИР «Все включено»",
                    options: [
                        "кешбэк до 10 000 ₽ в месяц",
                        "5% выгода при покупке топлива",
                        "5% на категории сезона",
                        "от 0,5% до 1% кешбэк на остальные покупки**"
                    ],
                    backgroundImage: Image("orderCardLanding")
                ),
                config: .init(
                    title: .init(
                        textFont: .body,
                        textColor: .black
                    ),
                    optionPlaceholder: .black
                )
            )
        }
    }
}
