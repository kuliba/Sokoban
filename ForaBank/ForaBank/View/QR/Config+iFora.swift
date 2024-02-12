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
        button: .iFora,
        info: .iFora,
        productSelect: .iFora
    )
}

private extension ButtonComponent.ButtonConfig {
    
    static let iFora: Self = .init(
        active: .init(
            backgroundColor: .init(hex: "#FF3636"),
            text: .init(
                textFont: .textH4R16240(),
                textColor: .textWhite
            )
        ),
        inactive: .init(
            backgroundColor: .mainColorsGrayMedium.opacity(0.1),
            text: .init(
                textFont: .textH4R16240(),
                textColor: .mainColorsWhite.opacity(0.5)
            )
        )
    )
}

private extension AmountComponent.AmountConfig {
    
    static let iFora: Self = .init(
        amount: .init(
            textFont: .textH1Sb24322(),
            textColor: .white
        ),
        backgroundColor: .mainColorsBlackMedium,
        button: .iFora,
        dividerColor: .bordersDivider,
        title: .init(
            textFont: .textBodySR12160(),
            textColor: .textPlaceholder
        )
    )
}

private extension InfoComponent.InfoConfig {
    
    static let iFora: Self = .init(
        title: .placeholder,
        value: .secondary
    )
}

private extension ProductSelectComponent.ProductSelectConfig {
    
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
            )
        ),
        chevronColor: .iconGray,
        footer: .placeholder,
        header: .placeholder,
        title: .secondary
    )
}

private extension SberQR.TextConfig {
    
    static let secondary: Self = .init(
        textFont: .textH4M16240(),
        textColor: .textSecondary
    )
    
    static let placeholder: Self = .init(
        textFont: .textBodyMR14180(),
        textColor: .textPlaceholder
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
            map: Info.preview,
            config: .iFora
        )
    }
}
