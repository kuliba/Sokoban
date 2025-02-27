//
//  ViewComponents+collateralLoanLanding.swift
//  Vortex
//
//  Created by Valentin Ozerov on 26.02.2025.
//

import DropDownTextListComponent
import Foundation
import CollateralLoanLandingGetShowcaseUI
import CollateralLoanLandingGetCollateralLandingUI
import SwiftUI

extension ViewComponents {
    
    func makeCollateralLoanWrapperView(
        binder: GetCollateralLandingDomain.Binder,
        getPDFDocument: @escaping GetPDFDocument,
        goToMain: @escaping () -> Void,
        makeOperationDetailInfoViewModel: @escaping MakeDetailsViewModel,
        makeCollateralLoanLandingFactory: @escaping MakeCollateralLoanLandingFactory
    ) -> CollateralLoanLandingWrapperView {
        
        .init(
            binder: binder,
            config: .default,
            factory: makeCollateralLoanLandingFactory(getPDFDocument),
            goToMain: goToMain,
            makeOperationDetailInfoViewModel: makeOperationDetailInfoViewModel
        )
    }
    
    func makeCollateralLoanShowcaseWrapperView(
        binder: GetShowcaseDomain.Binder,
        goToMain: @escaping () -> Void,
        getPDFDocument: @escaping GetPDFDocument,
        makeOperationDetailInfoViewModel: @escaping MakeDetailsViewModel,
        makeCollateralLoanLandingFactory: @escaping MakeCollateralLoanLandingFactory
    ) -> CollateralLoanShowcaseWrapperView {
        
        .init(
            binder: binder,
            factory: makeCollateralLoanLandingFactory(getPDFDocument),
            config: .default,
            goToMain: goToMain,
            makeOperationDetailInfoViewModel: makeOperationDetailInfoViewModel
        )
    }
    
    typealias GetPDFDocument = GetCollateralLandingFactory.GetPDFDocument
    typealias MakeDetailsViewModel = CreateDraftCollateralLoanApplicationWrapperView.MakeOperationDetailInfoViewModel
    typealias MakeCollateralLoanLandingFactory = (@escaping GetPDFDocument) -> CollateralLoanLandingFactory
}

extension GetCollateralLandingConfig {

    static let `default` = Self(
        fonts: .init(body: FontConfig(Font.system(size: 14))),
        backgroundImageHeight: 703,
        paddings: .init(
            outerLeading: 16,
            outerTrailing: 15,
            outerBottom: 20,
            outerTop: 16
        ),
        spacing: 16,
        cornerRadius: 12,
        header: .default,
        conditions: .default,
        calculator: .default,
        faq: .default,
        documents: .default,
        footer: .default,
        bottomSheet: .default
    )
}

extension GetCollateralLandingConfig.Header {
    
    static let `default` = Self(
        height: 642,
        labelTag: .init(
            layouts: .init(
                cornerSize: 10,
                topOuterPadding: 215,
                leadingOuterPadding: 25,
                horizontalInnerPadding: 10,
                verticalInnerPadding: 6,
                rotationDegrees: -5
            ),
            fonts: .init(fontConfig: .init(
                Font.system(size: 32).bold(),
                foreground: .white,
                background: .red
            ))
        ),
        params: .init(
            fontConfig: .init(Font.system(size: 14)),
            spacing: 20,
            leadingPadding: 20,
            topPadding: 30
        )
    )
}

extension GetCollateralLandingConfig.Conditions {
    
    static let `default` = Self(
        header: .init(
            text: "Выгодные условия",
            headerFont: .init(Font.system(size: 18).bold())
        ),
        list: .init(
            layouts: .init(
                spacing: 13,
                horizontalPadding: 16,
                listTopPadding: 12,
                iconSize: CGSize(width: 40, height: 40),
                iconTrailingPadding: 16,
                subTitleTopPadding: 2
            ),
            fonts: .init(
                title: .init(Font.system(size: 14), foreground: .textPlaceholder),
                subTitle: .init(Font.system(size: 16))),
            colors: .init(
                background: .grayLightest,
                iconBackground: .iconBackground
            )
        )
    )
}

extension GetCollateralLandingConfig.Calculator {
    
    static let `default` = Self(
        root: .init(
            layouts: .init(
                height: 468,
                contentLeadingPadding: 16,
                contentTrailingPadding: 22,
                middleSectionSpacing: 11,
                spacingBetweenTitleAndValue: 8,
                chevronSpacing: 4,
                bottomPanelCornerRadius: 12,
                chevronOffsetY: 2
            ),
            fonts: .init(
                title: .init(Font.system(size: 12), foreground: .textPlaceholder),
                value: .init(Font.system(size: 16), foreground: .white)
            ),
            colors: .init(
                background: .black,
                divider: .divider,
                chevron: .divider,
                bottomPanelBackground: .bottomPanelBackground
            )
        ),
        header: .init(
            text: "Рассчитать кредит",
            font: .init(Font.system(size: 20).bold(), foreground: .white),
            topPadding: 16,
            bottomPadding: 12
        ),
        salary: .init(
            text: "Я получаю зарплату на счет в Инновациях-Бизнеса",
            font: .init(Font.system(size: 14), foreground: .white),
            leadingPadding: 16,
            trailingPadding: 17,
            bottomPadding: 18,
            toggleTrailingPadding: 22,
            toggle: .init(
                colors: .init(
                    on: .green,
                    off: .textPlaceholder
                )
            ),
            slider: .init(
                minTrackColor: .red,
                maxTrackColor: .textPlaceholder,
                thumbDiameter: 20,
                trackHeight: 2
            )
        ),
        period: .init(titleText: "Срок кредита"),
        percent: .init(titleText: "Процентная ставка"),
        desiredAmount: .init(
            titleText: "Желаемая сумма кредита",
            maxText: "До 15 млн. ₽",
            titleTopPadding: 20,
            sliderBottomPadding: 12,
            fontValue: .init(Font.system(size: 24).bold(), foreground: .white)
        ),
        monthlyPayment: .init(
            titleText: "Ежемесячный платеж",
            titleTopPadding: 16,
            valueTopPadding: 8
        ),
        info: .init(
            titleText: "Представленные параметры являются расчетными и носят справочный характер",
            titleTopPadding: 15,
            titleBottomPadding: 15
        ),
        deposit: .init(
            titleText: "Залог",
            titleTopPadding: 24
        )
    )
}

extension DropDownTextListConfig {
    
    static let `default` = Self(
        cornerRadius: 12,
        chevronDownImage: Image(systemName: "chevron.down"),
        layouts: .init(
            horizontalPadding: 16,
            verticalPadding: 12
        ),
        colors: .init(
            divider: .faqDivider,
            background: .grayLightest
        ),
        fonts: .init(
            title: .init(textFont: Font.system(size: 18).bold(), textColor: .primary),
            itemTitle: .init(textFont: Font.system(size: 14), textColor: .primary),
            itemSubtitle: .init(textFont: Font.system(size: 14), textColor: .textPlaceholder)
        )
    )
}

extension GetCollateralLandingConfig.Documents {
    
    static let `default` = Self(
        background: .grayLightest,
        topPadding: 16,
        header: .init(
            text: "Документы",
            headerFont: .init(Font.system(size: 18).bold())
        ),
        list: .init(
            defaultIcon: Image("file-text"),
            layouts: .init(
                horizontalPadding: 16,
                topPadding: 8,
                bottomPadding: 6,
                spacing: 13,
                iconTrailingPadding: 16,
                iconSize: .init(width: 20, height: 20)
            ),
            fonts: .init(
                title: .init(Font.system(size: 14))
            )
        )
    )
}

extension GetCollateralLandingConfig.Footer {
    
    static let `default` = Self(
        text: "Оформить заявку",
        font: .init(Font.system(size: 16).bold()),
        foreground: .white,
        background: .red,
        layouts: .init(
            height: 56,
            cornerRadius: 12,
            paddings: .init(top: 16, leading: 16, bottom: 0, trailing: 15)
        )
    )
}

extension GetCollateralLandingConfig.BottomSheet {
    
    static let `default` = Self(
        font: .init(Font.system(size: 16)),
        layouts: .init(
            spacing: 8,
            scrollThreshold: 6,
            sheetTopOffset: 100,
            sheetBottomOffset: 20,
            cellHeightCompensation: 8
        ),
        radioButton: .init(
            layouts: .init(
                size: .init(width: 24, height: 24),
                cellHeigh: 50,
                lineWidth: 1.25,
                ringDiameter: 20,
                circleDiameter: 10
            ),
            paddings: .init(
                horizontal: 18,
                vertical: 15
            ),
            colors: .init(
                unselected: .unselected,
                selected: .red
            )
        ),
        icon: .init(
            size: .init(width: 40, height: 40),
            horizontalPadding: 20,
            verticalPadding: 8,
            cellHeigh: 56
        ),
        divider: .init(
            leadingPadding: 55,
            trailingPadding: 15
        )
    )
}

private extension Color {
    
    static let grayLightest: Self = .init(red: 0.96, green: 0.96, blue: 0.97)
    static let unselected: Self = .init(red: 0.92, green: 0.92, blue: 0.92)
    static let red: Self = .init(red: 1, green: 0.21, blue: 0.21)
    static let iconBackground: Self = .init(red: 0.5, green: 0.8, blue: 0.76)
    static let textPlaceholder: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let buttonPrimaryDisabled: Self = .init(red: 0.83, green: 0.83, blue: 0.83)
    static let divider: Self = .init(red: 0.6, green: 0.6, blue: 0.6)
    static let bottomPanelBackground: Self = .init(red: 0.16, green: 0.16, blue: 0.16)
    static let faqDivider: Self = .init(red: 0.83, green: 0.83, blue: 0.83)
}
