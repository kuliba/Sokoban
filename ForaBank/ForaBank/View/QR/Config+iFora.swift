//
//  Config+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.12.2023.
//

import PaymentComponents
import SberQR

extension SberQR.Config {
    
    static let iFora: Self = .init(
        amount: .iFora,
        background: .init(
            color: .mainColorsGrayLightest
        ),
        button: .iForaFooter,
        carousel: .iForaSmall,
        info: .iFora,
        productSelect: .iFora
    )
}

extension AmountComponent.AmountConfig {
    
    static let iFora: Self = .init(
        amount: .init(
            textFont: .textH1Sb24322(),
            textColor: .white
        ),
        backgroundColor: .mainColorsBlackMedium,
        button: .iForaFooter,
        dividerColor: .bordersDivider,
        title: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        )
    )
}

extension InfoComponent.InfoConfig {
    
    static let iFora: Self = .init(
        title: .placeholder,
        value: .secondary
    )
}

extension ProductSelectComponent.ProductSelectConfig {
    
    static let iFora: Self = .init(
        amount: .secondary,
        card: .init(
            amount: .init(
                textFont: .textBodyXsSb11140(),
                textColor: .textWhite
            ),
            number: .init(
                textFont: .textBodyXsR11140(),
                textColor: .textWhite
            ),
            title: .init(
                textFont: .textBodyXsR11140(),
                textColor: .textWhite.opacity(0.4)
            ), 
            selectedImage: .ic16CheckLightGray16Fixed
        ),
        chevron: .init(
            color: .iconGray,
            image: .ic24ChevronDown
        ),
        footer: .placeholder,
        header: .placeholder,
        missingSelected: .init(
            backgroundColor: .bordersDivider,
            foregroundColor: .iconBlackMedium,
            image: .init("foralogo"),
            title: .init(
                textFont: .textH4M16240(),
                textColor: .textPlaceholder
            )
        ),
        title: .secondary,
        carouselConfig: .iForaSmall
    )
}

import CalendarUI

public extension CalendarConfig {
    
    static let iFora: Self = .init(
        title: "Выберите даты или период",
        titleConfig:.init(textFont: .textH3M18240(), textColor: .textSecondary),
        option: .init(textFont: .textBodyMR14200(), textColor: .mainColorsBlack),
        month: .init(textFont: .textH3M18240(), textColor: .mainColorsGray),
        optionSelectBackground: .mainColorsBlackMedium,
        weekdaysView: {
            WeekdaysView()
        },
        monthLabel: { date in
            MonthLabel(month: date)
        },
        dayConfig: .init(
            selectedColor: .mainColorsBlackMedium,
            todayBackground: .mainColorsGrayLightest,
            todayForeground: .mainColorsRed
        ),
        closeImage: .ic24Close,
        scrollDate: Date().scrollToday
    )
}

public extension FilterConfig {

    static let iFora: Self = .init(
        title: .init(
            title: "Фильтры",
            titleConfig: .init(
                textFont: .textH3M18240(),
                textColor: .textSecondary
            )
        ),
        periodTitle: .init(
            title: "Период",
            titleConfig: .init(
                textFont: .textBodyMSb14200(),
                textColor: .mainColorsGray
            )
        ),
        transactionTitle: .init(
            title: "Движение средств",
            titleConfig: .init(
                textFont: .textBodyMSb14200(),
                textColor: .mainColorsGray
            )
        ),
        categoryTitle: .init(
            title: "Категории",
            titleConfig: .init(
                textFont: .textBodyMSb14200(),
                textColor: .mainColorsGray
            )
        ),
        optionConfig: .init(
            font: .textBodyMR14200(),
            selectBackgroundColor: .mainColorsBlackMedium,
            notSelectedBackgroundColor: .mainColorsGrayLightest,
            selectForegroundColor: .textWhite,
            notSelectForegroundColor: .textSecondary
        ),
        buttonsContainerConfig: .init(
            clearButtonTitle: "Очистить",
            applyButtonTitle: "Применить"
        ),
        optionButtonCloseImage: .ic24Close,
        failureConfig: .init(
            title: "Мы не смогли загрузить ваши продукты.\nПопробуйте позже.",
            titleConfig: .init(textFont: .textH4R16240(), textColor: .textPlaceholder),
            icon: .ic32Search,
            iconForeground: .mainColorsGray,
            backgroundIcon: .mainColorsGrayLightest
        ),
        emptyConfig: .init(
            title: "В этот период операции отсутствовали",
            titleConfig: .init(textFont: .textH4R16240(), textColor: .textPlaceholder),
            icon: .ic32Search,
            iconForeground: .mainColorsGray,
            backgroundIcon: .mainColorsGrayLightest
        )
    )
}

import SwiftUI

// MARK: - Previews

struct SberQRConfirmPaymentWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            sberQRConfirmPaymentWrapperView(.init(confirm: .fixedAmount(.preview)))
                .previewDisplayName("SberQRConfirmPayment: Fixed")
            
            sberQRConfirmPaymentWrapperView(.init(confirm: .editableAmount(.preview)))
                .previewDisplayName("SberQRConfirmPayment: Editable")
        }
    }
    
    private static func sberQRConfirmPaymentWrapperView(
        _ state: SberQRConfirmPaymentState
    ) -> some View {
        
        SberQRConfirmPaymentWrapperView(
            viewModel: .default(
                initialState: state,
                getProducts: { .allProducts },
                pay: { _ in }
            ),
            map: PublishingInfo.preview,
            config: .iFora
        )
    }
}

extension Date {
    
    var scrollToday: Date {
        var today = Date()
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(secondsFromGMT: 0)!
        var components = gregorian.dateComponents([.timeZone, .year, .month, .day, .hour, .minute,.second], from: today)

        components.hour = 0
        components.minute = 0
        components.second = 0

        today = gregorian.date(from: components)!
        
        return today
    }
}
