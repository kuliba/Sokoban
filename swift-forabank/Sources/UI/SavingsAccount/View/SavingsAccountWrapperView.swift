//
//  SavingsAccountWrapperView.swift
//
//
//  Created by Andryusina Nataly on 20.11.2024.
//

import SwiftUI
import RxViewModel

public struct SavingsAccountWrapperView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let config: Config
    private let imageViewFactory: ImageViewFactory
    
    public init(
        viewModel: ViewModel,
        config: Config,
        imageViewFactory: ImageViewFactory
    ) {
        self.viewModel = viewModel
        self.config = config
        self.imageViewFactory = imageViewFactory
    }
    
    public var body: some View {
        
        RxWrapperView(
            model: viewModel,
            makeContentView: {
                SavingsAccountView(
                    state: $0,
                    event: $1,
                    config: config,
                    factory: imageViewFactory
                )
            }
        )
    }
}

public extension SavingsAccountWrapperView {
    
    typealias ViewModel = SavingsAccountViewModel
    typealias Config = SavingsAccountConfig
}
