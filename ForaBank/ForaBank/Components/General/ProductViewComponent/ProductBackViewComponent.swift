//
//  ProductBackViewComponent.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 02.05.2023.
//

import ProductSelectComponent
import SwiftUI
import CardUI
//MARK: - View

struct ProductBackView<Header: View, CVV: View>: View {
    
    let backConfig: CardUI.Config.Back
    
    let headerView: () -> Header
    let cvvView: () -> CVV
    
    var body: some View {
        
        VStack {
            
            headerView()
                .padding(.leading, backConfig.headerLeadingPadding)
                .padding(.top, backConfig.headerLeadingPadding)
                .padding(.trailing, backConfig.headerTrailingPadding)
            
            cvvView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

//MARK: - Internal Views

extension ProductView {
    
    struct HeaderBackView: View {
        
        @Binding var cardInfo: CardInfo
        let action: () -> Void
        
        var body: some View {
            
            VStack (alignment: .leading) {
                
                if !cardInfo.numberToDisplay.isEmpty {
                    
                    HStack {
                        
                        Text(cardInfo.numberToDisplay)
                            .font(.textH4M16240())
                            .foregroundColor(.mainColorsWhite)
                            .accessibilityIdentifier("numberToDisplay")
                        
                        Spacer()
                        
                        Button(action: action) {
                            
                            Image.ic24Copy
                                .resizable()
                                .frame(width: 24, height: 24, alignment: .center)
                                .foregroundColor(.mainColorsWhite)
                            
                        }
                    }
                }
                Text(cardInfo.owner)
                    .font(.textBodyMM14200())
                    .foregroundColor(.mainColorsWhite)
                    .accessibilityIdentifier("ownerName")
                    .padding(.top, 12 / UIScreen.main.scale)
            }
        }
    }
    
    struct CVVView: View {
        
        @Binding var cardInfo: CardInfo
        let action: () -> Void
        @State private var showDotsAnimation: Bool = false
        
        var body: some View {
            
            VStack {
                
                ZStack {
                    
                    Button(cardInfo.cvvToDisplay, action: action)
                        .font(.textBodyMR14200())
                        .foregroundColor(.mainColorsWhite)
                    if showDotsAnimation {
                        
                        DotsAnimations()
                    }
                }
                .frame(CGSize(width: 76, height: 40))
                .background(RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.textPlaceholder)
                    .opacity(0.5)
                )
                .padding(.trailing, 12 / UIScreen.main.scale)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

private extension ProductView {
    
    struct DotsAnimations : View {
        
        var body: some View {
            
            HStack(spacing: 3) {
                
                AnimatedDotView(duration: 0.6, delay: 0)
                AnimatedDotView(duration: 0.6, delay: 0.2)
                AnimatedDotView(duration: 0.6, delay: 0.4)
            }
        }
    }
}
