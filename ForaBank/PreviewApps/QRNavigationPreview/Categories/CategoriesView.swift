//
//  CategoriesView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 07.11.2024.
//

import SwiftUI

struct CategoriesView: View {
    
    let model: Categories
    
    var body: some View {
        
        content
            .foregroundColor(.secondary)
            .padding(.top)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Payment Categories")
            .navigationBarBackButtonHidden()
            .toolbar {
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Button(action: model.close) {
                        
                        Image(systemName: "chevron.left")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button(action: model.scanQR) {
                        
                        Image(systemName: "qrcode.viewfinder")
                    }
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
        
        if model.qrCode.value.isEmpty {
            Text("Load Categories failure")
                .foregroundColor(.red)
        } else {
            Text("TBD: list of categories")
        }
    }
}

#Preview {
    
    NavigationView {
        
        CategoriesView(model: .init(
            qrCode: .init(value: .init(UUID().uuidString.prefix(6)))
        ))
    }
}
