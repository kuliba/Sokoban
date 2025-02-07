//
//  PaymentCompleteView.Config+CollateralLoanLanding.swift
//  Vortex
//
//  Created by Valentin Ozerov on 05.02.2025.
//

extension PaymentCompleteView.Config {
    
    static let collateralLoanLanding: Self = .init(
        statuses: .init(
            completed: .init(
                content: .init(
                    logo: .ic48Check,
                    title: "Заявка на кредит успешно\nоформлена",
                    subtitle: "Специалист банка свяжется с Вами в\nближайшее время"
                ),
                config: .init(
                    amount: .init(
                        textFont: .textH1Sb24322(),
                        textColor: .backgroundBackground
                    ),
                    icon: .init(
                        foregroundColor: .iconWhite,
                        backgroundColor: .systemColorActive,
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
            ),
            inflight: .init(
                content: .init(
                    logo: .ic48Clock,
                    title: "Операция в обработке!",
                    subtitle: nil
                ),
                config: .init(
                    amount: .init(
                        textFont: .textH1Sb24322(),
                        textColor: .textSecondary
                    ),
                    icon: .init(
                        foregroundColor: .iconWhite,
                        backgroundColor: .systemColorWarning,
                        innerSize: .init(width: 44, height: 44),
                        outerSize: .init(width: 88, height: 88)
                    ),
                    logoHeight: 44,
                    title: .init(
                        textFont: .textH3Sb18240(),
                        textColor: .textSecondary
                    ),
                    subtitle: .init(
                        textFont: .textH3Sb18240(),
                        textColor: .textSecondary
                    )
                )
            ),
            rejected: .init(
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
            ),
            fraudCancelled: .init(
                content: .init(
                    logo: .ic48Clock,
                    title: "Перевод отменен!",
                    subtitle: nil
                ),
                config: .init(
                    amount: .init(
                        textFont: .textH1Sb24322(),
                        textColor: .textSecondary
                    ),
                    icon: .init(
                        foregroundColor: .iconWhite,
                        backgroundColor: .systemColorWarning,
                        innerSize: .init(width: 44, height: 44),
                        outerSize: .init(width: 88, height: 88)
                    ),
                    logoHeight: 44,
                    title: .init(
                        textFont: .textH3Sb18240(),
                        textColor: .textRed
                    ),
                    subtitle: .init(
                        textFont: .textH3Sb18240(),
                        textColor: .textSecondary
                    )
                )
            ),
            fraudExpired: .init(
                content: .init(
                    logo: .ic48Clock,
                    title: "Перевод отменен!",
                    subtitle: "Время на подтверждение\nперевода вышло"
                ),
                config: .init(
                    amount: .init(
                        textFont: .textH1Sb24322(),
                        textColor: .textSecondary
                    ),
                    icon: .init(
                        foregroundColor: .iconWhite,
                        backgroundColor: .systemColorWarning,
                        innerSize: .init(width: 44, height: 44),
                        outerSize: .init(width: 88, height: 88)
                    ),
                    logoHeight: 44,
                    title: .init(
                        textFont: .textH3Sb18240(),
                        textColor: .textRed
                    ),
                    subtitle: .init(
                        textFont: .textH3Sb18240(),
                        textColor: .textSecondary
                    )
                )
            )
        )
    )
}
