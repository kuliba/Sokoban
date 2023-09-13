//
//  AuthTransfersViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 23.11.2022.
//  Refactor by Dmitry Martynov on 26.12.2022
//

import SwiftUI
import Combine

// MARK: - ViewModel

class AuthTransfersViewModel: ObservableObject {
    
    let action: PassthroughSubject<AuthTransfersAction, Never> = .init()
    
    @Published var link: Link?    
    @Published var sections: [TransfersSectionViewModel]
    @Published var bottomSheet: BottomSheet?
    @Published var opacity: Double
    @Published var offset: Double
    @Published var title: String
    @Published var subTitle: String
    @Published var legalTitle: String

    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    let iconName = Image("Cover Auth")
    let navigation: NavigationBarView.ViewModel
    
    init(_ model: Model,
         sections: [TransfersSectionViewModel],
         opacity: Double = 1,
         offset: Double = 0,
         title: String = "",
         subTitle: String = "",
         legalTitle: String = "",
         navigation: NavigationBarView.ViewModel) {
        
        self.model = model
        self.sections = sections
        self.opacity = opacity
        self.offset = offset
        self.title = title
        self.subTitle = subTitle
        self.legalTitle = legalTitle
        self.navigation = navigation
    }
    
    convenience init(_ model: Model, closeAction: @escaping () -> Void) {
        
        let navigation: NavigationBarView.ViewModel = .init(opacity: 0, action: closeAction)
        
        self.init(model, sections: [], navigation: navigation)
        
        bind()
    }
    
    private func bind() {
        
        model.transferAbroad
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transferAbroad in
                
                guard let self else { return }
                
                guard let transferAbroad = transferAbroad else { return }
                
                title = transferAbroad.main.title
                subTitle = transferAbroad.main.subTitle
                legalTitle = transferAbroad.main.legalTitle
                
                navigation.title = "\(title) \(subTitle)"
                
                self.sections = [TransfersCoverView.ViewModel(data: transferAbroad.main.promotion),
                                 TransfersDirectionsView.ViewModel(model: model, data: transferAbroad.main.directions),
                                 TransfersInfoView.ViewModel(model, data: transferAbroad.main.info),
                                 TransfersBannersView.ViewModel(model: model, data: transferAbroad.main.bannerCatalogList),
                                 TransfersCountriesView.ViewModel(model: model, data: transferAbroad.main.countriesList),
                                 TransfersAdvantagesView.ViewModel(data: transferAbroad.main.advantages),
                                 TransfersQuestionsView.ViewModel(data: transferAbroad.main.questions),
                                 TransfersSupportView.ViewModel(data: transferAbroad.main.support)]
                
                bind(sections)
            }
            .store(in: &bindings)
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case let .close(close):
                    switch close {
                    case .link:
                        LoggerAgent.shared.log(category: .ui, message: "received AuthTransfersAction.Close.Link")
                        link = nil
                        
                    case .sheet:
                        bottomSheet = nil
                    }
                    
                case let .show(show):
                    switch show {
                    case let .navbarTitle(scrollOffsetY):
                        
                        let opacity = scrollOffsetY / 300
                        if (0...1).contains(opacity) {
                            self.navigation.opacity = opacity
                        }
                        
                    case let .orderProduct(productData):
                        
                        let viewModel: OrderProductView.ViewModel = .init(
                            model,
                            productData: productData
                        )
                        
                        bottomSheet = .init(type: .orderProduct(viewModel))
                    }
                    
                case .transfersSection:
                    break
                }
            }
            .store(in: &bindings)
        
        $offset
            .receive(on: DispatchQueue.main)
            .sink { [weak self] offset in
                
                guard let self else { return }
                
                navigation.opacity = offset
                opacity = 1 - offset
            }
            .store(in: &bindings)
    }
    
    private func bind(_ sections: [TransfersSectionViewModel]) {
        
        for section in sections {
            
            switch section {
                
            case let payload as TransfersDirectionsView.ViewModel:
                
                payload.action
                    .compactMap { $0 as? TransfersSectionAction }
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] action in
                        
                        guard let self else { return }
                        
                        switch action {
                        case let .tap(countryCode):
                            
                            guard let viewModel = TransfersDetailView.ViewModel(model, countryCode: countryCode)
                            else { return }
                            
                            bind(viewModel)
                            bottomSheet = .init(type: .directions(viewModel))
                            
                        default:
                            break
                        }
                    }
                    .store(in: &bindings)
                
            case let payload as TransfersBannersView.ViewModel:
                
                payload.action
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] action in
                        
                        guard let self else { return }
                        
                        switch action {
                        case let payload as TransfersPromoAction.Banner.Mig.Tap:
                            
                            if let viewModel = TransfersPromoDetailView.ViewModel(model: model,
                                                                                  countryId: payload.countryId,
                                                                                  bannerType: payload.bannerType) {
                                bottomSheet = .init(type: .promoMig(viewModel))
                            }
                            
                        case let payload as TransfersPromoAction.Banner.Deposit.Tap:
                             
                            if let viewModel = TransfersPromoDepositView.ViewModel(model: model,
                                                                                  countryId: payload.countryId,
                                                                                  bannerType: payload.bannerType) {
                                bottomSheet = .init(type: .promoDeposit(viewModel))
                            }

                        default:
                            break
                        }
                    }
                    .store(in: &bindings)
                
            default:
                break
            }
        }
    }
    
    private func bind(_ viewModel: TransfersDetailView.ViewModel) {
        
        viewModel.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] action in
                
                guard let self else { return }
                
                switch action {
                case .order:
                    
                    self.action.send(.close(.sheet))
                    
                    let action: (Int) -> Void = { [weak self] id in
                        
                        guard let self = self else { return }
                        
                        if let catalogProduct = self.model.catalogProducts.value.first(where: { $0.id == id })  {
                            self.action.send(.show(.orderProduct(catalogProduct)))
                        }
                    }
                    
                    let dismissAction: () -> Void = { [weak self] in
                       
                        self?.action.send(.close(.link))
                    }
                    
                    let viewModel: AuthProductsViewModel = .init(self.model, products: self.model.catalogProducts.value, action: action, dismissAction: dismissAction)
                    LoggerAgent.shared.log(level: .debug, category: .ui, message: "presented products view")
                    self.link = .products(viewModel)
                    
                case .transfer:
                    
                    self.action.send(.close(.sheet))
                    self.action.send(.transfersSection(.transfers))
                }
            }
            .store(in: &bindings)
    }
    
}

extension AuthTransfersViewModel {
    
    var padding: CGFloat {
        
        UIApplication.safeAreaInsets.top + 12
    }
}

// MARK: - Types

extension AuthTransfersViewModel {
    
    struct BottomSheet: BottomSheetCustomizable {

        let id = UUID()
        let type: Kind

        var animationSpeed: Double { 0.4 }
        
        enum Kind {
            
            case directions(TransfersDetailView.ViewModel)
            case promoMig(TransfersPromoDetailView.ViewModel)
            case promoDeposit(TransfersPromoDepositView.ViewModel)
            case orderProduct(OrderProductView.ViewModel)
        }
    }
    
    enum Link {
       
        case products(AuthProductsViewModel)
    }
    
}

// MARK: - Action

enum AuthTransfersAction {
    
    case close(Close)
    case show(Show)
    case transfersSection(TransfersSectionAction)
    
    enum Close {
        
        case link, sheet
    }
    
    enum Show {
        
        case orderProduct(CatalogProductData)
        case navbarTitle(scrollOffsetY: Double)
    }
}

extension AuthTransfersAction {
    
    var transfersSectionAction: TransfersSectionAction? {
        
        if case let .transfersSection(transfersSection) = self {
            return transfersSection
        } else {
            return nil
        }
    }
}

enum CountryType: CaseIterable {
    
    case abkhazia
    case azerbaijan
    case armenia
    case belarus
    case georgia
    case kazakhstan
    case kyrgyzstan
    case moldova
    case tadjikistan
    case turkey
    case uzbekistan
    case southOssetia
    
    var title: String {
        
        switch self {
        case .abkhazia: return "Абхазия"
        case .azerbaijan: return "Азербайджан"
        case .armenia: return "Армения"
        case .belarus: return "Беларусь"
        case .georgia: return "Грузия"
        case .kazakhstan: return "Казахстан"
        case .kyrgyzstan: return "Кыргызстан"
        case .moldova: return "Молдова"
        case .tadjikistan: return "Таджикистан"
        case .turkey: return "Турция"
        case .uzbekistan: return "Узбекистан"
        case .southOssetia: return "Южная Осетия"
        }
    }
    
    var icon: Image {
        
        switch self {
        case .abkhazia: return .init("Abkhazia Flag")
        case .azerbaijan: return .init("Azerbaijan Flag")
        case .armenia: return .init("Armenia Flag")
        case .belarus: return .init("Belarus Flag")
        case .georgia: return .init("Georgia Flag")
        case .kazakhstan: return .init("Kazakhstan Flag")
        case .kyrgyzstan: return .init("Kyrgyzstan Flag")
        case .moldova: return .init("Moldova Flag")
        case .tadjikistan: return .init("Tadjikistan Flag")
        case .turkey: return .init("Turkey Flag")
        case .uzbekistan: return .init("Uzbekistan Flag")
        case .southOssetia: return .init("South Ossetia Flag")
        }
    }
    
    var rate: String {
        
        switch self {
        case .armenia: return "1"
        case .georgia: return "1,2"
        case .kazakhstan: return "1"
        case .kyrgyzstan: return "1"
        case .moldova: return "1"
        case .tadjikistan: return "1,5"
        case .uzbekistan: return "1,5"
        default:
            return "0"
        }
    }
    
}

extension AuthTransfersViewModel {
    
    static let sample: AuthTransfersViewModel = .init(
        .emptyMock,
        sections: [
            TransfersCoverView.ViewModel.sample,
            TransfersDirectionsView.ViewModel(
                model: .emptyMock,
                items:  TransfersDirectionsView.ViewModel.sampleItems),
            TransfersInfoView.ViewModel.sample,
            TransfersCountriesView.ViewModel(
                model: .emptyMock,
                items:  TransfersDirectionsView.ViewModel.sampleItems),
            TransfersAdvantagesView.ViewModel(
                items: TransfersAdvantagesView.ViewModel.sampleItems),
            TransfersQuestionsView.ViewModel(
                data: TransfersQuestionsView.ViewModel.sampleData),
            TransfersSupportView.ViewModel(
                items: TransfersSupportView.ViewModel.sampleItems)
        ],
        title: "Переводы",
        subTitle: "за рубеж",
        legalTitle: "Фора-банк является зарегистрированным поставщиком платежных услуг. Наша деятельность находится под контролем Налогово-таможенной службы (HMRC) в соответствии с Положением об отмывании денег №12667079 и регулируется Управлением по финансовому регулированию и надзору РФ",
        navigation: .init(title: "Переводы за рубеж", opacity: 0.5)
    )
}
