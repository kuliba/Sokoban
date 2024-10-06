//
//  LandingWrapperView.swift
//  ForaBank
//
//  Created by Igor Malyarov on 08.09.2023.
//

import Combine
import CombineSchedulers
import SwiftUI

public final class LandingWrapperViewModel: ObservableObject {
    
    public typealias Images = [String: Image]
    public typealias ImagePublisher = AnyPublisher<Images, Never>
    public typealias ImageLoader = ([ImageRequest]) -> Void
    
    public typealias State = Result<UILanding?, Error>
    public typealias StatePublisher = AnyPublisher<State, Never>
    
    @Published public private(set) var state: State
    
    @Published private(set) var images: Images = .init()
    @Published var requests: [ImageRequest] = .init()
    
    public var limitsViewModel: ListHorizontalRectangleLimitsViewModel?
    
    private var bindings = Set<AnyCancellable>()
    private var landingActions: (LandingEvent) -> Void
    let viewFactory: ViewFactory
    
    let config: UILanding.Component.Config
    
    var cardLimitsInfo: CardLimitsInfo?
    var newLimitsValue: [BlockHorizontalRectangularEvent.Limit] = []
    
    public init(
        initialState: State = .success(nil),
        statePublisher: StatePublisher,
        imagePublisher: ImagePublisher,
        imageLoader: @escaping ImageLoader,
        viewFactory: ViewFactory,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        config: UILanding.Component.Config,
        landingActions: @escaping (LandingEvent) -> Void
    ) {
        self.state = initialState
        self.landingActions = landingActions
        self.config = config
        self.viewFactory = viewFactory
        
        let landing = try? initialState.get()
        
        requests = landing?.imageRequests() ?? []
        
        imagePublisher
            .receive(on: scheduler)
            .sink { [weak self] in
                
                self?.images = $0
            }
            .store(in: &bindings)
        
        statePublisher
            .removeDuplicates()
            .receive(on: scheduler)
            .sink { [weak self] result in
                
                if case let .success(.some(landing)) = result {
                    self?.requests = landing.imageRequests()
                }
                imageLoader(self?.requests ?? [])
                self?.state = result
            }
            .store(in: &bindings)
    }
    
    public init(
        initialState: State,
        imagePublisher: ImagePublisher,
        imageLoader: @escaping ImageLoader,
        viewFactory: ViewFactory,
        limitsViewModel: ListHorizontalRectangleLimitsViewModel?,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        config: UILanding.Component.Config,
        landingActions: @escaping (LandingEvent) -> Void
    ) {
        self.state = initialState
        self.landingActions = landingActions
        self.config = config
        self.viewFactory = viewFactory
        self.limitsViewModel = limitsViewModel
        
        let landing = try? initialState.get()
        
        requests = landing?.imageRequests() ?? []
        
        imagePublisher
            .receive(on: scheduler)
            .sink { [weak self] in
                
                self?.images = $0
            }
            .store(in: &bindings)
        
        if case let .success(.some(landing)) = initialState {
            requests = landing.imageRequests()
            imageLoader(requests)
        }
    }

    public func action(_ action: LandingEvent) {
        
        switch action {
            
        case .card(let card):
            switch card {
            case .goToMain:
                self.landingActions(.card(.goToMain))
                
            case let .openUrl(link):
                self.landingActions(.card(.openUrl(link)))
                
            case .order(cardTarif: let cardTarif, cardType: let cardType):
                self.landingActions(.card(.order(cardTarif: cardTarif, cardType: cardType)))
            }
            
        case .sticker(let sticker):
            switch sticker {
                
            case .goToMain:
                self.landingActions(.sticker(.goToMain))
            case .order:
                self.landingActions(.sticker(.order))
            }
            
        case let .bannerAction(bannerAction):
            switch bannerAction {
            case let .contact(contact):
                self.landingActions(.bannerAction(.contact(contact)))
                
            case .depositsList:
                self.landingActions(.bannerAction(.depositsList))
                
            case .depositTransfer:
                self.landingActions(.bannerAction(.depositTransfer))
                
            case .landing:
                self.landingActions(.bannerAction(.landing))
                
            case .migAuthTransfer:
                self.landingActions(.bannerAction(.migAuthTransfer))
                
            case let .migTransfer(country):
                self.landingActions(.bannerAction(.migTransfer(country)))
                
            case let .openDeposit(deposit):
                self.landingActions(.bannerAction(.openDeposit(deposit)))
            }
            
        case let .listVerticalRoundImageAction(action):
            self.landingActions(.listVerticalRoundImageAction(action))
        }
    }
    
    public struct Error: Swift.Error, Equatable {
        
        public let message: String
        
        public init(message: String) {
            self.message = message
        }
    }
    
    // TODO: change after refactoring
    
    public func updateCardLimitsInfo(_ newValue: CardLimitsInfo?) {
        cardLimitsInfo = newValue
    }
}

public extension LandingWrapperViewModel {
    
    func navigationTitle() -> String {
        
        if case let .success(landing) = state {
            if let landing {
                return landing.headerTitle()
            }
        }
        return ""
    }
}

public struct LandingWrapperView: View {
     
    public typealias UpdateSaveButtonAction = () -> Void
    
    @ObservedObject private var viewModel: LandingWrapperViewModel
    private let updateSaveButtonAction: UpdateSaveButtonAction?
    
    public init(
        viewModel: LandingWrapperViewModel,
        updateSaveButtonAction: UpdateSaveButtonAction? = nil
    ) {
        self.viewModel = viewModel
        self.updateSaveButtonAction = updateSaveButtonAction
    }
    
    @ViewBuilder
    public var body: some View {
        
        switch viewModel.state {
            
        case .success(.none), .failure:
            PlaceholderView(
                config: .defaultValue,
                action: viewModel.action
            )
            
        case let .success(.some(landing)):
            landingUIView(
                landing,
                viewModel.images,
                viewModel.config,
                viewModel.cardLimitsInfo,
                {
                    viewModel.newLimitsValue.updateOrAddLimit($0)
                    if let updateSaveButtonAction { updateSaveButtonAction() }
                },
                { 
                    return viewModel.newLimitsValue
                }
            )
        }
    }
    
    private func landingUIView(
        _ landing: UILanding,
        _ images: [String: Image],
        _ config: UILanding.Component.Config,
        _ cardLimitsInfo: CardLimitsInfo?,
        _ limitIsChanged: @escaping (BlockHorizontalRectangularEvent.Limit) -> Void,
        _ newLimits: @escaping () -> [BlockHorizontalRectangularEvent.Limit]
    ) -> LandingView {
        .init(
            viewModel: .init(landing: landing, config: config),
            images: images,
            action: viewModel.action,
            viewFactory: viewModel.viewFactory,
            limitsViewModel: viewModel.limitsViewModel,
            cardLimitsInfo: cardLimitsInfo, 
            limitIsChanged: limitIsChanged,
            newLimits: newLimits
        )
    }
}

// MARK: - Preview Content

struct LandingWrapperView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            LandingWrapperView(
                viewModel: .init(
                    statePublisher: Just(.failure(.preview)).eraseToAnyPublisher(),
                    imagePublisher: imagePublisher,
                    imageLoader: { _ in },
                    viewFactory: .default,
                    scheduler: .immediate,
                    config: .defaultValue,
                    landingActions: { _ in }
                )
            )
            
            LandingWrapperView(
                viewModel: .init(
                    statePublisher: Just(.success(.preview)).eraseToAnyPublisher(),
                    imagePublisher: imagePublisher,
                    imageLoader: { _ in },
                    viewFactory: .default,
                    scheduler: .immediate,
                    config: .defaultValue,
                    landingActions: { _ in }
                )
            )
            /* ZStack {
                 LandingWrapperView(
                     viewModel: .init(
                         initialState: .success((.preview, .detail(.init(groupID: "a", viewID: "1")))),
                         statePublisher: Just(.success(.preview))
                             .delay(for: 3, scheduler: DispatchQueue.main)
                             .eraseToAnyPublisher(),
                         imagePublisher: imagePublisher,
                         scheduler: .immediate
                     )
                 )
                    
                 Text("TBD: navigate to detail programmatically")
                     .foregroundColor(.red)
             }*/
        }
        
    }
    
    static let imagePublisher: LandingWrapperViewModel.ImagePublisher = {
        
        return Just(["1": Image.bolt])
            .eraseToAnyPublisher()
    }()
    
}

private extension LandingWrapperViewModel.Error {
    
    static let preview: Self = .init(message: "Landing has not been loaded.")
}

public extension UILanding {
    
    static let preview: Self = .defaultLanding
}

extension UILanding {
    
    func imageRequests() -> [ImageRequest] {
        
        let headerImages = self.header.flatMap { $0.imageRequests() }
        let main = self.main.flatMap { $0.imageRequests() }
        let footer = self.footer.flatMap { $0.imageRequests() }
        let details = self.details.flatMap { $0.dataGroup.flatMap { $0.dataView.flatMap { $0.imageRequests() }}}
        return headerImages + main + footer + details
    }
}
