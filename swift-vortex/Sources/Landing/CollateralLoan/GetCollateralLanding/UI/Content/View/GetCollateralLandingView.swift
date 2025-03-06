//
//  GetCollateralLandingView.swift
//
//
//  Created by Valentin Ozerov on 12.12.2024.
//

import Combine
import SwiftUI
import CollateralLoanLandingGetShowcaseUI

public struct GetCollateralLandingView<InformerPayload>: View {
    
    let state: State
    let domainEvent: (DomainEvent) -> Void
    let externalEvent: (ExternalEvent) -> Void
    let config: Config
    let factory: Factory

    public init(
        state: State,
        domainEvent: @escaping (DomainEvent) -> Void,
        externalEvent: @escaping (ExternalEvent) -> Void,
        config: Config,
        factory: Factory
    ) {
        self.state = state
        self.domainEvent = domainEvent
        self.externalEvent = externalEvent
        self.config = config
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
            .safeAreaInset(edge: .bottom, content: { footerView(product: product) })
        }
    }
        
    private var bottomSheetItem: Binding<State.BottomSheet?> {
        
    .init(
        get: { state.bottomSheet },
        set: { _ in })
    }

    func backgroundImageView(product: Product) -> some View {
        
        VStack {
            
            factory.makeImageViewWithURL(product.marketing.image)
                .scaledToFit()
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .ignoresSafeArea(edges: .all)
    }

    private func contentView(product: Product) -> some View {
        
        VStack {
            
            HeaderView(config: config)
            
            product.conditions.nilIfEmpty.map { _ in
                
                ConditionsView(
                    product: product,
                    config: config,
                    makeImageViewWithMD5Hash: factory.makeImageViewWithMD5Hash
                )
            }
            
            CalculatorView(
                state: state,
                product: product,
                config: config,
                domainEvent: domainEvent,
                externalEvent: externalEvent
            )
            
            product.faq.nilIfEmpty.map { _ in

                FaqView(product: product, config: config)
            }

            product.documents.nilIfEmpty.map { _ in

                DocumentsView(
                    product: product,
                    config: config, 
                    externalEvent: externalEvent,
                    factory: factory
                )
            }
        }
        .background(Color.clear)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.bottom, config.paddings.outerBottom)
        .ignoresSafeArea(edges: .all)
    }
    
    private func footerView(product: Product) -> some View {
        
        FooterView(
            product: product,
            config: config.footer,
            state: state,
            externalEvent: externalEvent
        )
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
    
    public typealias Config = GetCollateralLandingConfig
    public typealias Factory = GetCollateralLandingFactory
    public typealias State = GetCollateralLandingDomain.State<InformerPayload>
    public typealias ExternalEvent = GetCollateralLandingDomain.ExternalEvent
    public typealias DomainEvent = GetCollateralLandingDomain.Event<InformerPayload>
}

// MARK: - Previews

struct GetCollateralLandingView_Previews<InformerPayload>: PreviewProvider {
    
    static var previews: some View {
        
        GetCollateralLandingView<InformerPayload>(
            state: .init(
                landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE",
                formatCurrency: { _ in "" }
            ),
            domainEvent: { print($0) },
            externalEvent: {
                print($0)
            },
            config: .preview,
            factory: Factory.preview
        )
        .previewDisplayName("Product with calculator")

        let periodBottomSheet = State.BottomSheet(sheetType: .periods([]))
        
        GetCollateralLandingView(
            state: .init(
                landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE",
                bottomSheet: periodBottomSheet,
                formatCurrency: { _ in "" }
            ),
            domainEvent: { print($0) },
            externalEvent: {
                print($0)
            },
            config: .preview,
            factory: Factory.preview
        )
        .previewDisplayName("Product period selector")
        
        let collateralBottomSheet = State.BottomSheet(sheetType: .collaterals([]))

        GetCollateralLandingView(
            state: .init(
                landingID: "COLLATERAL_LOAN_CALC_REAL_ESTATE",
                bottomSheet: collateralBottomSheet,
                formatCurrency: { _ in "" }
            ),
            domainEvent: {
                print($0)
            },
            externalEvent: { print($0) },
            config: .preview,
            factory: Factory.preview
        )
        .previewDisplayName("Product collateral selector")
    }

    static var carStub: GetCollateralLandingProduct { .carStub }

    typealias State = GetCollateralLandingDomain.State<InformerPayload>
    typealias Factory = GetCollateralLandingFactory
}
