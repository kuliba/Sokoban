//
//  LastPaymentView.swift
//  
//
//  Created by Дмитрий Савушкин on 20.02.2024.
//

import SwiftUI

public struct LastPaymentView: View {
    
    let lastPayment: LastPayment
    let event: (LastPayment) -> Void
    let config: Config
    
    public init(
        lastPayment: LastPayment,
        event: @escaping (LastPayment) -> Void,
        config: Config
    ) {
        self.lastPayment = lastPayment
        self.config = config
        self.event = event
    }
    
    public var body: some View {
        
        Button(action: { event(lastPayment) }, label: label)
    }
}

public extension LastPaymentView {
    
    typealias Config = LastPaymentConfig
}

private extension LastPaymentView {
    
    func label() -> some View {
        
        VStack {
            
            image()
                .frame(width: 40, height: 40)
            
            title()
        }
        .frame(width: 80, height: 80)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    func image() -> some View {
        
        if let image = lastPayment.image {
            image.resizable()
        } else {
            Image.defaultIcon(
                backgroundColor: config.backgroundColor,
                foregroundColor: .white,
                icon: config.defaultImage
            )
        }
    }

    func title() -> some View {
        
        VStack(spacing: 3) {
            
            Text(lastPayment.title)
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text(lastPayment.amount)
                .foregroundColor(.red)
        }
        .multilineTextAlignment(.center)
        .font(.system(size: 12))
    }
}

// MARK: - Previews

struct LatestPaymentView_Previews: PreviewProvider {
   
    static var previews: some View {
        
        LastPaymentView(
            lastPayment: .init(
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
