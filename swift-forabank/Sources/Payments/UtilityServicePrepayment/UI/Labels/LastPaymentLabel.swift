//
//  LastPaymentLabel.swift
//  
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import SwiftUI

public struct LastPaymentLabel<IconView>: View 
where IconView: View {
    
    private let amount: String
    private let title: String
    private let config: Config
    private let iconView: IconView
    
    public init(
        amount: String,
        title: String,
        config: Config,
        iconView: IconView
    ) {
        self.amount = amount
        self.title = title
        self.config = config
        self.iconView = iconView
    }
    
    public var body: some View {
        
        VStack {
            
            iconView
                .frame(width: 40, height: 40)
            
            titleView()
        }
        .frame(width: 80, height: 80)
        .contentShape(Rectangle())
    }
}

public extension LastPaymentLabel {
    
    typealias Config = LastPaymentLabelConfig
}

private extension LastPaymentLabel {

    func titleView() -> some View {
        
        VStack(spacing: 3) {
            
            title.text(withConfig: config.title)
                .lineLimit(1)
            amount.text(withConfig: config.amount)
        }
        .multilineTextAlignment(.center)
        .font(.system(size: 12))
    }
}

// MARK: - Previews

struct LatestPaymentView_Previews: PreviewProvider {
   
    static var previews: some View {
        
        LastPaymentLabel(
            amount: "amount",
            title: "title",
            config: .preview,
            iconView: Text("Icon View")
        )
    }
}
