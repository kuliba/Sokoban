//
//  GetCollateralLandingView.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

import SwiftUI
import BottomSheetComponent

public struct GetCollateralLandingView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    var bottomSheet: Binding<State.BottomSheet?> {
        
    .init(
        get: { state.bottomSheet },
        set: { if $0 == nil { event(.closeBottomSheet) } })
    }
    
    public var body: some View {
        
        ScrollView {
            ZStack {
                
                backgroundImageView
                contentView
            }
            .background(state.product.getCollateralLandingTheme.backgroundColor)
        }
        .ignoresSafeArea()
        .bottomSheet(item: bottomSheet, content: {
            
            switch $0.sheetType {
            case let .periods(period):
                BottomSheetContentView(items: period.map(\.bottomSheetItem)) {
                    event(.selectCollateral($0))
                }
            case let .collaterals(collateral):
                BottomSheetContentView(items: collateral.map(\.bottomSheetItem)) {
                    event(.selectCollateral($0))
                }
            }
        })
    }
    
    var backgroundImageView: some View {
        
        VStack {
            // TODO: Need to realized
            // Image(backgroundImage)
            
            // simulacrum
            if #available(iOS 15.0, *) {
                Color.teal
                    .frame(height: factory.config.backgroundImageHeight)
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .ignoresSafeArea(edges: .all)
    }

    var contentView: some View {
        
        VStack {
            
            HeaderView(config: factory.config)
            
            state.product.conditions.nilIfEmpty.map { _ in
                
                ConditionsView(config: factory.config, product: state.product)
            }
            
            CalculatorView(config: factory.config, product: state.product)
            
            state.product.faq.nilIfEmpty.map { _ in

                FaqView(config: factory.config, product: state.product)
            }

            state.product.documents.nilIfEmpty.map { _ in

                DocumentsView(config: factory.config, product: state.product)
            }
            
            FooterView(
                config: factory.config.footer,
                product: state.product,
                action: { event(.createDraftApplication) }
            )
        }
        .background(Color.clear)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.bottom, factory.config.paddings.outerBottom)
        .ignoresSafeArea(edges: .all)
    }
}

extension GetCollateralLandingView {
    
    typealias HeaderView = GetCollateralLandingHeaderView
    typealias ConditionsView = GetCollateralLandingConditionsView
    typealias CalculatorView = GetCollateralLandingCalculatorView
    typealias FaqView = GetCollateralLandingFaqView
    typealias DocumentsView = GetCollateralLandingDocumentsView
    typealias FooterView = GetCollateralLandingFooterView
    
    typealias Factory = GetCollateralLandingFactory
    typealias State = GetCollateralLandingState
    typealias Event = GetCollateralLandingEvent
}

// MARK: - Previews

struct GetCollateralLandingView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingView(
            state: .init(product: .carStub),
            event: { _ in },
            factory: factory
        )
        .previewDisplayName("Product with calculator")

        let periodBottomSheet = State.BottomSheet(sheetType: .periods(carStub.calc.rates))
        
        GetCollateralLandingView(
            state: .init(bottomSheet: periodBottomSheet, product: .carStub),
            event: { _ in },
            factory: factory
        )
        .previewDisplayName("Product period selector")
        
        let collateralBottomSheet = State.BottomSheet(sheetType: .collaterals(carStub.calc.collaterals))

        GetCollateralLandingView(
            state: .init(bottomSheet: collateralBottomSheet, product: .carStub),
            event: { _ in },
            factory: factory
        )
        .previewDisplayName("Product collateral selector")
    }

    static let carStub = GetCollateralLandingProduct.carStub
    static let factory = GetCollateralLandingFactory()

    typealias State = GetCollateralLandingState
}
