//
//  LandingUIView.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import SwiftUI

public struct LandingUIView: View {
    
    @ObservedObject private var viewModel: LandingViewModel
    
    private let landing: Landing
    private let action: (LandingAction) -> Void
    private let openURL: (URL) -> Void
    
    /// - Warning: Do not forget to wrap in `NavigationView`!
    public init(
        viewModel: LandingViewModel,
        landing: Landing,
        action: @escaping (LandingAction) -> Void,
        openURL: @escaping (URL) -> Void
    ) {
        self.viewModel = viewModel
        self.landing = landing
        self.action = action
        self.openURL = openURL
    }
    
    public var body: some View {
        
        VStack {
            
            ForEach(landing.header, content: itemView)
            
            ScrollView {
                
                ForEach(landing.main, content: itemView)
                
                ForEach(landing.footer, content: itemView)
            }
        }
        .animation(.default, value: viewModel.destination)
        .background(
            NavigationLink(
                "",
                destination: destinationView(),
                isActive: .init(
                    get: { viewModel.destination != nil },
                    set: { if !$0 { viewModel.setDestination(to: nil) }}
                )
            )
        )
    }
    
    private func itemView(
        component: LandingComponent
    ) -> some View {
        
        LandingComponentVew(
            component: component,
            selectDetail: viewModel.selectDetail
        )
    }
    
    private func destinationView() -> some View {
        
        viewModel.destination.map(destinationView)
    }
    
    @ViewBuilder
    private func destinationView(
        destination: LandingViewModel.Destination
    ) -> some View {
        
        switch destination {
        case let .detail(detail):
            Text("Here is a Detail View for \(detail.viewID.rawValue)/\(detail.viewID.rawValue)")
        }
    }
}

extension LandingUIView {
    
    struct LandingComponentVew: View {
        
        let component: LandingComponent
        let selectDetail: (Detail) -> Void
        
        var body: some View {
            
            switch component {
                
            case let .listHorizontalRoundImage(model, config):
                ListHorizontalRoundImageView(
                    model: model,
                    config: config)
                
            case let .multiLineHeader(model, config):
                MultiLineHeaderView(
                    model: model,
                    config: config)
                
            case let .multiTextsWithIconsHorizontal(model, config):
                MultiTextsWithIconsHorizontalView(
                    model: model,
                    config: config)
                
            case let .pageTitle(model, config):
                PageTitleView(
                    model: model,
                    config: config)
                
            case let .detailButton(detail):
                SelectDetailButton(
                    detail: detail,
                    selectDetail: selectDetail
                )
                
            case .textWithIconHorizontal(_):
                EmptyView()
                
            case .empty:
                EmptyView()
            }
        }
    }
}

// MARK: - Previews

struct LandingUIView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        LandingUIView(
            viewModel: .init(),
            landing: .init(
                header: .header,
                main: .main,
                footer: []
            ),
            action: { _ in },
            openURL: { _ in }
        )
    }
}
