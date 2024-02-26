//
//  LatestPaymentView.swift
//  
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import SwiftUI

public struct LatestPaymentView: View {
    
    let latestPayment: LatestPayment
    let event: (ComposedOperatorsEvent) -> Void
    
    public init(
        latestPayment: LatestPayment,
        event: @escaping (ComposedOperatorsEvent) -> Void
    ) {
        self.latestPayment = latestPayment
        self.event = event
    }
    
    public var body: some View {
        
        Button {
            
            event(.selectLastOperation(latestPayment.id))
            
        } label: {
            
            VStack {
             
                latestPayment.image
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                
                VStack(spacing: 8) {

                    Text(latestPayment.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .font(.system(size: 12))
                        .lineLimit(1)
                        
                        Text(latestPayment.amount)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.red)
                            .font(.system(size: 12))
                }
            }
            .frame(width: 80, height: 80, alignment: .center)
        }
        .contentShape(Rectangle())
    }
}

struct LatestPaymentView_Previews: PreviewProvider {
   
    static var previews: some View {
        
        LatestPaymentView(
            latestPayment: .init(
                image: .init(systemName: ""),
                title: "title",
                amount: "amount"
            ),
            event: { _ in }
        )
    }
}
