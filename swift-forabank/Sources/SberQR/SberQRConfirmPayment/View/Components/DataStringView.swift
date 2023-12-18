//
//  DataStringView.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

import SwiftUI

struct DataStringView<ID: Equatable>: View {
    
    let data: Parameters.DataString<ID>
    
    var body: some View {
        
        Text(String(describing: data))
    }
}

// MARK: - Previews

struct DataStringView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        DataStringView(data: .preview)
    }
}
