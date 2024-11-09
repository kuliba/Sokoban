//
//  ServicePickerView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.11.2024.
//

import SwiftUI

struct ServicePickerView: View {
    
    let model: ServicePicker
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            Button("Add Company", action: model.addCompany)
            Button("Go to Main", action: model.goToMain)
        }
        .navigationTitle("ServicePicker")
    }
}

#Preview {
    
    ServicePickerView(model: .init())
}
