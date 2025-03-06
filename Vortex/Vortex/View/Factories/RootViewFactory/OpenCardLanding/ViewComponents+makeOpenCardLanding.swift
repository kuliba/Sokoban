//
//  ViewComponents+makeOpenCardLanding.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 24.02.2025.
//

import DropDownTextListComponent
import ListLandingComponent
import HeaderLandingComponent
import SwiftUI
import UIPrimitives

public struct OrderCardLanding {
    
    let header: Header
    let conditions: ListLandingComponent.Items
    let security: ListLandingComponent.Items
    let dropDownList: DropDownTextList
    
    public init(
        header: Header,
        conditions: ListLandingComponent.Items,
        security: ListLandingComponent.Items,
        dropDownList: DropDownTextList
    ) {
        self.header = header
        self.conditions = conditions
        self.security = security
        self.dropDownList = dropDownList
    }
}

extension ViewComponents {
    
    @inlinable
    func makeOrderCardLandingView(
        binder: OrderCardLandingDomain.Binder,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        OffsetObservingScrollWithModelView(refresh: {
            //TODO: create binder.content.event(.load)
        }) { offset in
            
            makeOrderCardLandingContentView(
                landing: binder.content,
                offset: offset
            )
            .safeAreaInset(edge: .bottom) {
                
                heroButton(action: { binder.flow.event(.select(.continue)) })
                    .frame(maxWidth: .infinity)
                    .background(.white)
            }
            .conditionalBottomPadding()
            .navigationBarWithBack(
                title: offset.wrappedValue.y > 0 ?  binder.content.header.navTitle : "",
                subtitle: offset.wrappedValue.y > 0 ?  binder.content.header.navSubtitle : "",
                subtitleForegroundColor: .textPlaceholder,
                dismiss: dismiss
            )
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeOrderCardLandingContentView(
        landing: OrderCardLanding,
        offset: Binding<CGPoint>
    ) -> some View {
        
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

//TODO: add swipe to refresh
struct DismissibleScrollView<Content: View>: View {
    
    @State private var offset: CGPoint = .zero
    
    let title: (Double) -> String
    let dismiss: () -> Void
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        
        OffsetObservingScrollView(
            axes: .vertical,
            showsIndicators: false,
            offset: $offset,
            coordinateSpaceName: "orderCardScroll",
            content: content
        )
        .navigationBarWithBack(
            title: title(offset.y),
            dismiss: dismiss
        )
    }
}
