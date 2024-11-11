//
//  MultiplePickerView.swift
//  QRNavigationPreview
//
//  Created by Igor Malyarov on 08.11.2024.
//

import SwiftUI

struct MultiplePickerView: View {
    
    let model: MultiplePicker
    
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
    
    MultiplePickerView(model: .init())
}
