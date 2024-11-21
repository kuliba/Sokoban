//
//  ContentView.swift
//  CollateralLoanLandingPreview
//
//  Created by Valentin Ozerov on 05.11.2024.
//

import SwiftUI
import UIPrimitives
import RxViewModel
import RemoteServices
import CollateralLoanLandingShowCaseUI

struct ContentView: View {
    
    @StateObject var model: ContentViewDomain.Flow
        
    var body: some View {
        NavigationView {
            Button {
                model.event(.select(.showcase))
            } label: {
                Label("Show all products", systemImage: "qrcode.viewfinder")
                    .imageScale(.large)
            }
            .navigationDestination(
                destination: model.state.navigation,
                dismiss: { model.event(.dismiss) },
                content: { sheet in
                
                    switch sheet {
                        
                    case let .showcase(picker):
                        productsView(picker)
                    }
                }
            )
        }
    }
    
    private func productsView(_ picker: CollaterlLoanPicker) -> some View {
        
        RxWrapperView(
            model: picker,
            makeContentView: { state, event in
                
                Group {
                    
                    if state.isLoading {
                        
                        ProgressView()
                    } else {
                    
                        ScrollView {
                            ForEach(state.elements) {
                                
                                productView(product: $0.element)
                            }
                        }
                    }
                }
                .onFirstAppear {
                    event(.load)
                }
            })
    }
    
    func productView(product: Product) -> some View {
        
        let factory = CollateralLoanLandingShowCaseViewFactory()
        
        return factory.makeView(with: product)
    }

    typealias Product = CollateralLoanLandingShowCaseData.Product
}

extension ContentViewNavigation: Identifiable {

    var id: ID {
        switch self {
            
        case .showcase:
            return .showcase
        }
    }

    enum ID: Hashable { case showcase }
}
