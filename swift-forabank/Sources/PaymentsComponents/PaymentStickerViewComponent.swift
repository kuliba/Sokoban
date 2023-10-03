//
//  File.swift
//  
//
//  Created by Дмитрий Савушкин on 29.09.2023.
//

import Foundation
import SwiftUI

// MARK: - ViewModel

extension PaymentStickerView {
    
    class ViewModel: ObservableObject {
        
        @Published var isAccountOpen: Bool
        @Published var isHidden: Bool = false
        
        let currency: String
        let conditionLinkURL: String
        let ratesLinkURL: String?
        let currencyCode: Int
        
        let header: HeaderViewModel
        let options: [OptionViewModel]
        
        init(
            currency: String,
            conditionLinkURL: String,
            ratesLinkURL: String?,
            currencyCode: Int,
            header: HeaderViewModel,
            options: [OptionViewModel],
            isAccountOpen: Bool
        ) {
            
            self.currency = currency
            self.conditionLinkURL = conditionLinkURL
            self.ratesLinkURL = ratesLinkURL
            self.currencyCode = currencyCode
            self.header = header
            self.options = options
            self.isAccountOpen = isAccountOpen
        }
    }
}

extension PaymentStickerView.ViewModel {
    
    // MARK: - Header
    
    class HeaderViewModel: ObservableObject {
        
        @Published var title: String
        
        /// Для показа изображения после открытия счета
        @Published var isAccountOpened: Bool
        
        let detailTitle: String
        
        init(title: String, detailTitle: String, isAccountOpened: Bool = false) {
            
            self.title = title
            self.detailTitle = detailTitle
            self.isAccountOpened = isAccountOpened
        }
    }
    
    // MARK: - Option
    
    struct OptionViewModel: Identifiable {

        var id: String { title }
        let title: String
        let icon: Image
        let description: String
        let iconColor: Color
        
        init(
            title: String,
            icon: Image = .init("Arrow Circle"),
            description: String = "Бесплатно",
            iconColor: Color = .green
        ) {
            
            self.title = title
            self.icon = icon
            self.description = description
            self.iconColor = iconColor
        }
    }
}
    
public struct PaymentStickerViewConfig {
    
    public let rectangleColor: Color
    public let configHeader: Header
    public let configOption: Option
    
    public struct Header {
        
        public let titleFont: Font
        public let titleColor: Color
        public let descriptionFont: Font
        public let descriptionColor: Color
        
        public init(
            titleFont: Font,
            titleColor: Color,
            descriptionFont: Font,
            descriptionColor: Color
        ) {
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.descriptionFont = descriptionFont
            self.descriptionColor = descriptionColor
        }
    }
    
    public struct Option {
        
        public let titleFont: Font
        public let titleColor: Color
        
        public let iconColor: Color
        
        public let descriptionFont: Font
        public let descriptionColor: Color
        
        public init(
            titleFont: Font,
            titleColor: Color,
            iconColor: Color,
            descriptionFont: Font,
            descriptionColor: Color
        ) {
            self.titleFont = titleFont
            self.titleColor = titleColor
            self.iconColor = iconColor
            self.descriptionFont = descriptionFont
            self.descriptionColor = descriptionColor
        }
    }
    
    public init(
        rectangleColor: Color,
        configHeader: PaymentStickerViewConfig.Header,
        configOption: PaymentStickerViewConfig.Option
    ) {
        self.rectangleColor = rectangleColor
        self.configHeader = configHeader
        self.configOption = configOption
    }
}

// MARK: - View

public struct PaymentStickerView<OpenAccountCardView: View>: View {
    
    @ObservedObject var viewModel: ViewModel
    let openAccountCardView: () -> OpenAccountCardView
    let config: PaymentStickerViewConfig
    
    public var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(config.rectangleColor)
            
            VStack(alignment: .leading) {
                
                HeaderView(
                    viewModel: viewModel.header,
                    config: config.configHeader
                )
                
                HStack(alignment: .top, spacing: 20) {
                    
                    openAccountCardView()
                    
                    VStack {
                        
                        ForEach(viewModel.options) { option in
                            OptionView(
                                viewModel: option,
                                config: config.configOption
                            )
                        }
                    }
                }.padding(20)
                
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: 200)
//        .hidden(viewModel.isHidden)
    }
}

extension PaymentStickerView {
    
    // MARK: - Header
    
    struct HeaderView: View {
        
        @ObservedObject var viewModel: ViewModel.HeaderViewModel
        let config: PaymentStickerViewConfig.Header
        
        var body: some View {
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(viewModel.title)
                        .font(config.titleFont)
                        .foregroundColor(config.titleColor)
                    
                    Text(viewModel.detailTitle)
                        .font(config.descriptionFont)
                        .foregroundColor(config.descriptionColor)
                }
                
                Spacer()
                
                if viewModel.isAccountOpened {
                    
                    Image("Check Enabled")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }.padding([.leading, .trailing, .top], 20)
        }
    }
    
    // MARK: - Option
    
    struct OptionView: View {
        
        let viewModel: ViewModel.OptionViewModel
        let config: PaymentStickerViewConfig.Option
        
        var body: some View {
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text(viewModel.title)
                    .font(config.titleFont)
                    .foregroundColor(config.titleColor)
                
                HStack {
                    
                    viewModel.icon
                        .renderingMode(.template)
                        .foregroundColor(config.iconColor)
                    
                    Text(viewModel.description)
                        .font(config.descriptionFont)
                        .foregroundColor(config.descriptionColor)
                }
            }
        }
    }
}

//MARK: - Preview Content

extension PaymentStickerView.ViewModel {
    
    static func emptyStub() -> PaymentStickerView.ViewModel {
        
        .init(
            currency: "RUB",
            conditionLinkURL: "",
            ratesLinkURL: nil,
            currencyCode: 810,
            header: .init(title: "", detailTitle: ""),
            options: .init(),
            isAccountOpen: false
        )
    }
    
    static func sampleStub() -> PaymentStickerView.ViewModel {
        
        .init(
            currency: "USD",
            conditionLinkURL: "https://www.forabank.ru/dkbo/dkbo.pdf",
            ratesLinkURL: "https://www.forabank.ru/user-upload/tarif-fl-ul/Moscow_tarifi.pdf",
            currencyCode: 840,
            header: .init(
                title: "USD счет",
                detailTitle: "Счет в долларах США"),
            options: [
                .init(title: "Открытие"),
                .init(title: "Обслуживание")
            ],
            isAccountOpen: false
        )
    }
    
    static func configStub() -> PaymentStickerViewConfig {
        
        .init(
            rectangleColor: .gray,
            configHeader: .init(
                titleFont: .title,
                titleColor: .black,
                descriptionFont: .body,
                descriptionColor: .gray
            ),
            configOption: .init(
                titleFont: .body,
                titleColor: .black,
                iconColor: .green,
                descriptionFont: .body,
                descriptionColor: .gray
            ))
    }
}

// MARK: - Previews

struct PaymentStickerViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        PaymentStickerView(
            viewModel: .sampleStub(),
            openAccountCardView: {
                
                Color.black
                    .frame(width: 120, height: 80, alignment: .center)
            },
            config: .init(
                rectangleColor: .accentColor,
                configHeader: .init(
                    titleFont: .title,
                    titleColor: .black,
                    descriptionFont: .body,
                    descriptionColor: .gray
                ),
                configOption: .init(
                    titleFont: .body,
                    titleColor: .black,
                    iconColor: .green,
                    descriptionFont: .body,
                    descriptionColor: .gray
                ))
        )
        .previewLayout(.sizeThatFits)
    }
}
