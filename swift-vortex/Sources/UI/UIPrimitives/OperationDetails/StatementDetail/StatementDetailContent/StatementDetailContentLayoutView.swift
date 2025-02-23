//
//  StatementDetailContentLayoutView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import SharedConfigs
import SwiftUI

public struct StatementDetailContentLayoutView: View {
    
    private let content: Content
    private let config: Config
    
    public init(
        content: Content,
        config: Config
    ) {
        self.content = content
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: config.spacing) {
            
            logoView()
                .frame(config.logoSize)
            
            content.status.title.text(
                withConfig: config.config(for: content.status)
            )
            
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
            
            content.merchantLogo.map { image in
                
                image
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}

private extension StatementDetailContentLayoutViewConfig {
    
    var logoSize: CGSize { .init(width: logoWidth, height: logoWidth) }
}

private extension StatementDetailContent.Status {
    
    var title: String {
        
        switch self {
        case .completed: return "Успешно!"
        case .inflight: return "В обработке!"
        case .rejected: return "Отказ!"
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
            
            view(.completed)
            view(.inflight)
            view(.rejected)
        }
    }
    
    private static func view(
        _ status: StatementDetailContent.Status
    ) -> some View {
        
        StatementDetailContentLayoutView(
            content: .preview(status),
            config: .preview
        )
        .previewDisplayName(status.title)
    }
}

private extension StatementDetailContent {
    
    static func preview(
        _ status: Status = .completed
    ) -> Self {
        
        return .init(
            formattedAmount: "$ 1 000",
            formattedDate: "25 августа 2021, 19:54",
            merchantLogo: .init(systemName: "archivebox.circle"),
            merchantName: "УФК Владимирской области",
            purpose: "Транспортный налог",
            status: status
        )
    }
}
