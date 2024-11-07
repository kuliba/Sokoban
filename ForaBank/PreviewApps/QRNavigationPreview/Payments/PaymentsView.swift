//
//  PaymentsView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 29.10.2024.
//

import SwiftUI

struct PaymentsView: View {
    
    let model: Payments
    
    var body: some View {
        
        Text("Payments View for **\(model.url.relativeString)**")
            .foregroundColor(.secondary)
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Payments")
            .navigationBarBackButtonHidden()
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Button("Close", action: model.close)
                }
            }
    }
}
