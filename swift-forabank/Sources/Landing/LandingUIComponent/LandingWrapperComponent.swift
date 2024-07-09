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
    
    private var bindings = Set<AnyCancellable>()
    private var landingActions: (LandingEvent) -> Void
    let makeIconView: LandingView.MakeIconView

    let config: UILanding.Component.Config
    
    public init(
        initialState: State = .success(nil),
        statePublisher: StatePublisher,
        imagePublisher: ImagePublisher,
        imageLoader: @escaping ImageLoader,
        makeIconView: @escaping LandingView.MakeIconView,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        config: UILanding.Component.Config,
        landingActions: @escaping (LandingEvent) -> Void
    ) {
        self.state = initialState
        self.landingActions = landingActions
        self.config = config
        self.makeIconView = makeIconView
        
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
        result: State,
        imagePublisher: ImagePublisher,
        imageLoader: @escaping ImageLoader,
        makeIconView: @escaping LandingView.MakeIconView,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        config: UILanding.Component.Config,
        landingActions: @escaping (LandingEvent) -> Void
    ) {
        self.state = result
        self.landingActions = landingActions
        self.config = config
        self.makeIconView = makeIconView
        
        let landing = try? result.get()
        
        requests = landing?.imageRequests() ?? []
        
        imagePublisher
            .receive(on: scheduler)
            .sink { [weak self] in
                
                self?.images = $0
            }
            .store(in: &bindings)
        
        if case let .success(.some(landing)) = result {
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
        }
    }
    
    public struct Error: Swift.Error, Equatable {
        
        public let message: String
        
        public init(message: String) {
            self.message = message
        }
    }
}

public struct LandingWrapperView: View {
        
    @ObservedObject private var viewModel: LandingWrapperViewModel
    
    public init(viewModel: LandingWrapperViewModel) {
        
        self.viewModel = viewModel
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
                viewModel.config
            )
        }
    }
    
    private func landingUIView(
        _ landing: UILanding,
        _ images: [String: Image],
        _ config: UILanding.Component.Config
    ) -> LandingView {
        .init(
            viewModel: .init(landing: landing, config: config),
            images: images,
            action: viewModel.action,
            makeIconView: viewModel.makeIconView
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
                    makeIconView: { _ in .init(
                        image: .flag,
                        publisher: Just(.percent).eraseToAnyPublisher()
                    )}, 
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
                    makeIconView: { _ in .init(
                        image: .flag,
                        publisher: Just(.percent).eraseToAnyPublisher()
                    )},
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
