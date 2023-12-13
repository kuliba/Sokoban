//
//  Config+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 12.12.2023.
//

import SberQR

extension SberQR.Config {
    
    static let iFora: Self = .init(
        amount: .iFora,
        background: .init(
            color: .mainColorsGrayLightest
        ),
        info: .init(
            title: .init(
                textFont: .textBodyMR14180(),
                textColor: .textPlaceholder
            ),
            value: .init(
                textFont: .textH4M16240(),
                textColor: .textSecondary
            )
        ),
        productSelect: .iFora
    )
}

private extension SberQR.AmountConfig {
    
    static let iFora: Self = .init(
        amount: .init(
            textFont: .textH1Sb24322(),
            textColor: .white
        ),
        backgroundColor: .mainColorsBlackMedium,
        button: .init(
//                active: .init(
                textFont: .textH4R16240(),
                textColor: .textWhite
//                ),
//                inactive: .init(
//                    textFont: .textH4R16240(),
//                    textColor: .mainColorsWhite.opacity(0.5)
//                )
        ),
        buttonColor: .init(hex: "#FF3636"),
        dividerColor: .bordersDivider,
        title: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        )
    )
}

private extension SberQR.ProductSelectConfig {
    
    static let iFora: Self = .init(
        amount: .init(
            textFont: .textH4M16240(),
            textColor: .textSecondary
        ),
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
            )
        ),
        chevronColor: .iconGray,
        footer: .init(
            textFont: .textBodyMR14180(),
            textColor: .textPlaceholder
        ),
        header: .init(
            textFont: .textBodyMR14180(),
            textColor: .textPlaceholder
        ),
        title: .init(
            textFont: .textH4M16240(),
            textColor: .textSecondary
        )
    )
}

import SwiftUI

// MARK: - Previews

struct SberQRConfirmPaymentWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            sberQRConfirmPaymentWrapperView(.fixedAmount(.preview))
                .previewDisplayName("SberQRConfirmPayment: Fixed")
            
            sberQRConfirmPaymentWrapperView(.editableAmount(.preview))
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
            map: Info.preview,
            config: .iFora
        )
    }
}
