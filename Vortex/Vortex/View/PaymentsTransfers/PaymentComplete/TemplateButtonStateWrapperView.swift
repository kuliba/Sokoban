//
//  TemplateButtonStateWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 30.07.2024.
//

import SwiftUI

struct TemplateButtonStateWrapperView: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        
        TemplateButtonView(viewModel: viewModel)
    }
    
    typealias ViewModel = TemplateButtonView.ViewModel
}
