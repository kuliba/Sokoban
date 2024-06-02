//
//  UtilityServiceLabel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.06.2024.
//

import SwiftUI

struct UtilityServiceLabel<IconView: View>: View {
    
    let service: UtilityService
    let iconView: () -> IconView
    
    var body: some View {
        
        HStack {
            
            iconView()
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(service.name)
                    .font(.subheadline)
                
                Text(service.id)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 1)
        }
        .contentShape(Rectangle())
        .foregroundColor(service.id.localizedCaseInsensitiveContains("failure") ? .red : .primary)
    }
}

#Preview {
    UtilityServiceLabel(
        service: .init(name: "Utility Service", puref: "preview||123"),
        iconView: { Text("..") }
    )
}
