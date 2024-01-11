//
//  FastPaymentsSettingsView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 11.01.2024.
//

import SwiftUI

struct FastPaymentsSettingsView: View {
    
    @ObservedObject var viewModel: FastPaymentsSettingsViewModel
    
    var body: some View {
        
        Text("Fast Payments Settings")
    }
}

struct FastPaymentsSettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
 
        FastPaymentsSettingsView(viewModel: .preview)
    }
}
