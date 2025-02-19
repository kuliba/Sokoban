//
//  PaymentCompletionLayoutView.swift
//
//
//  Created by Igor Malyarov on 16.02.2025.
//

import Combine
import SwiftUI
import UIPrimitives

public struct PaymentCompletionLayoutView<Buttons, Details, Footer, StatusView>: View
where Buttons: View,
      Details: View,
      Footer: View,
      StatusView: View {
    
    private let config: Config
    private let buttons: () -> Buttons
    private let details: () -> Details
    private let footer: () -> Footer
    private let statusView: () -> StatusView
    
    public init(
        config: Config,
        buttons: @escaping () -> Buttons,
        details: @escaping () -> Details,
        footer: @escaping () -> Footer,
        statusView: @escaping () -> StatusView
    ) {
        self.config = config
        self.buttons = buttons
        self.details = details
        self.footer = footer
        self.statusView = statusView
    }
    
    public var body: some View {
        
        VStack {
            
            VStack(spacing: config.spacing) {
                
                statusView() // PaymentCompletionStatusView
                details()
            }
            
            Spacer()
            
            buttons()
                .padding(.bottom, config.buttonsPadding)
        }
        .safeAreaInset(edge: .bottom, content: footer)
    }
    
    public typealias Config = PaymentCompletionLayoutViewConfig
}

extension PaymentCompletionLayoutView
where StatusView == PaymentCompletionStatusView {
    
    public init(
        state: PaymentCompletion,
        makeIconView: @escaping (String) -> UIPrimitives.AsyncImage,
        config: Config,
        statusConfig: PaymentCompletionConfig,
        buttons: @escaping () -> Buttons,
        details: @escaping () -> Details,
        footer: @escaping () -> Footer
    ) {
        self.init(
            config: config,
            buttons: buttons,
            details: details,
            footer: footer
        ) {
            PaymentCompletionStatusView(
                state: state,
                makeIconView: makeIconView,
                config: statusConfig
            )
        }
    }
}

struct PaymentCompletionLayoutView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            PaymentCompletionLayoutView(
                config: .preview,
                buttons: { Color.green.frame(height: 92) },
                details: { Color.blue.frame(height: 92) },
                footer: { Color.orange.frame(height: 112)},
                statusView: { Color.gray.frame(height: 280) }
            )
            
            paymentCompletionLayoutView(.completed)
                .previewDisplayName("completed")
            
            paymentCompletionLayoutView(.inflight)
                .previewDisplayName("inflight")
            
            paymentCompletionLayoutView(.rejected)
                .previewDisplayName("rejected")
            
            paymentCompletionLayoutView(.fraudCancelled)
                .previewDisplayName("fraudCancelled")
            
            paymentCompletionLayoutView(.fraudExpired)
                .previewDisplayName("fraudExpired")
        }
    }
    
    private static func paymentCompletionLayoutView(
        _ completion: PaymentCompletion
    ) -> some View {
        
        PaymentCompletionLayoutView(
            state: completion,
            makeIconView: {
                
                return .init(
                    image: .init(systemName: $0),
                    publisher: Just(.init(systemName: $0)).eraseToAnyPublisher()
                )
            },
            config: .preview,
            statusConfig: .preview,
            buttons: { Color.green.frame(height: 92) },
            details: { Color.blue.frame(height: 92) },
            footer: { Color.orange.frame(height: 112)}
        )
    }
}

private extension PaymentCompletion {
    
    static let completed: Self = .init(formattedAmount: "1,000 ¢", merchantIcon: nil, status: .completed)
    static let inflight: Self = .init(formattedAmount: "1,000 ¢", merchantIcon: nil, status: .inflight)
    static let rejected: Self = .init(formattedAmount: "1,000 ¢", merchantIcon: nil, status: .rejected)
    static let fraudCancelled: Self = .init(formattedAmount: "1,000 ¢", merchantIcon: nil, status: .fraud(.cancelled))
    static let fraudExpired: Self = .init(formattedAmount: "1,000 ¢", merchantIcon: nil, status: .fraud(.expired))
}

private extension PaymentCompletionLayoutViewConfig {
    
    static let preview: Self = .init(
        buttonsPadding: 56,
        spacing: 24
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
