//
//  UtilityServiceLabel.swift
//  ForaBank
//
//  Created by Igor Malyarov on 02.06.2024.
//

import SwiftUI

struct UtilityServiceLabel<IconView: View>: View {
    
    let service: UtilityService
    let iconView: IconView
    
    var body: some View {
        
        HStack {
            
            iconView
                .frame(width: 32, height: 32)
            
            Text(service.name)
                .multilineTextAlignment(.leading)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 1)
        }
        .contentShape(Rectangle())
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.gray.opacity(0.1))
        )
    }
}

#Preview {
    UtilityServiceLabel(
        service: .init(name: "Utility Service", puref: "preview||123"),
        iconView: Text("..")
    )
}
