//
//  ViewComponents+makeOpenCardLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 24.02.2025.
//

import DropDownTextListComponent
import HeaderLandingComponent
import ListLandingComponent
import RxViewModel
import SwiftUI
import UIPrimitives
import OrderCardLandingComponent

extension ViewComponents {
    
    @inlinable
    func makeOrderCardLandingView(
        binder: OrderCardLandingDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        OffsetObservingScrollWithModelView(refresh: {
            binder.content.event(.load)
        }) { offset in
            
            RxWrapperView(model: binder.content) { state, event in
                
                makeOrderCardLandingContentView(
                    landing: state.landing,
                    offset: offset
                )
                .navigationBarWithBack(
                    title: offset.wrappedValue.y > 0 ? (state.landing?.header.navTitle ?? "") : "",
                    subtitle: offset.wrappedValue.y > 0 ? (state.landing?.header.navSubtitle ?? "") : "",
                    subtitleForegroundColor: .textPlaceholder,
                    dismiss: dismiss
                )
            }
        }
        .conditionalBottomPadding()
        .safeAreaInset(edge: .bottom) {
            
            heroButton { binder.flow.event(.select(.continue)) }
                .frame(maxWidth: .infinity)
                .background(.white)
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeOrderCardLandingContentView(
        landing: OrderCardLanding?,
        offset: Binding<CGPoint>
    ) -> some View {
        
        if let landing {
            
            OffsetObservingScrollView(
                axes: .vertical,
                showsIndicators: false,
                offset: offset,
                coordinateSpaceName: "coordinateSpaceName"
            ) {
                VStack(spacing: 16) {
                    
                    HeaderView(
                        header: landing.header,
                        config: .iVortex,
                        imageFactory: .init(makeBannerImageView: makeGeneralIconView)
                    )
                    .edgesIgnoringSafeArea(.top)
                    
                    VStack {
                        
                        ListLandingComponent.List(
                            items: landing.conditions,
                            config: .iVortex,
                            factory: .init(
                                makeIconView: makeIconView,
                                makeBannerImageView: makeGeneralIconView
                            )
                        )
                        
                        ListLandingComponent.List(
                            items: landing.security,
                            config: .iVortex,
                            factory: .init(
                                makeIconView: makeIconView,
                                makeBannerImageView: makeGeneralIconView
                            )
                        )
                        
                        DropDownTextListView(
                            config: .default,
                            list: landing.dropDownList
                        )
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 16)
                }
            }
        } else {
            
            Rectangle()
                .fill(.gray.opacity(0.6))
                .frame(height: UIScreen.main.bounds.height)
                .frame(maxWidth: .infinity)
                .shimmering()
        }
    }
    
    @inlinable
    func heroButton(
        title: String = "Продолжить",
        style: ButtonSimpleView.ViewModel.ButtonStyle = .red,
        action: @escaping () -> Void
    ) -> some View {
        
        ButtonSimpleView(
            viewModel: .init(
                title: title,
                style: .red,
                action: action
            )
        )
        .frame(height: 48)
        .padding()
    }
}

extension LandingState<OrderCardLandingComponent.OrderCardLanding> {

    var landing: OrderCardLanding? {
        
        guard !isLoading else { return nil }
        
        switch status {
        case let .landing(landing),
             let .mix(landing, _):
            return landing
            
        default:
            return nil
        }
    }
}
