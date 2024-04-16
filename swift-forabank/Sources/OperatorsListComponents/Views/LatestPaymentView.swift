//
//  LatestPaymentView.swift
//  
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import SwiftUI

public struct LatestPaymentView: View {
    
    let latestPayment: LatestPayment
    let event: (LatestPayment) -> Void
    let config: LatestPayment.LatestPaymentConfig
    
    public init(
        latestPayment: LatestPayment,
        event: @escaping (LatestPayment) -> Void,
        config: LatestPayment.LatestPaymentConfig
    ) {
        self.latestPayment = latestPayment
        self.config = config
        self.event = event
    }
    
    public var body: some View {
        
        Button(action: { event(latestPayment) }) {
            
            VStack {
             
                if let image = latestPayment.image {
                 
                    image
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                } else {
                    
                    Image.defaultIcon(
                        backgroundColor: config.backgroundColor,
                        icon: config.defaultImage
                    )
                }
                
                VStack(spacing: 3) {

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
            event: { _ in },
            config: .init(
                defaultImage: .init(systemName: ""),
                backgroundColor: .blue
            )
        )
    }
}
