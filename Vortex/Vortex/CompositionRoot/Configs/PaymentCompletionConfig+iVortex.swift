//
//  PaymentCompletionConfig+iVortex.swift
//  Vortex
//
//  Created by Igor Malyarov on 30.07.2024.
//

import Combine
import PaymentCompletionUI
import SwiftUI

extension PaymentCompletionConfig {
    
    static let iVortex: Self = .init(
        statuses: .init(
            completed: .completed(),
            inflight: .inflight(),
            rejected: .rejected(),
            fraudCancelled: .fraudCancelled(),
            fraudExpired: .fraudExpired()
        )
    )
}

extension PaymentCompletionConfig.Statuses.Status {
    
    static func completed(
        title: String = "Успешный перевод",
        subtitle: String? = nil
    ) -> Self {
        
        return .init(
            content: .init(
                logo: .ic48Check,
                title: title,
                subtitle: subtitle
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
        )
    }
    
    static func inflight(
        title: String = "Операция в обработке!",
        subtitle: String? = nil
    ) -> Self {
        
        return .init(
            content: .init(
                logo: .ic48Clock,
                title: title,
                subtitle: subtitle
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
    }
    
    static func rejected(
        title: String = "Операция неуспешна!",
        subtitle: String? = nil
    ) -> Self {
        
        return .init(
            content: .init(
                logo: .ic48Close,
                title: title,
                subtitle: subtitle
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
        )
    }
    
    static func fraudCancelled(
        title: String = "Перевод отменен!",
        subtitle: String? = nil
    ) -> Self {
        
        return .init(
            content: .init(
                logo: .ic48Clock,
                title: title,
                subtitle: subtitle
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
    }
    
    static func fraudExpired(
        title: String = "Перевод отменен!",
        subtitle: String? = "Время на подтверждение\nперевода вышло"
    ) -> Self {
        
        return .init(
            content: .init(
                logo: .ic48Clock,
                title: title,
                subtitle: subtitle
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
    }
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
                    image: .init(systemName: $0),
                    publisher: Just(.init(systemName: $0)).eraseToAnyPublisher()
                )
            },
            config: .iVortex
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
