//
//  UtilityServicePicker.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

struct UtilityServicePicker<Icon>: View {
    
    let state: State
    let event: (Service) -> Void
    let config: Config
    
    var body: some View {
        
        List {
            
            ForEach(state.services, content: serviceView)
        }
    }
    
    private func serviceView(
        service: Service
    ) -> some View {
        
        Button(service.name.prefix(16)) { event(service) }
    }
}

extension UtilityServicePicker {
    
    typealias State = UtilityServicePickerState<Icon>
    typealias Service = UtilityService<Icon>
    typealias Config = UtilityServicePickerConfig
}

#Preview {
    UtilityServicePicker(
        state: .preview,
        event: { print($0) },
        config: .preview
    )
}
