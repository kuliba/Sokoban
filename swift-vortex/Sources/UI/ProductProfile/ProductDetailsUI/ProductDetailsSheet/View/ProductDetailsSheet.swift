//
//  ProductDetailsSheet.swift
//
//
//  Created by Andryusina Nataly on 12.03.2024.
//

import SwiftUI

struct ProductDetailsSheet: View {
    
    let buttons: [ProductDetailsSheetState.PanelButton] // state
    let event: (SheetButtonEvent) -> Void
    let config: SheetConfig
    
    var body: some View {
        
        VStack {
            
            config.image //ic24FileText
                .resizable()
                .padding(config.paddings.horizontal)
                .frame(
                    width: config.imageSizes.height,
                    height: config.imageSizes.height,
                    alignment: .center)
                .background(config.colors.background)//Color.mainColorsGrayLightest)
                .cornerRadius(config.imageSizes.cornerRadius)
                .accessibilityIdentifier("InfoProductSheetIcon")
            
            Text("Реквизиты карты")
                .font(config.fonts.title)//.textH3UnderlineM18240())
                .multilineTextAlignment(.center)
                .foregroundColor(config.colors.foreground)//.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, config.paddings.topTitle)
                .accessibilityIdentifier("InfoProductSheetTitle")
            
            Text("Вы можете поделиться всеми реквизитами (кроме CVV кода) или выбрать некоторые")
                .font(config.fonts.subtitle)//.textBodyMR14180())
                .multilineTextAlignment(.center)
                .foregroundColor(config.colors.subtitle)//.textPlaceholder)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, config.paddings.topSubtitle)
                .padding()
                .accessibilityIdentifier("InfoProductSheetSubtitle")
            
            ForEach(buttons, id: \.self, content: buttonView)
        }
        .frame(height: 397)
        .frame(maxWidth: .infinity)
    }
    
    private func buttonView(button: ProductDetailsSheetState.PanelButton) -> some View {
        
        Button(action: { event(button.event) }) {
            Text(button.title)
                .font(config.fonts.button)//.textH3UnderlineSb18240())
                .multilineTextAlignment(.center)
        }
        .frame(height: config.buttonSizes.height)
        .frame(maxWidth: .infinity)
        .background(config.colors.background)//.mainColorsGrayLightest)
        .cornerRadius(config.buttonSizes.cornerRadius)
        .foregroundColor(config.colors.foreground)//textSecondary)
        .padding(.horizontal, config.paddings.horizontal)
        .accessibilityIdentifier(button.accessibilityIdentifier)
    }
}

struct ProductDetailsSheet_Previews: PreviewProvider {
    
    static var previews: some View {
        ProductDetailsSheet(
            buttons: .previewRegular,
            event: { _ in },
            config: .preview)
    }
}
