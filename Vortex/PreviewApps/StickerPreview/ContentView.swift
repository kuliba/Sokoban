//
//  ContentView.swift
//  StickerPreview
//
//  Created by Дмитрий Савушкин on 20.10.2023.
//

import PaymentSticker
import SwiftUI

struct ContentView: View {
    
    var body: some View {
      
        OperationView(
            model: .preview,
            configuration: .init(
                tipViewConfig: .preview,
                stickerViewConfig: .preview,
                selectViewConfig: .preview,
                productViewConfig: .preview,
                inputViewConfig: .preview,
                amountViewConfig: .preview
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension OperationViewConfiguration {
    
    static let preview: Self = .init(
        tipViewConfig: .preview,
        stickerViewConfig: .preview,
        selectViewConfig: .preview,
        productViewConfig: .preview,
        inputViewConfig: .preview,
        amountViewConfig: .preview
    )
}

extension StickerViewConfiguration {
    
    static let preview: Self = .init(
        rectangleColor: .gray,
        configHeader: .init(
            titleFont: .title3,
            titleColor: .black,
            descriptionFont: .body,
            descriptionColor: .black
        ),
        configOption: .init(
            titleFont: .body,
            titleColor: .black,
            iconColor: .green,
            descriptionFont: .body,
            descriptionColor: .gray,
            optionFont: .body,
            optionColor: .gray
        )
    )
}
extension SelectViewConfiguration {
    
    static let preview: Self = .init(
        selectOptionConfig: .init(
            titleFont: .title3,
            titleForeground: .black,
            placeholderForeground: .gray,
            placeholderFont: .body
        ),
        optionsListConfig: .init(
            titleFont: .title3,
            titleForeground: .black
        ),
        optionConfig: .init(
            nameFont: .body,
            nameForeground: .black
        )
    )
}
extension ProductView.Appearance {
    
    static let preview: Self = .init(
        headerTextColor: .black,
        headerTextFont: .title3,
        textColor: .black,
        textFont: .body,
        optionConfig: .init(
            numberColor: .black,
            numberFont: .body,
            nameColor: .black,
            nameFont: .body,
            balanceColor: .black,
            balanceFont: .body
        ),
        background: .init(color: .gray)
    )
}
extension InputConfiguration {
    
    static let preview: Self = .init(
        titleFont: .title3,
        titleColor: .black,
        iconColor: .gray,
        iconName: "photo.artframe"
    )
}

extension AmountViewConfiguration {
    
    static let preview: Self = .init(
        amountFont: .title3,
        amountColor: .white,
        buttonTextFont: .body,
        buttonTextColor: .white,
        buttonColor: .red,
        hintFont: .body,
        hintColor: .gray,
        background: .black
    )
}

extension TipViewConfiguration {

    static let preview: Self = .init(
        titleFont: .title3,
        titleForeground: .black,
        backgroundView: .gray
    )
}
