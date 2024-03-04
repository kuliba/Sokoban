//
//  UtilityServicePicker.swift
//  ForaBank
//
//  Created by Igor Malyarov on 27.02.2024.
//

import SwiftUI

struct UtilityServicePicker: View {
    
    let state: [UtilityService] // TODO: replace with NonEmpty
    let event: (UtilityService) -> Void
    
    var body: some View {
        
        List {
            
            ForEach(state, content: serviceView)
        }
        .listStyle(.plain)
    }
    
    private func serviceView(
        service: UtilityService
    ) -> some View {
        
        Button(service.id) { event(service) }
    }
}

struct UtilityServicePicker_Previews: PreviewProvider {
    
    static var previews: some View {
 
        UtilityServicePicker(state: [], event: { _ in })
    }
}
