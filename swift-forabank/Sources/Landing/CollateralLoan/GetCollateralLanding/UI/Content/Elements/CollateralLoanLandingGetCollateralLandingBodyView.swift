//
//  CollateralLoanLandingGetCollateralLandingBodyView.swift
//
//
//  Created by Valentin Ozerov on 14.11.2024.
//

import SwiftUI

struct CollateralLoanLandingGetCollateralLandingBodyView: View {
    
    let backgroundImage: String
    let headerView: HeaderView
    let conditionsView: ConditionsView?
    let calculatorView: CalculatorView
    let frequentlyAskedQuestionsView: FrequentlyAskedQuestionsView?
    let documentsView: DocumentsView?
    let footerView: FooterView
    let config: Config
    let theme: Theme
    
    var body: some View {

        ScrollView {
            ZStack {
                
                backgroundImageView
                contentView
            }
            .background(theme.backgroundColor)
        }
        .ignoresSafeArea()
    }
    
    typealias Config = CollateralLoanLandingGetCollateralLandingViewConfig
}

private extension CollateralLoanLandingGetCollateralLandingBodyView {
    
    var backgroundImageView: some View {
        
        VStack {
            // TODO: Need to realized
            // Image(backgroundImage)
            
            // simulacrum
            if #available(iOS 15.0, *) {
                Color.teal
                    .frame(height: config.backgroundImageHeight)
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .ignoresSafeArea(edges: .all)
    }
    
    var contentView: some View {
        
        VStack {
            
            headerView
            
            if let conditionsView {
                conditionsView
            }
            
            calculatorView
            
            if let frequentlyAskedQuestionsView {
                frequentlyAskedQuestionsView
            }
            
            if let documentsView {
                documentsView
            }
            
            footerView
        }
        .background(Color.clear)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.bottom, config.paddings.outerBottom)
        .ignoresSafeArea(edges: .all)
    }
}

extension CollateralLoanLandingGetCollateralLandingBodyView {
    
    typealias HeaderView = CollateralLoanLandingGetCollateralLandingHeaderView
    typealias ConditionsView = CollateralLoanLandingGetCollateralLandingConditionsView
    typealias CalculatorView = CollateralLoanLandingGetCollateralLandingCalculatorView
    typealias FrequentlyAskedQuestionsView = CollateralLoanLandingGetCollateralLandingFrequentlyAskedQuestionsView
    typealias DocumentsView = CollateralLoanLandingGetCollateralLandingDocumentsView
    typealias FooterView = CollateralLoanLandingGetCollateralLandingFooterView
typealias Theme = CollateralLoanLandingGetCollateralLandingTheme
}

// MARK: - Previews

struct CollateralLoanLandingGetCollateralLandingView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        CollateralLoanLandingGetCollateralLandingView(
            content: content,
            factory: factory
        )
    }
    
    static let cardData = GetCollateralLandingProduct.cardStub
    static let realEstateData = GetCollateralLandingProduct.realEstateStub
    static let content = Content(product: cardData)
    static let factory = Factory()
    
    typealias Content = CollateralLoanLandingGetCollateralLandingContent
    typealias Factory = CollateralLoanLandingGetCollateralLandingViewFactory
}
