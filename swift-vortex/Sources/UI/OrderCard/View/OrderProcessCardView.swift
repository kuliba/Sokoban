//
//  OrderProcessCardView.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

import Foundation
import LinkableText
import PaymentComponents
import SharedConfigs
import SwiftUI
import CreateCardApplication
import OTPInputComponent
import UIPrimitives

public struct Config {
    
    let product: ProductConfig
    let shimmeringColor: Color
}

public struct OrderProcessCardView<Confirmation>: View {
    
    let state: State<Confirmation>
    let event: (Event<Confirmation>) -> Void
    let config: Config
    
    private let coordinateSpace: String
    
    public init(
        state: State<Confirmation>,
        event: @escaping (Event<Confirmation>) -> Void,
        config: Config,
        coordinateSpace: String = "orderScroll"
    ) {
        self.state = state
        self.event = event
        self.config = config
        self.coordinateSpace = coordinateSpace
    }
    
    public var body: some View {
        
        ZStack {
            
            ScrollView(showsIndicators: false) {
                
//                orderProcessCardView(state.orderProduct)
            }
            .coordinateSpace(name: coordinateSpace)
        }
    }
    
    private func orderProcessCardView(
        _ data: OrderProcessCard?
    ) -> some View {
        
        VStack(spacing: 16) {
            
//            ProductView(
//                product: .init(
//                    image: <#T##String#>,
//                    header: <#T##(String, String)#>,
//                    orderOption: <#T##(open: String, service: String)#>
//                ),
//                isLoading: <#T##Bool#>,
//                config: <#T##ProductConfig#>
//            )
//            income(income: <#T##String#>)
//            messageView(data == nil)
        }
        .padding(.all, 15)
    }
}
