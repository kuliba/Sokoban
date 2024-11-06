//
//  QRFailureView.swift
//  QRNavigationPreviewTests
//
//  Created by Igor Malyarov on 06.11.2024.
//

import SwiftUI

struct QRFailureView: View {
    
    let qrFailure: QRFailure
    
    var body: some View {
        
        Text(String(describing: qrFailure))
    }
}

#Preview {
    
    QRFailureView(
        qrFailure: .init(qrCode: .init(value: UUID().uuidString))
    )
}
