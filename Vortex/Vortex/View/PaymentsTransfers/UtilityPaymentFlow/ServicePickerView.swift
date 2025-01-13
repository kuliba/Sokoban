//
//  ServicePickerView.swift
//
//
//  Created by Igor Malyarov on 05.05.2024.
//

import Foundation
import SwiftUI

struct ServicePickerView<Service, ServiceView>: View
where Service: Identifiable,
      ServiceView: View {
    
    let state: State
    let serviceView: (Service) -> ServiceView
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(spacing: 16) {
                
                ForEach(state, content: serviceView)
            }
            .padding()
        }
    }
}

extension ServicePickerView {
    
    typealias State = [Service]
}
