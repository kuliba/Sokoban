//
//  JsonView.swift
//  LandingPreview
//
//  Created by Andryusina Nataly on 31.08.2023.
//

import LandingMapping
import LandingUIComponent
import SwiftUI
import Tagged

struct JsonView: View {
    
    @State var text: String = .multiLineHeader
    @State private var showingLandingView: Bool = false
    @State private var showingAlert = false
    @State private var landing: LandingUIComponent.UILanding?
    
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
                            dataGroup: []
                        )
                        let detailButton: UILanding.Component = .detailButton(detail)
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

extension LandingUIComponent.UILanding {
    
    func appendingToMain(
        component: UILanding.Component
    ) -> Self {
        
        .init(
            header: header,
            main: main + [component],
            footer: footer,
            details: [],
            config: .defaultValue
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


private extension LandingUIComponent.UILanding {
    
    init(
        data: LandingMapping.Landing
    ) {
        
        let header: [Component] = data.header.compactMap(Component.init(data:))
        let main: [Component] = data.main.compactMap( Component.init(data:))
        let footer: [Component] = data.footer.compactMap(Component.init(data:))
        let details: [Detail] = []
        
        self.init(header: header, main: main, footer: footer, details: details, config: .defaultValue)
    }
}

private extension UILanding.Component.Config {
    
    static let defaultValue: Self = .init(listHorizontalRoundImage: .defaultValue, listHorizontalRectangleImage: .init(cornerRadius: 10), listVerticalRoundImage: .emptyConfig, listDropDownTexts: .emptyConfig, multiLineHeader: .defaultValueGray, multiTextsWithIconsHorizontal: .defaultValueBlack, multiTexts: .defaultValue, multiMarkersText: .emptyConfig, multiButtons: .emptyConfig, multiTypeButtons: .emptyConfig, pageTitle: .defaultValue, textWithIconHorizontal: .emptyConfig, detailButton: .emptyConfig, iconWithTwoTextLines: .emptyConfig, image: .emptyConfig, imageSvg: .emptyConfig, verticalSpacing: .emptyConfig, notImplemented: .emptyConfig)
}

private extension LandingUIComponent.UILanding.Component {
    
    init(
        data: LandingMapping.Landing.DataView
    ) {
        switch data {
            
        case let .list(.horizontalRoundImage(x)):
            self = .list(.horizontalRoundImage(.init(data: x)))
        case let .multi(.lineHeader(x)):
            self = .multi(.lineHeader(.init(data: x)))
        case let .pageTitle(x):
            self = .pageTitle(.init(data: x))
        case let .multi(.textsWithIconsHorizontalArray(x)):
            self = .multi(.textsWithIconsHorizontal(.init(data: x)))
        case let .textsWithIconHorizontal(x):
            self = .textWithIconHorizontal(.init(data: x))
        case let .multi(.text(x)):
            self = .multi(.texts(.init(data: x)))

            // TODO: исправить после реализации всех кейсов!!!
        default:
            self = .notImplemented
        }
    }
}

private extension LandingUIComponent.UILanding.Multi.Texts {
    
    init(
        data: LandingMapping.Landing.MultiText
    ) {
        
        self.init(texts: data.text.map{ .init($0.rawValue) })
    }
}

private extension LandingUIComponent.UILanding.IconWithTwoTextLines {
    
    init(
        data: LandingMapping.Landing.IconWithTwoTextLines
    ) {
        
        self.init(md5hash: data.md5hash, title: data.title, subTitle: data.subTitle)
    }
}

private extension LandingUIComponent.UILanding.List.HorizontalRoundImage {
    
    init(
        data: LandingMapping.Landing.ListHorizontalRoundImage
    ) {
        let lists: [LandingUIComponent.UILanding.List.HorizontalRoundImage.ListItem]? = data.list?.map {
            LandingUIComponent.UILanding.List.HorizontalRoundImage.ListItem(data: $0)
        }
        self.init(title: data.title, list: lists ?? [])
    }
}

private extension LandingUIComponent.UILanding.List.HorizontalRoundImage.ListItem {
    
    init(
        data: LandingMapping.Landing.ListHorizontalRoundImage.ListItem
    ) {
        
        self.init(imageMd5Hash: "1", title: data.title, subInfo: data.subInfo, detail: data.detail.map{ .init(data: $0) })
    }
}

private extension LandingUIComponent.UILanding.List.HorizontalRoundImage.ListItem.Detail {
    
    init(
        data: LandingMapping.Landing.ListHorizontalRoundImage.ListItem.Detail
    ) {
        
        self.init(groupId: data.groupId.rawValue, viewId: data.viewId.rawValue)
    }
}

private extension LandingUIComponent.UILanding.Multi.LineHeader {
    
    init(
        data: LandingMapping.Landing.MultiLineHeader
    ) {
        self.init(
            backgroundColor: "WHITE",
            regularTextList: data.regularTextList,
            boldTextList: data.boldTextList
        )
    }
}

private extension LandingUIComponent.UILanding.PageTitle {
    
    init(
        data: LandingMapping.Landing.PageTitle
    ) {
        self.init(
            text: data.text,
            subTitle: data.subtitle,
            transparency: data.transparency)
    }
}

private extension LandingUIComponent.UILanding.Multi.TextsWithIconsHorizontal {
    
    init(
        data: LandingMapping.Landing.MuiltiTextsWithIconsHorizontal
    ) {
        self.init(lists: data.list.map {
            .init(md5hash: $0.md5hash, title: $0.title)
        })
    }
}

private extension LandingUIComponent.UILanding.TextsWithIconHorizontal {
    
    init(
        data: LandingMapping.Landing.TextsWithIconHorizontal
    ) {
        self.init(md5hash: data.md5hash, title: data.title, contentCenterAndPull: data.contentCenterAndPull)
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

extension LandingUIComponent.UILanding.List.HorizontalRoundImage.Config {
    
    static let defaultValue: Self = .init(
        backgroundColor: .grayLightest,
        title: .defaultValue,
        subtitle: .defaultValue,
        detail: .defaultValue,
        item: .init(cornerRadius: 28, width: 56, spacing: 8, size: .init(width: 80, height: 80)),
        cornerRadius: 12,
        spacing: 16,
        height: 184
    )
}

extension LandingUIComponent.UILanding.List.HorizontalRoundImage.Config.Title {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        font: .title
    )
}

extension LandingUIComponent.UILanding.List.HorizontalRoundImage.Config.Subtitle {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        background: .white,
        font: .title,
        cornerRadius: 12,
        padding: .init(horizontal: 6, vertical: 6)
    )
}

extension LandingUIComponent.UILanding.List.HorizontalRoundImage.Config.Detail {
    
    static let defaultValue: Self = .init(
        color: .textSecondary,
        font: .body
    )
}

extension LandingUIComponent.UILanding.Multi.LineHeader.Config {
    
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
extension LandingUIComponent.UILanding.Multi.LineHeader.Config.Item {
    
    static let defaultValueBlack: Self = .init(
        color: .black,
        fontRegular: .title,
        fontBold: .bold(.title)())
    static let defaultValueWhite: Self = .init(
        color: .white,
        fontRegular: .title,
        fontBold: .bold(.title)())
}

extension LandingUIComponent.UILanding.Multi.TextsWithIconsHorizontal.Config {
    
    static let defaultValueBlack: Self = .init(
        color: .black,
        font: .body)
}

extension LandingUIComponent.UILanding.PageTitle.Config {
    
    static let defaultValue: Self = .init(
        title: .init(color: .black, font: .title),
        subtitle: .init(color: .gray, font: .body))
}

extension LandingUIComponent.UILanding.Multi.Texts.Config {
    
    static let defaultValue: Self = .init(textColor: .gray, padding: .init(horizontal: 10, vertical: 20))
}


private extension String {
    
    static let multiLineHeader: Self = """
{
    "statusCode":0,
    "errorMessage":null,
   "data":{
      "header":[
         {
            "type":"PAGE_TITLE",
            "data":{
               "title":"Переводы за рубеж",
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
         },
        {
                "type": "MULTI_TEXT",
                "data": {
                  "list": [
                    "*Акция «Кешбэк до 1000 руб. за первый перевод» – стимулирующее мероприятие, не является лотереей. Период проведения акции «Кешбэк до 1000 руб. за первый перевод» с 01 ноября 2022 по 31 января 2023 года. Информацию об организаторе акции, о правилах, порядке, сроках и месте ее проведения можно узнать на официальном сайте www.innovation.ru и в офисах АКБ «ИННОВАЦИИ БИЗНЕСА» (АО).",
                    "** Участник Акции имеет право заключить с банком договор банковского счета с использованием карты МИР по тарифному плану «МИГ» или «Все включено-Промо» с бесплатным обслуживанием.",
                    "*** Банк выплачивает Участнику Акции кешбэк в размере 100% от суммы комиссии за первый перевод, но не более 1000 рублей."
                  ]
                }
              }
      ],
      "footer":[
        {
        "type": "MULTI_LINE_HEADER",
            "data": {
                "backgroundColor": "BLACK",
                "regularTextList": [
                    "Пакет"
                ],
                "boldTextList": [
                    "Премиальный"
                ]
            }
        }
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
        url: URL(string: "https://www.innovation.ru/")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil)!
}
