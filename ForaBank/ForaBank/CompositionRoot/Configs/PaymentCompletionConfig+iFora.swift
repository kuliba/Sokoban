//
//  PaymentCompletionConfig+iFora.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.07.2024.
//

import Combine
import PaymentCompletionUI
import SwiftUI

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

#if DEBUG
struct PaymentCompletionStatusView_PaymentCompletion_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            statusView(.completed)
                .previewDisplayName("completed")
            statusView(.inflight)
                .previewDisplayName("inflight")
            statusView(.rejected)
                .previewDisplayName("rejected")
            statusView(.fraudCancelled)
                .previewDisplayName("fraud: cancelled")
            statusView(.fraudExpired)
                .previewDisplayName("fraud: expired")
        }
    }
    
    private static func statusView(
        _ completion: PaymentCompletion
    ) -> some View {
        
        PaymentCompletionStatusView(
            state: completion, 
            makeIconView: {
                
                return .init(
                    image: .init(systemName: $0!),
                    publisher: Just(.init(systemName: $0!)).eraseToAnyPublisher()
                )
            },
            config: .iFora
        )
    }
}

private extension PaymentCompletion {
    
    static let completed: Self = .init(
        formattedAmount: "1 000 ₽",
        merchantIcon: "externaldrive.connected.to.line.below",
        status: .completed
    )
    static let inflight: Self = .init(
        formattedAmount: "1 000 ₽",
        merchantIcon: "externaldrive.connected.to.line.below",
        status: .inflight
    )
    static let rejected: Self = .init(
        formattedAmount: "1 000 ₽",
        merchantIcon: "externaldrive.connected.to.line.below",
        status: .rejected
    )
    static let fraudCancelled: Self = .init(
        formattedAmount: "1 000 ₽",
        merchantIcon: "externaldrive.connected.to.line.below",
        status: .fraud(.cancelled)
    )
    static let fraudExpired: Self = .init(
        formattedAmount: "1 000 ₽",
        merchantIcon: "externaldrive.connected.to.line.below",
        status: .fraud(.expired)
    )
}
#endif
