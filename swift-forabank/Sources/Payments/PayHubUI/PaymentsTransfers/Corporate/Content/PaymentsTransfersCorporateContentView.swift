//
//  PaymentsTransfersCorporateContentView.swift
//
//
//  Created by Igor Malyarov on 04.09.2024.
//

import SwiftUI

public struct PaymentsTransfersCorporateContentView: View {
    
    let content: Content
    let config: Config
    
    public init(
        content: Content,
        config: Config
    ) {
        self.content = content
        self.config = config
    }

    public var body: some View {
        
        Text("TBD " + String(describing: content))
            .frame(maxHeight: .infinity)
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Text("TBD: Profile without QR")
                }
            }
    }
}

public extension PaymentsTransfersCorporateContentView {
    
    typealias Content = PaymentsTransfersCorporateContent
    typealias Config = PaymentsTransfersCorporateContentViewConfig
}

#Preview {
    PaymentsTransfersCorporateContentView(
        content: .init(),
        config: .preview
    )
}
