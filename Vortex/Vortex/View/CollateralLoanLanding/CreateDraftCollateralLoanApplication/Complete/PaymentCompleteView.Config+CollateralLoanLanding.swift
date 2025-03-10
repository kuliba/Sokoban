//
//  PaymentCompleteView.Config+CollateralLoanLanding.swift
//  Vortex
//
//  Created by Valentin Ozerov on 05.02.2025.
//

extension PaymentCompleteView.Config {
    
    static let collateralLoanLanding = Self(
        statuses: .init(
            completed: .default,
            inflight: .default,
            rejected: .default,
            fraudCancelled: .default,
            fraudExpired: .default,
            suspend: .default
        )
    )
}

extension PaymentCompleteView.Config.Statuses.Status {
    
    static let `default` = Self(
        content: .init(
            logo: .ic48Close,
            title: "Заявка на кредит неуспешна!",
            subtitle: "Что-то пошло не так...\nПопробуйте позже."
        ),
        config: .init(
            amount: .init(
                textFont: .textH1Sb24322(),
                textColor: .backgroundBackground
            ),
            icon: .init(
                foregroundColor: .iconWhite,
                backgroundColor: .mainColorsRed,
                innerSize: .init(width: 44, height: 44),
                outerSize: .init(width: 88, height: 88)
            ),
            logoHeight: 0,
            title: .init(
                textFont: .textH3Sb18240(),
                textColor: .textSecondary
            ),
            subtitle: .init(
                textFont: .textBodyMR14200(),
                textColor: .textPlaceholder
            )
        )
    )
}
