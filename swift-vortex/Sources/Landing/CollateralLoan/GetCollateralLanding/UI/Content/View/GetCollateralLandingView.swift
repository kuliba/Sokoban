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
    let domainEvent: (DomainEvent) -> Void
    let externalEvent: (ExternalEvent) -> Void
    let factory: Factory

    public init(
        state: State,
        domainEvent: @escaping (DomainEvent) -> Void,
        externalEvent: @escaping (ExternalEvent) -> Void,
        factory: Factory
    ) {
        self.state = state
        self.domainEvent = domainEvent
        self.externalEvent = externalEvent
        self.factory = factory
    }
    
    public var body: some View {
        
        switch state.product {
        case .none:
            ProgressView()
        case let .some(product):
            
            ScrollView {
                
                ZStack {
                    
                    backgroundImageView(product: product)
                    contentView(product: product)
                }
                .background(product.getCollateralLandingTheme.backgroundColor)
            }
            .ignoresSafeArea()
        }
    }
    
    // TODO: move it to main target
//    private func bottomSheet(_ bottomSheet: State.BottomSheet) -> some View {
//        
//        switch bottomSheet.sheetType {
//        case let .periods(period):
//            return BottomSheetView(
//                items: period.map(\.bottomSheetItem),
//                config: factory.config.bottomSheet,
//                makeImageView: factory.makeImageView
//            ) {
//                switch $0 {
//                case .selectMonthPeriod(let termMonth):
//                    domainEvent(.selectMonthPeriod(termMonth))
//                default: break
//                }
//            }
//        case let .collaterals(collateral):
//            return BottomSheetView(
//                items: collateral.map(\.bottomSheetItem),
//                config: factory.config.bottomSheet,
//                makeImageView: factory.makeImageView
//            ) {
//                switch $0 {
//                case .selectCollateral(let collateral):
//                    domainEvent(.selectCollateral(collateral))
//                default: break
//                }
//            }
//        }
//    }
    
    private var bottomSheetItem: Binding<State.BottomSheet?> {
        
    .init(
        get: { state.bottomSheet },
        set: { _ in })
    }

    func backgroundImageView(product: Product) -> some View {
        
        VStack {
            
            factory.makeImageView(product.marketing.image)
                .frame(height: factory.config.backgroundImageHeight)
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .ignoresSafeArea(edges: .all)
    }

    private func contentView(product: Product) -> some View {
        
        VStack {
            
            HeaderView(config: factory.config)
            
            product.conditions.nilIfEmpty.map { _ in
                
                ConditionsView(
                    product: product,
                    config: factory.config,
                    makeImageView: factory.makeImageView
                )
            }
            
            CalculatorView(
                state: state,
                config: factory.config,
                domainEvent: domainEvent,
                externalEvent: externalEvent
            )
            
            product.faq.nilIfEmpty.map { _ in

                FaqView(product: product, config: factory.config)
            }

            product.documents.nilIfEmpty.map { _ in

                DocumentsView(
                    product: product,
                    config: factory.config,
                    makeImageView: factory.makeImageView)
            }
            
            FooterView(
                config: factory.config.footer,
                state: state,
                domainEvent: domainEvent
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
    typealias Product = GetCollateralLandingProduct
    
    public typealias Factory = GetCollateralLandingFactory
    public typealias State = GetCollateralLandingDomain.State
    public typealias ExternalEvent = GetCollateralLandingDomain.ExternalEvent
    public typealias DomainEvent = GetCollateralLandingDomain.Event
}

// MARK: - Previews

struct GetCollateralLandingView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingView(
            state: .init(
                landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE"
            ),
            domainEvent: { print($0) },
            externalEvent: {
                print($0)
            },
            factory: Factory.preview
        )
        .previewDisplayName("Product with calculator")

        let periodBottomSheet = State.BottomSheet(sheetType: .periods(carStub.calc.rates))
        
        GetCollateralLandingView(
            state: .init(
                bottomSheet: periodBottomSheet,
                landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE"
            ),
            domainEvent: { print($0) },
            externalEvent: {
                print($0)
            },
            factory: Factory.preview
        )
        .previewDisplayName("Product period selector")
        
        let collateralBottomSheet = State.BottomSheet(sheetType: .collaterals(carStub.calc.collaterals))

        GetCollateralLandingView(
            state: .init(
                bottomSheet: collateralBottomSheet,
                landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE"
            ),
            domainEvent: {
                print($0)
            },
            externalEvent: { print($0) },
            factory: Factory.preview
        )
        .previewDisplayName("Product collateral selector")
    }

    static let carStub = GetCollateralLandingProduct.carStub

    typealias State = GetCollateralLandingDomain.State
    typealias Factory = GetCollateralLandingFactory
}
