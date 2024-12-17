//
//  MuiltiTextsView.swift
//  
//
//  Created by Andryusina Nataly on 07.09.2023.
//

import SwiftUI
import Tagged

extension UILanding.Multi {
    
    struct TextsView: View {
        
        let model: Texts
        let config: Texts.Config
        
        init(model: Texts, config: Texts.Config) {
            self.model = model
            self.config = config
        }
        
        var body: some View {
            
            VStack(alignment: .leading) {
                
                VStack(spacing: config.spacing) {
                    
                    ForEach(model.texts) {
                        
                        Text($0.rawValue)
                            .foregroundColor(config.colors.text)
                            .font(config.font)
                            .accessibilityIdentifier("TextsViewText")
                    }
                }
                .padding(.horizontal, config.paddings.inside.horizontal)
                .padding(.vertical, config.paddings.inside.vertical)
                .background(config.colors.background)
                .cornerRadius(config.cornerRadius)
            }
            .padding(.horizontal, config.paddings.main.horizontal)
            .padding(.vertical, config.paddings.main.vertical)
        }
    }
}

struct TextsView_Previews: PreviewProvider {
    
    static var previews: some View {
       
        Group {
            UILanding.Multi.TextsView(
                model: .init(
                    texts: [
                        "*Акция «Кешбэк до 1000 руб. за первый перевод» – стимулирующее мероприятие, не является лотереей. Период проведения акции «Кешбэк до 1000 руб. за первый перевод» с 01 ноября 2022 по 31 января 2023 года. \nИнформацию об организаторе акции, о правилах, порядке, сроках и месте ее проведения можно узнать на официальном сайте www.forabank.ru и в офисах АКБ «ФОРА-БАНК» (АО).",
                        "** Участник Акции имеет право заключить с банком договор банковского счета с использованием карты МИР по тарифному плану «МИГ» или «Все включено-Промо» с бесплатным обслуживанием.",
                        "*** Банк выплачивает Участнику Акции кешбэк в размере 100% от суммы комиссии за первый перевод, но не более 1000 рублей."
                    ]),
                config: .defaultValue)
            .previewDisplayName("Full")
            
            UILanding.Multi.TextsView(
                model: .init(
                    texts: []),
                config: .defaultValue)
            .previewDisplayName("Empty")
        }
        .background(Color.white)
    }
}
