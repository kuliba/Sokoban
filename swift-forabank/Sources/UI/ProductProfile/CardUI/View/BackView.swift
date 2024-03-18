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
    
    let back: Config.Back
    
    let header: () -> Header
    let cvv: () -> CVV
    
    public init(
        back: Config.Back,
        header: @escaping () -> Header,
        cvv: @escaping () -> CVV
    ) {
        self.back = back
        self.header = header
        self.cvv = cvv
    }
    
    public var body: some View {
        
        VStack {
            
            header()
                .padding(.leading, back.headerLeadingPadding)
                .padding(.top, back.headerLeadingPadding)
                .padding(.trailing, back.headerTrailingPadding)
            
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
                back: .preview,
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
