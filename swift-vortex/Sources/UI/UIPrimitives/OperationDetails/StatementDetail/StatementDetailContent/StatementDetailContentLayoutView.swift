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
    private let config: Config
    private let makeLogoView: (String) -> LogoView
    
    public init(
        content: Content,
        config: Config,
        makeLogoView: @escaping (String) -> LogoView
    ) {
        self.content = content
        self.config = config
        self.makeLogoView = makeLogoView
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            logoView()
                .frame(config.logoSize)
            
            content.status.map {
                
                $0.title.text(withConfig: config.config(for: $0))
            }
            
            content.merchantName?.text(withConfig: config.merchantName, alignment: .center)
            
            content.formattedAmount?.text(withConfig: config.formattedAmount, alignment: .center)
            
            content.purpose?.text(withConfig: config.purpose, alignment: .center)
                .frame(height: config.purposeHeight)
            
            content.formattedDate?.text(withConfig: config.formattedDate, alignment: .center)
        }
    }
}

public extension StatementDetailContentLayoutView {
    
    typealias Content = StatementDetailContent
    typealias Config = StatementDetailContentLayoutViewConfig
}

// MARK: - implementation

private extension StatementDetailContentLayoutView {
    
    func logoView() -> some View {
        
        ZStack {
            
            Color.clear
            
            content.merchantLogo.map(makeLogoView)
        }
    }
}

private extension StatementDetailContentLayoutViewConfig {
    
    var logoSize: CGSize { .init(width: logoWidth, height: logoWidth) }
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
            
            view(.empty)
            view(.logo)
            view(.logoWithStatus)
            
            view(.completed)
            view(.inflight)
            view(.rejected)
        }
        .border(.red)
    }
    
    private static func view(
        _ status: StatementDetailContent.Status
    ) -> some View {
        
        view(.preview(status))
    }
    
    private static func view(
        _ content: StatementDetailContent
    ) -> some View {
        
        StatementDetailContentLayoutView(
            content: content,
            config: .preview
        ) {
            Image(systemName: $0)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .previewDisplayName(content.status?.title)
    }
}

private extension StatementDetailContent {
    
    static let empty: Self = make()
    static let logo: Self = make(merchantLogo: "archivebox.circle")
    static let logoWithStatus: Self = make(merchantLogo: "archivebox.circle", status: .inflight)
    
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
        merchantLogo: String? = nil,
        merchantName: String? = nil,
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
