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
        
        Button("Add Company", action: model.addCompany)
            .navigationTitle("ServicePicker")
    }
}

#Preview {
    
    ServicePickerView(model: .init())
}
