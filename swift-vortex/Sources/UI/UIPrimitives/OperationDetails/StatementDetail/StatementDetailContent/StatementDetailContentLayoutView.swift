//
//  StatementDetailContentLayoutView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import SharedConfigs
import SwiftUI

public struct StatementDetailContentLayoutView<LogoView: View>: View {
    
    private let content: Content
    private let isLoading: Bool
    private let config: Config
    private let makeLogoView: (String) -> LogoView
    
    public init(
        content: Content,
        isLoading: Bool,
        config: Config,
        makeLogoView: @escaping (String) -> LogoView
    ) {
        self.content = content
        self.isLoading = isLoading
        self.config = config
        self.makeLogoView = makeLogoView
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            logoView()
            statusView()
            merchantNameView()
            formattedAmountView()
            purposeView()
            formattedDateView()
            if isLoading { buttonsPlaceholderView() }
        }
    }
}

public extension StatementDetailContentLayoutView {
    
    typealias Content = StatementDetailContent
    typealias Config = StatementDetailContentLayoutViewConfig
}

// MARK: - implementation

private extension StatementDetailContentLayoutView {
    
    func buttonsPlaceholderView() -> some View {
        
        HStack(spacing: 8) {
            
            ForEach(0..<3) { _ in buttonPlaceholderView() }
        }
    }
    
    func buttonPlaceholderView() -> some View {
        
        VStack(spacing: 18) {
            
            withShimmer { config.placeholderColors.button }
                .clipShape(Circle())
                .frame(config.frames.buttonCircle)
            
            withTextPlaceholder(size: config.frames.buttonText, content: EmptyView.init)
        }
        .frame(config.frames.button)
    }
    
    func logoView() -> some View {
        
        content.merchantLogo.map(makeLogoView)
            .frame(config.logoSize)
            .clipShape(Circle())
    }
    
    func statusView() -> some View {
        
        withTextPlaceholder(size: config.frames.status) {
            
            content.status.map {
                
                $0.title.text(withConfig: config.config(for: $0))
            }
        }
    }
    
    func merchantNameView() -> some View {
        
        content.merchantName?.text(withConfig: config.merchantName, alignment: .center)
    }
    
    func formattedAmountView() -> some View {
        
        withTextPlaceholder(size: config.frames.formattedAmount) {
            
            content.formattedAmount?.text(withConfig: config.formattedAmount, alignment: .center)
        }
    }
    
    func purposeView() -> some View {
        
        withTextPlaceholder(size: config.frames.purpose) {
            
            content.purpose?.text(withConfig: config.purpose, alignment: .center)
                .frame(height: config.purposeHeight)
        }
    }
    
    func formattedDateView() -> some View {
        
        withTextPlaceholder(size: config.frames.purpose) {
            
            content.formattedDate?.text(withConfig: config.formattedDate, alignment: .center)
        }
    }
    
    private func withTextPlaceholder(
        size: CGSize,
        content: () -> some View
    ) -> some View {
        
        ZStack {
            
            withShimmer(textPlaceholder).frame(size)
            content().opacity(isLoading ? 0 : 1)
        }
    }
    
    private func textPlaceholder() -> some View {
        
        config.placeholderColors.text
            .clipShape(RoundedRectangle(cornerRadius: 90))
    }
    
    private func withShimmer(
        _ content: () -> some View
    ) -> some View {
        
        content()
            .opacity(isLoading ? 1 : 0)
            ._shimmering(isActive: isLoading)
    }
}

private extension StatementDetailContentLayoutViewConfig {
    
    var logoSize: CGSize { .init(width: frames.logoWidth, height: frames.logoWidth) }
}

private extension StatementDetailContent.Status {
    
    var title: String {
        
        switch self {
        case .completed: return "Успешно"
        case .inflight: return "В обработке"
        case .rejected: return "Отказ"
        }
    }
}

private extension StatementDetailContentLayoutViewConfig {
    
    func config(
        for status: StatementDetailContent.Status
    ) -> TextConfig {
        
        return .init(
            textFont: self.status.font,
            textColor: color(for: status)
        )
    }
    
    func color(
        for status: StatementDetailContent.Status
    ) -> Color {
        
        switch status {
        case .completed:
            return self.status.completed
            
        case .inflight:
            return self.status.inflight
            
        case .rejected:
            return self.status.rejected
        }
    }
}

// MARK: - Previews

struct StatementDetailContentLayoutView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            view(.base, isLoading: true)
                .previewDisplayName("base loading")
            view(.base)
                .previewDisplayName("base")
            
            view(.withStatus, isLoading: true)
                .previewDisplayName("with status loading")
            view(.withStatus)
                .previewDisplayName("status loading")
            
            view(.completed, isLoading: true)
            view(.completed)
            
            view(.inflight)
            view(.rejected)
        }
        .border(.red)
    }
    
    private static func view(
        _ status: StatementDetailContent.Status,
        isLoading: Bool = false
    ) -> some View {
        
        view(.preview(status), isLoading: isLoading)
            .previewDisplayName(status.title)
    }
    
    private static func view(
        _ content: StatementDetailContent,
        isLoading: Bool = false
    ) -> some View {
        
        StatementDetailContentLayoutView(
            content: content,
            isLoading: isLoading,
            config: .preview
        ) {
            Image(systemName: $0)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

private extension StatementDetailContent {
    
    static let base: Self = make()
    static let withStatus: Self = make(status: .inflight)
    
    static func preview(
        _ status: Status = .completed
    ) -> Self {
        
        return .init(
            formattedAmount: "$ 1 000",
            formattedDate: "25 августа 2021, 19:54",
            merchantLogo: "archivebox.circle",
            merchantName: "УФК Владимирской области",
            purpose: "Транспортный налог",
            status: status
        )
    }
    
    private static func make(
        formattedAmount: String? = nil,
        formattedDate: String? = nil,
        merchantLogo: String = "archivebox.circle",
        merchantName: String = "УФК Владимирской области",
        purpose: String? = nil,
        status: Status? = nil
    ) -> Self {
        
        return .init(
            formattedAmount: formattedAmount,
            formattedDate: formattedDate,
            merchantLogo: merchantLogo,
            merchantName: merchantName,
            purpose: purpose,
            status: status
        )
    }
}
