//
//  SberQRFeatureView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 19.11.2023.
//

import SwiftUI

struct SberQRFeatureView: View {
    
    @StateObject var viewModel: SberQRFeatureViewModel
    
    let url: URL
    let dismiss: () -> Void
    
    var body: some View {
        
        SberQRPaymentView(
            url: url,
            dismiss: dismiss,
            asyncGet: viewModel.setSelection
        )
        .sheet(item: .init(
            get: { viewModel.selection },
            set: { if $0 == nil { viewModel.resetSelection() }})
        ) { selection in
            
            NavigationView {
                
                TextPickerView(commit: viewModel.consumeSelection)
                    .navigationTitle("Select")
            }
        }
    }
}

#Preview {
    SberQRFeatureView(
        viewModel: .init(),
        url: .init(string: "https://platiqr.ru/?uuid=3001638371&amount=27.50&trxid=2023072420443097822")!,
        dismiss: {}
    )
}
