//
//  InfoView.swift
//
//
//  Created by Andryusina Nataly on 13.03.2025.
//

import SwiftUI
import SharedConfigs

public struct InfoView: View {
    
    let info: Info
    let config: Config
    
    public init(info: Info, config: Config) {
        self.info = info
        self.config = config
    }
    
    public var body: some View {
        
        VStack(spacing: config.paddings.top) {
            
            info.title.text(withConfig: config.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, config.paddings.leading)
                .padding(.bottom, config.bottom)

            ForEach(info.list, id: \.title, content: item)
        }
        .padding(.bottom, config.paddings.bottom)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func item(
        _ item: Item
    ) -> some View {
        
        HStack(alignment: .top, spacing: config.paddings.trailing) {
            
            item.image
                .resizable()
                .renderingMode(.template)
                .foregroundColor(config.imageColor(item.enable))
                .frame(config.imageSize)
            
            item.title
                .text(withConfig: config.textConfig(item.enable))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, config.paddings.leading)
    }
}

public extension InfoView {
    
    typealias Config = SavingsAccountInfoConfig
    typealias Item = SavingsAccountInfo.Item
    typealias Info = SavingsAccountInfo
}

#Preview {
    InfoView(info: .preview, config: .preview)
}

private extension SavingsAccountInfoConfig {
    
    func imageColor(_ value: Bool) -> Color {
        value ? enable.color : disable.color
    }
    
    func textConfig(_ value: Bool) -> TextConfig {
        value ? enable.text : disable.text
    }
}
