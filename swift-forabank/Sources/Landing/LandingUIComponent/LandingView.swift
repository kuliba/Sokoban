//
//  LandingUIView.swift
//  
//
//  Created by Andryusina Nataly on 02.09.2023.
//

import Combine
import SwiftUI
import UIPrimitives
import BottomSheetComponent

// MARK: - for preview app

public struct LandingView: View {
    
    @StateObject private var viewModel: LandingViewModel
    @State private(set) var isShowHeader = false

    @State private var scrollViewContentSize: CGSize = .zero
    
    private let action: (LandingEvent) -> Void
    private let images: [String: Image]
    private let imageViewFactory: ImageViewFactory
    private let carouselViewFactory: CarouselViewFactory?
    private let makeLimit: MakeLimit
    private var limitsViewModel: ListHorizontalRectangleLimitsViewModel?
    private let cardLimitsInfo: CardLimitsInfo?
    private let limitIsChanged: (BlockHorizontalRectangularEvent.Limit) -> Void
    private let newLimits: () -> [BlockHorizontalRectangularEvent.Limit]

    public init(
        viewModel: LandingViewModel,
        images: [String: Image],
        action: @escaping (LandingEvent) -> Void,
        imageViewFactory: ImageViewFactory,
        carouselViewFactory: CarouselViewFactory? = nil,
        makeLimit: @escaping MakeLimit = { _ in nil },
        limitsViewModel: ListHorizontalRectangleLimitsViewModel?,
        cardLimitsInfo: CardLimitsInfo?,
        limitIsChanged: @escaping (BlockHorizontalRectangularEvent.Limit) -> Void,
        newLimits: @escaping () -> [BlockHorizontalRectangularEvent.Limit]
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.images = images
        self.action = action
        self.imageViewFactory = imageViewFactory
        self.carouselViewFactory = carouselViewFactory
        self.makeLimit = makeLimit
        self.limitsViewModel = limitsViewModel
        self.cardLimitsInfo = cardLimitsInfo
        self.limitIsChanged = limitIsChanged
        self.newLimits = newLimits
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
            action(.goToBack)
        }) { Image(systemName: "chevron.backward") }
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 0) {
                    
                    componentsView(viewModel.landing.main)
                }
                .background(
                    GeometryReader {
                        Color.clear.preference(
                            key: ViewOffsetKey.self,
                            value: -$0.frame(in: .named("scroll")).origin.y)
                    }
                )
            }
            .onPreferenceChange(ViewOffsetKey.self) { value in
                isShowHeader = value > viewModel.config.offsetForDisplayHeader
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
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                header()
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private func header() -> some View {
         
        
        if viewModel.landing.shouldShowNavigationTitle(
            isShowHeader) {
            
            componentsView(viewModel.landing.header)
        } else {
            
            VStack {
                
                let pageTitle = viewModel.landing.titleInMain()
                
                pageTitle.text.text(withConfig: viewModel.config.pageTitle.title)
                
                pageTitle.subTitle.map {
                    $0.text(withConfig: viewModel.config.pageTitle.subtitle)
                }
            }
        }
    }
    
    private func componentsView(
        _ components: [UILanding.Component]
    ) -> some View {
        
        ForEach(components, id: \.id, content: itemView)
    }
    
    private func orderCard(
        _ tarif: Int,
        _ type: Int
    ) {
        
        viewModel.selectDetail(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            
            action(.card(.order(cardTarif: tarif, cardType: type)))
        }
    }
    
    
    @ViewBuilder
    private func itemView(
        component: UILanding.Component
    ) -> some View {
        
        let landingView = LandingComponentView(
            cardLimitsInfo: cardLimitsInfo, 
            component: component,
            images: images,
            config: viewModel.config,
            selectDetail: viewModel.selectDetail,
            action: action,
            orderCard: orderCard,
            imageViewFactory: imageViewFactory, 
            carouselViewFactory: carouselViewFactory,
            makeLimit: makeLimit,
            canOpenDetail: {
                return viewModel.landing.components(g: $0.groupID.rawValue, v: $0.viewID.rawValue) != []
            }, 
            limitsViewModel: limitsViewModel,
            limitIsChanged: limitIsChanged,
            newLimits: newLimits
        )
        
        switch component {
            
        case .pageTitle:
            
            if !viewModel.landing.titleInMain().text.isEmpty {
               EmptyView()
            } else {
                landingView
            }
            
        default:
            landingView
        }
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
        
        let cardLimitsInfo: CardLimitsInfo?
        let component: UILanding.Component
        let images: [String: Image]
        let config: UILanding.Component.Config
        let selectDetail: (DetailDestination?) -> Void
        let action: (LandingEvent) -> Void
        let orderCard: (Int, Int) -> Void
        let imageViewFactory: ImageViewFactory
        let carouselViewFactory: CarouselViewFactory?
        let makeLimit: MakeLimit
        let canOpenDetail: UILanding.CanOpenDetail
        let limitsViewModel: ListHorizontalRectangleLimitsViewModel?
        let limitIsChanged: (BlockHorizontalRectangularEvent.Limit) -> Void
        let newLimits: () -> [BlockHorizontalRectangularEvent.Limit]

        var body: some View {
            makeContentView()
        }
        
        @ViewBuilder
        func makeContentView() -> some View {
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
                
            case .pageTitle(let model):
                PageTitleView(model: model, config: config.pageTitle)
                
            case let .multi(.texts(model)):
                UILanding.Multi.TextsView(
                    model: model,
                    config: config.multiTexts)
                
            case let .verticalSpacing(model):
                VerticalSpacingView(model: model, config: config.verticalSpacing)
            case let .spacing(model):
                SpacingView(model: model, config: config.spacing)
                
            case let .image(model):
                ImageView(model: .init(data: model, images: images), config: config.image, factory: imageViewFactory)
                
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
                        action: action,
                        selectDetail: selectDetail,
                        canOpenDetail: canOpenDetail
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
                        images: images,
                        action: action,
                        selectDetail: selectDetail,
                        canOpenDetail: canOpenDetail
                    ),
                    config: config.listHorizontalRectangleImage
                )
                
            case let .list(.horizontalRectangleLimits(state)):
                
                if let limitsViewModel {
                    ListHorizontalRectangleLimitsWrappedView(
                        model: limitsViewModel,
                        factory: imageViewFactory,
                        config: config.listHorizontalRectangleLimits)
                }
                else {
                    ListHorizontalRectangleLimitsWrappedView(
                        model: .init(
                            initialState: state,
                            reduce: {state,_ in (state, .none)},
                            handleEffect: {_,_ in }
                        ),
                        factory: imageViewFactory,
                        config: config.listHorizontalRectangleLimits)
                }
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
                
            case let .blockHorizontalRectangular(block):
                // TODO: add reduce, handleEffect
                
                BlockHorizontalRectangularWrappedView(
                    viewModel: .init(
                        initialState: .init(
                            block: block,
                            initialLimitsInfo: cardLimitsInfo
                        ),
                        reduce: BlockHorizontalRectangularReducer(limitIsChanged: limitIsChanged).reduce(_:_:),
                        handleEffect: {_,_ in }),
                    factory: imageViewFactory,
                    config: config.blockHorizontalRectangular)
                
            case let .carousel(.base(model)):
                if let carouselViewFactory { carouselViewFactory.makeCarouselBaseView(model)
                }
                
            case let .carousel(.withTabs(model)):
                if let carouselViewFactory { carouselViewFactory.makeCarouselWithTabsView(model)
                }

            case let .carousel(.withDots(model)):
                if let carouselViewFactory { carouselViewFactory.makeCarouselWithDotsView(model)
                }
            }
        }
    }
}

public extension LandingView {
    
    typealias MakeIconView = (String) -> IconView
    typealias IconView = UIPrimitives.AsyncImage
    
    typealias MakeLimit = (String) -> LimitValues?
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
            imageViewFactory: .default,
            makeLimit: { _ in nil },
            limitsViewModel: nil, 
            cardLimitsInfo: .init(type: "", svCardLimits: nil, editEnable: true),
            limitIsChanged: { _ in }, 
            newLimits: { [] }
        )
    }
}
