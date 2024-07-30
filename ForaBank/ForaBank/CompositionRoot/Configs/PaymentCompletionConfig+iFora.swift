//
//  PaymentCompletionConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.07.2024.
//

import PaymentCompletionUI

extension PaymentCompletionConfig {
    
    static let iFora: Self = .init(
        statuses: .init(
            completed: .init(
                content: .init(
                    logo: .ic48Check,
                    title: "Успешный перевод",
                    subtitle: nil
                ),
                config: .init(
                    amount: .init(
                        textFont: .textH1Sb24322(),
                        textColor: .textSecondary
                    ),
                    icon: .init(
                        foregroundColor: .iconWhite,
                        backgroundColor: .systemColorActive,
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
                    title: "Операция неуспешна!",
                    subtitle: nil
                ),
                config: .init(
                    amount: .init(
                        textFont: .textH1Sb24322(),
                        textColor: .textSecondary
                    ),
                    icon: .init(
                        foregroundColor: .iconWhite,
                        backgroundColor: .mainColorsRed,
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
                        textColor: .textSecondary
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
                        textColor: .textSecondary
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
