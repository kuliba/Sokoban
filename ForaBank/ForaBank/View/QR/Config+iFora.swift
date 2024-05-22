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
            )
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
        title: .secondary
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
