//
//  SelectorWrapperView.swift
//
//
//  Created by Disman Dmitry on 02.02.2024.
//

import SwiftUI

public struct SelectorWrapperView: View {
    
    @StateObject var viewModel: SelectorViewModel
    
    public init(
        viewModel: SelectorViewModel
    ) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    public var body: some View {
        
        SelectorView(
            state: viewModel.state,
            event: viewModel.event
        )
    }
}
