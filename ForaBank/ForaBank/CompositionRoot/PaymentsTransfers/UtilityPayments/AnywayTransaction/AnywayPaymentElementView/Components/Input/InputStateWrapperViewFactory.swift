//
//  InputStateWrapperViewFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import SwiftUI

struct InputStateWrapperViewFactory {
    
    let makeIconView: MakeIconView
}

extension InputStateWrapperViewFactory {
    
    typealias MakeIconView = () -> InputIconView
}

struct InputIconView: View {
    
    var body: some View {
        
        Text("?")
    }
}
