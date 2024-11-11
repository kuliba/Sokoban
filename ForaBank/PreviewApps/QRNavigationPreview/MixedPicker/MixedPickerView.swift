//
//  MixedPickerView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 07.11.2024.
//

import SwiftUI

struct MixedPickerView: View {
    
    let model: MixedPicker
    
    var body: some View {
        
        Button("Add Company", action: model.addCompany)
            .navigationTitle("MixedPicker")
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
}

#Preview {
    
    MixedPickerView(model: .init())
}
