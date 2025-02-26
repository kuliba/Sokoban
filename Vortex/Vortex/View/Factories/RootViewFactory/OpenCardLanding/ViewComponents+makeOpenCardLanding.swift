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
        landing: OrderCardLanding,
        continue: @escaping () -> Void,
        dismiss: @escaping () -> Void
    ) -> some View {
        
        DismissibleScrollView(
            title: { $0 > 0 ? landing.header.title : "" },
            dismiss: dismiss
        ) {
            makeOrderCardLandingContentView(landing: landing)
        }
        .safeAreaInset(edge: .bottom) {
            
            heroButton(action: `continue`)
        }
    }
    
    @inlinable
    @ViewBuilder
    func makeOrderCardLandingContentView(
        landing: OrderCardLanding
    ) -> some View {
       
        ScrollView {
            
            LazyVStack(spacing: 16) {
                
                HeaderView(
                    header: landing.header,
                    config: .iVortex,
                    imageFactory: .init(makeIconView: makeIconView)
                )
                
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
            .padding(.bottom, 25)
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
