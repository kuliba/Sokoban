//
//  UtilityServicePicker.swift
//  NavStackPreview
//
//  Created by Igor Malyarov on 23.04.2024.
//

import SwiftUI

struct UtilityServicePicker<Icon, IconView>: View
where IconView: View {
    
    let state: State
    let event: (Service) -> Void
    let config: Config
    let iconView: (Icon) -> IconView
    
    var body: some View {
        
        List {
            
            ForEach(state.services, content: serviceView)
        }
    }
    
    private func serviceView(
        service: Service
    ) -> some View {
        
        Button(action: { event(service) }) {
            
            Label {
                Text(service.name.prefix(16))
            } icon: {
                iconView(service.icon).aspectRatio(contentMode: .fit)
            }
        }
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
        config: .preview,
        iconView: { Text($0) }
    )
}
