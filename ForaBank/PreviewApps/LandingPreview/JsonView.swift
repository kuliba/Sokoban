//
//  JsonView.swift
//  LandingPreview
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import LandingMapping
import LandingUIComponent
import SwiftUI

struct JsonView: View {
    
    @State var text: String = .multiLineHeader
    @State private var showingLandingView: Bool = false
    @State private var showingAlert = false
    @State private var landing: LandingUIComponent.Landing?
    
    @State private var alertID: AlertID?
    
    enum AlertID: Identifiable, Hashable {
        
        case orderCard(cardTarif: Int, cardType: Int)
        
        var id: Self { self }
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                TextEditor(text: $text)
                
                Button(action: {
                    do {
                        let a = try parse(string: text)
                        let detail = Detail(
                            groupID: "GroupID_123",
                            viewID: "ViewID_abc"
                        )
                        let detailButton: LandingComponent = .detailButton(detail)
                        landing = .init(data: a).appendingToMain(component: detailButton)
                        showingLandingView = true
                    } catch {
                        showingAlert = true
                    }
                }) {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.gray)
                        
                        Text("Продолжить")
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 48)
                .padding()
                
                NavigationLink(
                    "",
                    destination: destination,
                    isActive: .init(
                        get: { landing != nil },
                        set: { if !$0 { landing = nil } }
                    )
                )
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Ошибка"), message: Text("Некорректный JSON"), dismissButton: .default(Text("Ok")))
            }
            .animation(.default, value: landing)
        }
    }
    
    private var destination: some View {
        
        landing.map { landing in
            
            ContentView(
                landing: landing,
                action: action
            )
            .alert(item: $alertID, content: alert)
        }
    }
    
    private func action(
        _ landingAction: LandingAction
    ) {
        switch landingAction {
        case .goToMain:
            landing = nil
            
        case let .orderCard(cardTarif: cardTarif, cardType: cardType):
            alertID = .orderCard(cardTarif: cardTarif, cardType: cardType)
        }
    }
    
    private func alert(alertID: AlertID) -> Alert {
        
        switch alertID {
        case let .orderCard(cardTarif: cardTarif, cardType: cardType):
            
            return Alert(
                title: Text("Ordered a card with tariff \(cardTarif) of type \(cardType)")
            )
        }
    }
}

extension LandingUIComponent.Landing {
    
    func appendingToMain(
        component: LandingComponent
    ) -> Self {
    
        .init(
            header: header,
            main: main + [component],
            footer: footer
        )
    }
}

struct JsonView_Previews: PreviewProvider {
    static var previews: some View {
        JsonView()
    }
}

private func parse(string: String) throws -> LandingMapping.Landing {
    
    let data = Data(string.utf8)
    return try LandingMapper.map(
        data,
        anyHTTPURLResponse()
    ).get()
}


private extension LandingUIComponent.Landing {
    
    init(
        data: LandingMapping.Landing
    ) {
        
        let header: [LandingComponent] = data.header.map { LandingComponent.init(data: $0)}
        let main: [LandingComponent] = data.main.map { LandingComponent.init(data: $0)}
        let footer: [LandingComponent] = []
        
        self.init(header: header, main: main, footer: footer)
    }
}


private extension LandingUIComponent.LandingComponent {
    
    init(
        data: LandingMapping.Landing.DataView
    ) {
        switch data {
            
            /*case let .iconWithTwoTextLines(x):
             return (LandingComponents.IconWithTwoTextLines(data: x), LandingComponents.IconWithTwoTextLines*/
        case let .listHorizontalRoundImage(x):
                self = .listHorizontalRoundImage(.init(data: x), .defaultValue)
        case let .multiLineHeader(x):
                self = .multiLineHeader(.init(data: x), .init(
                    backgroundColor: .white,
                    item: .defaultValueBlack))
        case let .pageTitle(x):
                self = .pageTitle(.init(data: x), .defaultValue)
        case let .multiTextsWithIconsHorizontalArray(x):
                self = .multiTextsWithIconsHorizontal(.init(data: x), .defaultValueBlack)
            
        case let .textsWithIconHorizontal(x):
                self = .textWithIconHorizontal(.init(data: x))
        default:
            self = .empty
        }
    }
}

private extension LandingUIComponent.Landing.IconWithTwoTextLines {
    
    init(
        data: LandingMapping.Landing.IconWithTwoTextLines
    ) {
        
        self.init(image: .init(systemName: "flag"), title: data.title, subTitle: data.subTitle)
    }
}

private extension LandingUIComponent.Landing.ListHorizontalRoundImage {
    
    init(
        data: LandingMapping.Landing.ListHorizontalRoundImage
    ) {
        let lists: [LandingUIComponent.Landing.ListHorizontalRoundImage.ListItem]? = data.list?.map {
            Landing.ListHorizontalRoundImage.ListItem.init(data: $0)
        }
        self.init(title: data.title, list: lists ?? [], config: .defaultValue)
    }
}

private extension LandingUIComponent.Landing.ListHorizontalRoundImage.ListItem {
    
    init(
        data: LandingMapping.Landing.ListHorizontalRoundImage.ListItem
    ) {
        
        self.init(image: .bolt, title: data.title, subInfo: data.subInfo, details: .init(data: data.details))
    }
}

private extension LandingUIComponent.Landing.ListHorizontalRoundImage.ListItem.Details {
    
    init(
        data: LandingMapping.Landing.ListHorizontalRoundImage.ListItem.Details
    ) {
        
        self.init(detailsGroupId: data.detailsGroupId, detailViewId: data.detailViewId)
    }
}

private extension LandingUIComponent.Landing.MultiLineHeader {
    
    init(
        data: LandingMapping.Landing.MultiLineHeader
    ) {
        self.init(
            regularTextList: data.regularTextList,
            boldTextList: data.boldTextList
        )
    }
}

private extension LandingUIComponent.Landing.PageTitle {
    
    init(
        data: LandingMapping.Landing.PageTitle
    ) {
        self.init(
            text: data.text,
            subTitle: data.subtitle,
            transparency: data.transparency)
    }
}

private extension LandingUIComponent.Landing.MultiTextsWithIconsHorizontal {
    
    init(
        data: LandingMapping.Landing.MuiltiTextsWithIconsHorizontal
    ) {
        self.init(lists: data.list.map {
            .init(image: .percent, title: $0.title)
        })
    }
}

private extension LandingUIComponent.Landing.TextsWithIconHorizontal {
    
    init(
        data: LandingMapping.Landing.TextsWithIconHorizontal
    ) {
        self.init(image: .shield, title: data.title, contentCenterAndPull: data.contentCenterAndPull)
    }
}


extension Color {
    
    static let grayColor: Self = .init(red: 0.83, green: 0.83, blue: 0.83)
    static let textSecondary: Self = .init(red: 0.11, green: 0.11, blue: 0.11)
    static let grayLightest: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
}

extension Image {
    
    static let bolt: Self = .init(systemName: "bolt")
    static let percent: Self = .init(systemName: "percent")
    static let shield: Self = .init(systemName: "shield")
    static let flag: Self = .init(systemName: "flag")

}

extension LandingUIComponent.Landing.ListHorizontalRoundImage.Config {
    
    static let defaultValue: Self = .init(
        backgroundColor: .grayLightest,
        title: .defaultValue,
        subtitle: .defaultValue,
        detail: .defaultValue
    )
}

extension LandingUIComponent.Landing.ListHorizontalRoundImage.Config.Title {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        font: .title
    )
}

extension LandingUIComponent.Landing.ListHorizontalRoundImage.Config.Subtitle {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        background: .white,
        font: .title
    )
}

extension LandingUIComponent.Landing.ListHorizontalRoundImage.Config.Detail {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        font: .body
    )
}

extension LandingUIComponent.Landing.MultiLineHeader.Config {
    
    static let defaultValueBlack: Self = .init(
        backgroundColor: .black,
        item: .defaultValueWhite
    )
    static let defaultValueWhite: Self = .init(
        backgroundColor: .white,
        item: .defaultValueBlack
    )
    static let defaultValueGray: Self = .init(
        backgroundColor: .gray,
        item: .defaultValueBlack
    )
}
extension LandingUIComponent.Landing.MultiLineHeader.Config.Item {
    
    static let defaultValueBlack: Self = .init(
        color: .black,
        fontRegular: .title,
        fontBold: .bold(.title)())
    static let defaultValueWhite: Self = .init(
        color: .white,
        fontRegular: .title,
        fontBold: .bold(.title)())
}

extension LandingUIComponent.Landing.MultiTextsWithIconsHorizontal.Config {
    
    static let defaultValueBlack: Self = .init(
        color: .black,
        font: .body)
}

extension LandingUIComponent.Landing.PageTitle.Config {
    
    static let defaultValue: Self = .init(
        title: .init(color: .black, font: .title),
        subtitle: .init(color: .gray, font: .body),
        transparency: true)
}

private extension String {
    
    static let multiLineHeader: Self = """
{
   "data":{
      "header":[
         {
            "type":"PAGE_TITLE",
            "data":{
               "text":"Переводы за рубеж",
               "transparency":true
            }
         }
      ],
      "main":[
        {
            "type": "IMAGE",
            "data": {
                "isPlaceholder": false,
                "imageLink": "dict/getProductCatalogImage?image=/products/banners/Header_abroad.png",
                "backgroundColor": "WHITE"
            }
        },
         {
            "type":"MULTI_LINE_HEADER",
            "data":{
               "backgroundColor":"WHITE",
               "regularTextList":[
                  "Переводы"
               ],
               "boldTextList":[
                  "за рубеж"
               ]
            }
         },
         {
            "type":"MULTI_TEXTS_WITH_ICONS_HORIZONTAL",
            "data":[
               {
                  "md5hash":"a442191010ad33a883625f93d91037b1",
                  "title":"Быстро"
               },
               {
                  "md5hash":"7df826030e8d418be0a33edde3a26ad0",
                  "title":"Безопасно"
               },
               {
                  "md5hash":"5d9427225e136f31d26a211b9207dc3b",
                  "title":"Выгодно"
               }
            ]
         },
         {
            "type": "MULTI_BUTTONS",
            "data": {
              "list": [
                {
                  "buttonText": "Заказать карту",
                  "buttonStyle": "blackWhite",
                  "details": {
                    "detailsGroupId": "cardsLanding",
                    "detailViewId": "twoColorsLanding"
                  }
                },
                {
                  "buttonText": "Войти и перевести",
                  "buttonStyle": "whiteRed",
                  "action": {
                    "actionType": "goToMain"
                  }
                }
              ]
            }
          },
         {
            "type":"LIST_HORIZONTAL_ROUND_IMAGE",
            "data":{
               "title":"Популярные направления",
               "list":[
                  {
                     "md5hash":"6046e5eaff596a41ce9845cca3b0a887",
                     "title":"Армения",
                     "subInfo":"1%",
                     "details":{
                        "detailsGroupId":"forCountriesList",
                        "detailViewId":"Armeniya"
                     }
                  },
                  {
                     "md5hash":"6046e5eaff596a41ce9845cca3b0a88",
                     "title":"Узбекистан",
                     "subInfo":"1.5%",
                     "details":{
                        "detailsGroupId":"forCountriesList",
                        "detailViewId":"Uzbekistan"
                     }
                  }

               ]
            }
         }
      ],
      "footer":[
         
      ],
      "details":[
         {
            "detailsGroupId":"bannersLanding",
            "dataGroup":[
               {
                  "detailViewId":"moreTransfers",
                  "dataView":[
                     {
                        "type":"ICON_WITH_TWO_TEXT_LINES",
                        "data":{
                           "md5hash":"6046e5eaff596a41ce9845cca3b0a887",
                           "title":"Больше возможностей при переводах в Армению"
                        }
                     },
                     {
                        "type":"TEXTS_WITH_ICON_HORIZONTAL",
                        "data":{
                           "md5hash":"411d86beb3c9e68dfd8dd46bd544ea49",
                           "title":"Теперь до 1 000 000 ₽",
                           "contentCenterAndPull":true
                        }
                     }
                  ]
               }
            ]
         }
      ],
      "serial":"41c44e57adfeb9af7535139c495dd181"
   }
}
"""
}

private func anyHTTPURLResponse(
    _ statusCode: Int = 200
) -> HTTPURLResponse {
    
    .init(
        url: URL(string: "https://www.forabank.ru/")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil)!
}
