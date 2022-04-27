//
//  RootView.swift
//  ForaBank
//
//  Created by Max Gribov on 15.02.2022.
//

import SwiftUI

struct RootView: View {
    
    @ObservedObject var viewModel: RootViewModel
    
    var body: some View {
        
        MainView(viewModel: .sampleProducts)
    }
}

struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        RootView(viewModel: .init(.emptyMock))
    }
}
