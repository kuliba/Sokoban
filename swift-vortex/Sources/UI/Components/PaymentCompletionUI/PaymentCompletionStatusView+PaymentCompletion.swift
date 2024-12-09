//
//  PaymentCompletionStatusView+PaymentCompletion.swift
//
//
//  Created by Igor Malyarov on 30.07.2024.
//

import Combine
import SwiftUI
import UIPrimitives

public extension PaymentCompletionStatusView {
    
    init(
        state: PaymentCompletion,
        makeIconView: @escaping MakeIconView,
        config: PaymentCompletionConfig
    ) {
        let config = config.config(for: state.status)
        
        self.init(
            state: .init(
                status: .init(config.content),
                formattedAmount: state.formattedAmount,
                merchantIcon: state.merchantIcon
            ),
            makeIconView: makeIconView,
            config: .init(config.config)
        )
    }
}

private extension PaymentCompletionStatus.Status {
    
    init(
        _ content: PaymentCompletionConfig.Statuses.Status.Content
    ) {
        self.init(
            logo: content.logo,
            title: content.title,
            subtitle: content.subtitle
        )
    }
}

private extension PaymentCompletionStatusView.Config {
    
    init(
        _ config: PaymentCompletionConfig.Statuses.Status.Config
    ) {
        self.init(
            amount: config.amount,
            icon: .init(
                foregroundColor: config.icon.foregroundColor,
                backgroundColor: config.icon.backgroundColor,
                innerSize: config.icon.innerSize,
                outerSize: config.icon.outerSize
            ),
            logoHeight: config.logoHeight,
            title: config.title,
            subtitle: config.subtitle
        )
    }
}

private extension PaymentCompletionConfig {
    
    func config(
        for status: PaymentCompletion.Status
    ) -> PaymentCompletionConfig.Statuses.Status {
        
        switch status {
        case .completed:
            return statuses.completed
            
        case .inflight:
            return statuses.inflight
            
        case .rejected:
            return statuses.rejected
            
        case .fraud(.cancelled):
            return statuses.fraudCancelled
            
        case .fraud(.expired):
            return statuses.fraudExpired
        }
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
                    image: .init(systemName: $0 ?? "pencil.and.outline"),
                    publisher: Just(.init(systemName: $0 ?? "tray.full.fill")).eraseToAnyPublisher()
                )
            },
            config: .preview
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

private extension PaymentCompletionConfig {
    
    static let preview: Self = .init(
        statuses: .init(
            completed: .init(
                content: .init(
                    logo: .init(systemName: "house"),
                    title: "Payment completed",
                    subtitle: nil
                ),
                config: .init(
                    amount: .init(
                        textFont: .headline,
                        textColor: .green
                    ),
                    icon: .init(
                        foregroundColor: .white,
                        backgroundColor: .green,
                        innerSize: .init(width: 44, height: 44),
                        outerSize: .init(width: 88, height: 88)
                    ),
                    logoHeight: 44,
                    title: .init(
                        textFont: .title3.bold(),
                        textColor: .blue
                    ),
                    subtitle: .init(
                        textFont: .subheadline,
                        textColor: .pink
                    )
                )
            ),
            inflight: .init(
                content: .init(
                    logo: .init(systemName: "paperplane"),
                    title: "Payment in progress",
                    subtitle: nil
                ),
                config: .init(
                    amount: .init(
                        textFont: .headline,
                        textColor: .green
                    ),
                    icon: .init(
                        foregroundColor: .pink,
                        backgroundColor: .orange,
                        innerSize: .init(width: 44, height: 44),
                        outerSize: .init(width: 88, height: 88)
                    ),
                    logoHeight: 44,
                    title: .init(
                        textFont: .title3,
                        textColor: .secondary
                    ),
                    subtitle: .init(
                        textFont: .subheadline,
                        textColor: .pink
                    )
                )
            ),
            rejected: .init(
                content: .init(
                    logo: .init(systemName: "xmark.app"),
                    title: "Payment rejected",
                    subtitle: nil
                ),
                config: .init(
                    amount: .init(
                        textFont: .headline.bold(),
                        textColor: .red
                    ),
                    icon: .init(
                        foregroundColor: .white,
                        backgroundColor: .red,
                        innerSize: .init(width: 44, height: 44),
                        outerSize: .init(width: 88, height: 88)
                    ),
                    logoHeight: 44,
                    title: .init(
                        textFont: .title3,
                        textColor: .red
                    ),
                    subtitle: .init(
                        textFont: .subheadline,
                        textColor: .pink
                    )
                )
            ),
            fraudCancelled: .init(
                content: .init(
                    logo: .init(systemName: "car.window.right.xmark"),
                    title: "Payment cancelled (fraud)",
                    subtitle: nil
                ),
                config: .init(
                    amount: .init(
                        textFont: .headline,
                        textColor: .secondary
                    ),
                    icon: .init(
                        foregroundColor: .white,
                        backgroundColor: .orange,
                        innerSize: .init(width: 44, height: 44),
                        outerSize: .init(width: 88, height: 88)
                    ),
                    logoHeight: 44,
                    title: .init(
                        textFont: .title3,
                        textColor: .red
                    ),
                    subtitle: .init(
                        textFont: .subheadline,
                        textColor: .pink
                    )
                )
            ),
            fraudExpired: .init(
                content: .init(
                    logo: .init(systemName: "clock.badge.xmark"),
                    title: "Payment cancelled",
                    subtitle: "Payment cancelled due to confirmation period expiration"
                ),
                config: .init(
                    amount: .init(
                        textFont: .headline.bold(),
                        textColor: .secondary
                    ),
                    icon: .init(
                        foregroundColor: .white,
                        backgroundColor: .orange,
                        innerSize: .init(width: 44, height: 44),
                        outerSize: .init(width: 88, height: 88)
                    ),
                    logoHeight: 44,
                    title: .init(
                        textFont: .title3.bold(),
                        textColor: .red
                    ),
                    subtitle: .init(
                        textFont: .body,
                        textColor: .primary
                    )
                )
            )
        )
    )
}
#endif
