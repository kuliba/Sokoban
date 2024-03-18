//
//  BackView.swift
//
//
//  Created by Andryusina Nataly on 18.03.2024.
//

import SwiftUI
import Foundation

//MARK: - View

public struct BackView<Header: View, CVV: View>: View {
    
    let backConfig: Config.Back
    
    let header: () -> Header
    let cvv: () -> CVV
    
    public init(
        backConfig: Config.Back,
        header: @escaping () -> Header,
        cvv: @escaping () -> CVV
    ) {
        self.backConfig = backConfig
        self.header = header
        self.cvv = cvv
    }
    
    public var body: some View {
        
        VStack {
            
            header()
                .padding(.leading, backConfig.headerLeadingPadding)
                .padding(.top, backConfig.headerLeadingPadding)
                .padding(.trailing, backConfig.headerTrailingPadding)
            
            cvv()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

struct BackView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ZStack {
            
            Color.red
            BackView(
                backConfig: .preview,
                header: {
                    HeaderBackView(
                        cardInfo: .previewWiggleFalse,
                        action: { print("action") },
                        config: .config(.preview))
                },
                cvv: {
                    CVVView(
                        cardInfo: .previewWiggleFalse,
                        config: .config(.preview),
                        action: { print("cvv action") })
                })
        }
        .fixedSize()
    }
}
