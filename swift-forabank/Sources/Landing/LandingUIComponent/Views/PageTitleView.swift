//
//  PageTitleView.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

typealias ComponentPT = Landing.PageTitle
typealias ConfigPT = Landing.PageTitle.Config

struct PageTitleView: View {
    
    let model: ComponentPT
    let config: ConfigPT
    
    var body: some View {
        
        VStack {
            
            Text(model.text)
                .font(config.title.font)
                .foregroundColor(config.title.color)
            
            if let subtitle = model.subTitle {
                
                Text(subtitle)
                    .font(config.subtitle.font)
                    .foregroundColor(config.subtitle.color)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity,  alignment: .leading)
        .background(config.background)
    }
}

struct PageTitleView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            VStack{
                PageTitleView(
                    model:  .defaultValue1,
                    config: .defaultValue1)
            }
            .previewDisplayName("Непрозрачный")
            .frame(maxHeight: .infinity)
            .background(Color.red)

            VStack{
                PageTitleView(
                    model: .defaultValue2,
                    config: .defaultValue2)
            }
            .previewDisplayName("Прозрачный")
            .frame(maxHeight: .infinity)
            .background(Color.red)
        }
    }
}
