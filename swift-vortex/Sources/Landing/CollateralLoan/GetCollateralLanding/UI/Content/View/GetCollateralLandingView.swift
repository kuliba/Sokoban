//
//  GetCollateralLandingView.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

import BottomSheetComponent
import Combine
import SwiftUI

public struct GetCollateralLandingView: View {
    
    let state: State
    let event: (Event) -> Void
    let factory: Factory
    
    public var body: some View {
        
        ScrollView {
            
            ZStack {
                
                backgroundImageView
                contentView
            }
            .background(state.product.getCollateralLandingTheme.backgroundColor)
        }
        .ignoresSafeArea()
        .bottomSheet(item: bottomSheetItem, content: bottomSheet)
    }
    
    private func bottomSheet(_ bottomSheet: State.BottomSheet) -> some View {
        
        switch bottomSheet.sheetType {
        case let .periods(period):
            return BottomSheetView(
                items: period.map(\.bottomSheetItem),
                config: factory.config.bottomSheet,
                makeImageView: factory.makeImageView
            ) {
                switch $0 {
                case .selectMonthPeriod(let termMonth):
                    event(.selectMonthPeriod(termMonth))
                default: break
                }
            }
        case let .collaterals(collateral):
            return BottomSheetView(
                items: collateral.map(\.bottomSheetItem),
                config: factory.config.bottomSheet,
                makeImageView: factory.makeImageView
            ) {
                switch $0 {
                case .selectCollateral(let collateral):
                    event(.selectCollateral(collateral))
                default: break
                }
            }
        }
    }
    
    private var bottomSheetItem: Binding<State.BottomSheet?> {
        
    .init(
        get: { state.bottomSheet },
        set: { _ in })
    }

    var backgroundImageView: some View {
        
        VStack {
            
            factory.makeImageView(state.product.marketing.image)
                .frame(height: factory.config.backgroundImageHeight)
            
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
                
                ConditionsView(
                    state: state,
                    config: factory.config,
                    makeImageView: factory.makeImageView
                )
            }
            
            CalculatorView(
                state: state,
                config: factory.config,
                event: { event($0) }
            )
            
            state.product.faq.nilIfEmpty.map { _ in

                FaqView(state: state, config: factory.config)
            }

            state.product.documents.nilIfEmpty.map { _ in

                DocumentsView(
                    config: factory.config,
                    state: state,
                    makeImageView: factory.makeImageView)
            }
            
            FooterView(
                config: factory.config.footer,
                state: state,
                event: { event($0) }
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
    typealias BottomSheetView = GetCollateralLandingBottomSheetView
    
    typealias Factory = GetCollateralLandingFactory
    typealias State = GetCollateralLandingDomain.State
    typealias Event = GetCollateralLandingDomain.Event
}

// MARK: - Previews

struct GetCollateralLandingView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingView(
            state: .init(product: .carStub),
            event: { print($0) },
            factory: Factory.preview
        )
        .previewDisplayName("Product with calculator")

        let periodBottomSheet = State.BottomSheet(sheetType: .periods(carStub.calc.rates))
        
        GetCollateralLandingView(
            state: .init(bottomSheet: periodBottomSheet, product: .carStub),
            event: { print($0) },
            factory: Factory.preview
        )
        .previewDisplayName("Product period selector")
        
        let collateralBottomSheet = State.BottomSheet(sheetType: .collaterals(carStub.calc.collaterals))

        GetCollateralLandingView(
            state: .init(bottomSheet: collateralBottomSheet, product: .carStub),
            event: { print($0) },
            factory: Factory.preview
        )
        .previewDisplayName("Product collateral selector")
    }

    static let carStub = GetCollateralLandingProduct.carStub

    typealias State = GetCollateralLandingDomain.State
    typealias Factory = GetCollateralLandingFactory
}
