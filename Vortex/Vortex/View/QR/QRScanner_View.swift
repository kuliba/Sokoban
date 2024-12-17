//
//  QRScanner_View.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.11.2024.
//

import SwiftUI

struct QRScanner_View: View {
    
    let qrScanner: QRScanner
    let viewFactory: QRViewFactory
    
    var body: some View {
        
        if let qrModel = qrScanner as? QRViewModel {
            
            QRView(viewModel: qrModel, viewFactory: viewFactory)
        }
    }
}
