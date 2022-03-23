//
//  AuthCardScannerView.swift
//  ForaBank
//
//  Created by Max Gribov on 24.02.2022.
//

import SwiftUI

struct AuthCardScannerView: View {
    
    @ObservedObject var viewModel: AuthCardScannerViewModel
    
    var body: some View {
        
        Text("Card Scanner ...")
    }
}

struct AuthScanCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AuthCardScannerView(viewModel: .init(scannedAction: {_ in }, dismissAction: {}))
    }
}
