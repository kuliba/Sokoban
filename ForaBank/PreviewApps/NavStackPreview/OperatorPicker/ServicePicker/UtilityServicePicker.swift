//
//  UtilityServicePicker.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

struct UtilityServicePicker: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    var body: some View {
        
        List {
            
            ForEach(state.services, content: utilityServiceView)
        }
    }
    
    private func utilityServiceView(
        utilityService: UtilityService
    ) -> some View {
        
        Button(utilityService.name.prefix(16)) { event(utilityService) }
    }
}

extension UtilityServicePicker {
    
    typealias State = UtilityServicePickerState
    typealias Event = UtilityService
    typealias Config = UtilityServicePickerConfig
}

#Preview {
    UtilityServicePicker(
        state: .preview,
        event: { print($0) },
        config: .preview
    )
}
