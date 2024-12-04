//
//  SavingsAccountWrapperView.swift
//  
//
//  Created by Andryusina Nataly on 04.12.2024.
//

import RxViewModel
import SavingsAccount
import SwiftUI

struct SavingsAccountWrapperView: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    private let config: Config
    private let imageViewFactory: ImageViewFactory
    
    init(
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

extension SavingsAccountWrapperView {
    
    typealias ViewModel = SavingsAccountViewModel
    typealias Config = SavingsAccountConfig
}

typealias SavingsAccountViewModel = RxViewModel<SavingsAccountState, SavingsAccountEvent, SavingsAccountEffect>
