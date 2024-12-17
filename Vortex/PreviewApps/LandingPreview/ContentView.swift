//
//  ContentView.swift
//  LandingPreview
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import LandingUIComponent
import SwiftUI

struct ContentView: View {
    
    @Environment(\.openURL) var openURL
    
    let landing: UILanding
    let action: (LandingEvent) -> Void
    
    var body: some View {
        
        VStack {
            
            GroupBox {
                
                VStack(spacing: 24) {
                    
                    Button("Go to Main") { action(.card(.goToMain)) }
                    
                    Button("Wanna Card?") { action(.card(.order(cardTarif: 11, cardType: 77))) }
                }
                .frame(maxWidth: .infinity)
            } label: {
                Text("Not yet a part of landing components, just a demo of wiring actions")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .padding(.horizontal)
            
            LandingView(
                viewModel: .init(
                    landing: .init(
                        header: [
                            .pageTitle(.init(
                                text: "",
                                subTitle: "",
                                transparency: false
                            ))
                        ],
                        main: [
                            .multi(.textsWithIconsHorizontal(.init(
                                lists: [.init(
                                    md5hash: "",
                                    title: "")
                                ])))
                        ],
                        footer: [
                            .multi(.buttons(.init(
                                list: [.init(
                                    text: "", style: "", detail: nil, link: nil, action: .none)
                                                             ])))],
                        details: []
                    ),
                    config: .init(listHorizontalRoundImage: .defaultValue, listHorizontalRectangleImage: .init(cornerRadius: 0, size: .init(height: 0, width: 0), paddings: .init(horizontal: 0, vertical: 0), spacing: 0), listVerticalRoundImage: .init(padding: .init(horizontal: 0, vertical: 0), title: .init(font: .body, color: .grayColor, paddingHorizontal: 0, paddingTop: 0), divider: .blue, spacings: .init(lazyVstack: 0, itemHstack: 0, buttonHStack: 0, itemVStackBetweenTitleSubtitle: 0), item: .init(imageWidthHeight: 0, hstackAlignment: .center, font: .init(title: .body, titleWithOutSubtitle: .body, subtitle: .body), color: .init(title: .gray, subtitle: .black), padding: .init(horizontal: 0, vertical: 0)), listVerticalPadding: 0, componentSettings: .init(background: .green, cornerRadius: 0), buttonSettings: .init(circleFill: .blue, circleWidthHeight: 0, ellipsisForegroundColor: .green, text: .init(font: .body, color: .gray), padding: .init(horizontal: 0, vertical: 0))), listDropDownTexts: .init(fonts: .init(title: .title, itemTitle: .body, itemDescription: .caption), colors: .init(title: .black, itemTitle: .gray, itemDescription: .grayLightest), paddings: .init(horizontal: 0, vertical: 0, titleTop: 0, titleHorizontal: 0, itemVertical: 0, itemHorizontal: 0), heights: .init(title: 0, item: 0), backgroundColor: .blue, cornerRadius: 0, divider: .grayColor, chevronDownImage: Image.flag), multiLineHeader: .defaultValueBlack, multiTextsWithIconsHorizontal: .defaultValueBlack, multiTexts: .defaultValue, multiMarkersText: .init(colors: .init(foreground: .init(black: .black, white: .white, defaultColor: .gray), backgroud: .init(gray: .gray, black: .black, white: .white, defaultColor: .gray)), vstack: .init(padding: .init(leading: 16, trailing: 16, vertical: 16)), internalContent: .init(spacing: 0, cornerRadius: 12, lineTextLeadingPadding: 16, textFont: .body)), multiButtons: .init(settings: .init(spacing: 0, padding: .init(horiontal: 16, top: 12, bottom: 12)), buttons: .init(backgroundColors: .init(first: .blue, second: .green), textColors: .init(first: .black, second: .white), padding: .init(horiontal: 0, vertical: 0), font: .body, height: 0, cornerRadius: 12)), multiTypeButtons: .init(paddings: .init(horizontal: 0, top: 0, bottom: 0), cornerRadius: 0, fonts: .init(into: .title, button: .body), spacing: 0, sizes: .init(imageInfo: 0, heightButton: 0), colors: .init(background: .init(black: .black, gray: .gray, white: .white), button: .red, buttonText: .black, foreground: .init(fgBlack: .black, fgWhite: .white))), pageTitle: .defaultValue, textWithIconHorizontal: .init(paddings: .init(horizontal: 0, vertical: 0), backgroundColor: .gray, cornerRadius: 0, circleSize: 0, icon: .init(width: 0, height: 0, placeholderColor: .grayLightest, padding: .init(vertical: 0, leading: 0)), height: 0, spacing: 0, text: .init(color: .blue, font: .body)), iconWithTwoTextLines: .init(paddings: .init(horizontal: 0, vertical: 0), icon: .init(size: 0, paddingBottom: 0), title: .init(font: .body, color: .gray, paddingBottom: 0), subTitle: .init(font: .title, color: .blue, paddingBottom: 0)), image: .init(background: .init(black: .black, gray: .gray, white: .white, defaultColor: .gray), paddings: .init(horizontal: 0, vertical: 0), cornerRadius: 12, negativeBottomPadding: 0), imageSvg: .init(background: .init(black: .black, gray: .gray, white: .white, defaultColor: .green), paddings: .init(horizontal: 0, vertical: 0), cornerRadius: 12), verticalSpacing: .init(spacing: .init(big: 0, small: 0, negativeOffset: 0), background: .init(black: .black, gray: .gray, white: .white)), offsetForDisplayHeader: 0)
                ),
                images: ["": Image.percent],
                action: { _ in },
                openURL: { _ in }
            )
            
        }
    }
}

/*struct ContentView_Previews: PreviewProvider {
 static var previews: some View {
 
 ContentView()
 }
 }*/
