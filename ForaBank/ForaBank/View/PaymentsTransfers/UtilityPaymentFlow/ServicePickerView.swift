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
        
        List {
            
            ForEach(state, content: serviceView)
        }
        .listStyle(.plain)
    }
}

extension ServicePickerView {
    
    typealias State = [Service]
}
