//
//  LandingUIView.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Combine
import SwiftUI

public struct LandingView: View {
    
    @StateObject private var viewModel: LandingViewModel
    @State private var position: CGFloat = 0
    @State private var scrollViewContentSize: CGSize = .zero
    
    private let action: (LandingAction) -> Void
    private let openURL: (URL) -> Void
    private let images: [String: Image]
    
    public init(
        viewModel: LandingViewModel,
        images: [String: Image],
        action: @escaping (LandingAction) -> Void,
        openURL: @escaping (URL) -> Void
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.images = images
        self.action = action
        self.openURL = openURL
    }
    
    struct ViewOffsetKey: PreferenceKey {
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }
    
    var backButton : some View {
        
        Button(action: {
            action(.goToMain)
        }) { Image(systemName: "chevron.backward") }
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 0) { componentsView(viewModel.landing.main) }
                    .background(
                        GeometryReader {
                            Color.clear.preference(
                                key: ViewOffsetKey.self,
                                value: -$0.frame(in: .named("scroll")).origin.y)
                        }
                    )
                    .onPreferenceChange(ViewOffsetKey.self) {
                        position = $0
                    }
            }
            .coordinateSpace(name: "scroll")
            
            componentsView(viewModel.landing.footer)
        }
        .bottomSheet(
            item: .init(
                get: { viewModel.destination },
                set: viewModel.setDestination(to:)
            ),
            content: destinationView)
        .navigationBarTitle(
            viewModel.landing.navigationTitle(
                offset: position,
                offsetForDisplayHeader: viewModel.config.offsetForDisplayHeader),
            displayMode: .inline)
        .navigationBarItems(leading: backButton)
    }
    
    private func componentsView(
        _ components: [UILanding.Component]
    ) -> some View {
        
        ForEach(components, content: itemView)
    }
    
    private func orderCard(
        _ tarif: Int,
        _ type: Int
    ) {
        
        viewModel.selectDetail(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            
            action(.orderCard(cardTarif: tarif, cardType: type))
        }
    }

    
    private func itemView(
        component: UILanding.Component
    ) -> some View {
        
        return LandingComponentView(
            component: component,
            images: images,
            config: viewModel.config,
            selectDetail: viewModel.selectDetail,
            action: action,
            orderCard: orderCard
        )
    }
    
    @ViewBuilder
    private func destinationView(
        destination: LandingViewModel.Destination
    ) -> some View {
        
        switch destination {
        case let .detail(components):
            
            ScrollView {
                VStack(spacing: 0) { componentsView(components) }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                scrollViewContentSize = geo.size
                            }
                            return Color.clear
                        }
                    )
            }
            .frame(
                maxHeight: scrollViewContentSize.height
            )
            .transition(.move(edge: .bottom))
        }
    }
}

extension LandingView {
    
    struct LandingComponentView: View {
        
        let component: UILanding.Component
        let images: [String: Image]
        let config: UILanding.Component.Config
        let selectDetail: (DetailDestination?) -> Void
        let action: (LandingAction) -> Void
        let orderCard: (Int, Int) -> Void
        
        var body: some View {
            
            switch component {
                
            case let .list(.horizontalRoundImage(model)):
                ListHorizontalRoundImageView(
                    model: .init(data: model, images: images),
                    config: config.listHorizontalRoundImage,
                    selectDetail: selectDetail
                )
                
            case let .multi(.lineHeader(model)):
                MultiLineHeaderView(
                    model: model,
                    config: config.multiLineHeader)
                
            case let .multi(.textsWithIconsHorizontal(model)):
                MultiTextsWithIconsHorizontalView(
                    model: .init(data: model, images: images),
                    config: config.multiTextsWithIconsHorizontal)
                
                // заголовок отображается в navBar !!!
            case .pageTitle:
                EmptyView()
                
            case let .multi(.texts(model)):
                UILanding.Multi.TextsView(
                    model: model,
                    config: config.multiTexts)
                
            case let .verticalSpacing(model):
                VerticalSpacingView(model: model, config: config.verticalSpacing)
                
            case let .image(model):
                ImageView(model: .init(data: model, images: images), config: config.image)
                
            case let .list(.dropDownTexts(model)):
                ListDropdownTextsUIView(model: model, config: config.listDropDownTexts)
                
            case let .iconWithTwoTextLines(model):
                IconWithTwoTextLinesView(
                    model: .init(data: model, images: images),
                    config: config.iconWithTwoTextLines)
                
            case let .list(.verticalRoundImage(model)):
                ListVerticalRoundImageView(
                    model: .init(
                        data: model,
                        images: images,
                        selectDetail: selectDetail
                    ),
                    config: config.listVerticalRoundImage)
                
            case let .multi(.buttons(model)):
                MultiButtonsView(
                    model: .init(
                        data: model,
                        selectDetail: selectDetail,
                        action: action),
                    config: config.multiButtons)
                
            case let .textWithIconHorizontal(model):
                TextsWithIconHorizontalView(
                    model: .init(data: model, images: images),
                    config: config.textWithIconHorizontal)
                
            case let .imageSvg(model):
                ImageSvg(
                    model: .init(data: model, images: images),
                    config: config.imageSvg)
                
            case let .list(.horizontalRectangleImage(model)):
                ListHorizontalRectangleImageView(
                    model: .init(
                        data: model,
                        images: images),
                    config: config.listHorizontalRectangleImage,
                    selectDetail: selectDetail)
                
            case let .multi(.typeButtons(model)):
                MultiTypeButtonsView(
                    
                    model: .init(
                        data: model,
                        images: images,
                        selectDetail: selectDetail,
                        action: action,
                        orderCard: orderCard
                    ),
                    config: config.multiTypeButtons)
                
            case let .multi(.markersText(model)):
                MultiMarkersTextView(model: model, config: config.multiMarkersText)
            }
        }
    }
}

// MARK: - Previews

struct LandingUIView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        LandingView(
            viewModel: .init(
                landing: .init(
                    header: .header,
                    main: .main,
                    footer: .footer,
                    details: []
                ),
                config: .defaultValue
            ),
            images: .defaultValue,
            action: { _ in },
            openURL: { _ in }
        )
    }
}
