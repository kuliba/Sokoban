//
//  OrderProcessCardView.swift
//
//
//  Created by Дмитрий Савушкин on 09.02.2025.
//

//import CreateCardApplication
//import Foundation
//import LinkableText
//import OTPInputComponent
//import PaymentComponents
//import SharedConfigs
//import UIPrimitives
import SwiftUI

public struct OrderCardView<Confirmation>: View {
    
    let state: State
    let event: (Event) -> Void
    let config: Config
    
    private let coordinateSpace: String
    
    public init(
        state: State,
        event: @escaping (Event) -> Void,
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
}

public extension OrderCardView {
    
    typealias State = OrderCard.State<Confirmation>
    typealias Event = OrderCard.Event<Confirmation>
    typealias Config = OrderCardViewConfig
}
