//
//  OrderSavingsAccountWrapperView.swift
//  Vortex
//
//  Created by Andryusina Nataly on 05.02.2025.
//

import SwiftUI
import RxViewModel
import SavingsAccount

struct OrderSavingsAccountWrapperView: View {
    
    @ObservedObject var viewModel: ViewModel

    let amountToString: OrderSavingsAccountView.AmountToString
    let config: Config
    let imageFactory: SavingsAccount.ImageViewFactory
    let viewFactory: SavingsAccountDomain.OpenAccountViewFactory
    
    var body: some View {
        
        RxWrapperView(
            model: viewModel,
            makeContentView: { state, event in
                
               SavingsAccountDomain.OpenAccountView(
                    amountToString: amountToString,
                    state: state,
                    event: event,
                    config: config,
                    factory: imageFactory,
                    viewFactory: viewFactory
                )
            }
        )
    }
}

extension OrderSavingsAccountWrapperView {
    
    typealias ViewModel = OrderSavingsAccountViewModel
    typealias Config = SavingsAccount.OrderSavingsAccountConfig
}

typealias OrderSavingsAccountViewModel = RxViewModel<OrderSavingsAccountState, OrderSavingsAccountEvent, OrderSavingsAccountEffect>
