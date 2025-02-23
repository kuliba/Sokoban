//
//  StatementDetailContentLayoutView.swift
//  Vortex
//
//  Created by Igor Malyarov on 23.02.2025.
//

import SharedConfigs
import SwiftUI

struct StatementDetailContent: Equatable {
    
    let formattedAmount: String?
    let formattedDate: String?
    let merchantLogo: Image?
    let merchantName: String?
    let purpose: String?
    let status: Status
    
    enum Status {
        
        case completed, inflight, rejected
    }
}

struct StatementDetailContentLayoutView: View {
    
    let content: Content
    let config: Config
    
    var body: some View {
        
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

extension StatementDetailContentLayoutView {
    
    typealias Content = StatementDetailContent
    typealias Config = StatementDetailContentLayoutViewConfig
}

struct StatementDetailContentLayoutViewConfig: Equatable {
    
    let formattedAmount: TextConfig
    let formattedDate: TextConfig
    let logoWidth: CGFloat
    let merchantName: TextConfig
    let purpose: TextConfig
    let purposeHeight: CGFloat
    let spacing: CGFloat
    let status: Status
    
    struct Status: Equatable {
        
        let font: Font
        let completed: Color
        let inflight: Color
        let rejected: Color
    }
    
    var logoSize: CGSize { .init(width: logoWidth, height: logoWidth) }
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
            config: .iVortex
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
