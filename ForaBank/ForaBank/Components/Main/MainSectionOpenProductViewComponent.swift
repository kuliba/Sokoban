//
//  MainSectionOpenProductViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import Foundation
import SwiftUI
import Combine

//MARK: - ViewModel

extension MainSectionOpenProductView {

    class ViewModel: MainSectionCollapsableViewModel {

        override var type: MainSectionType { .openProduct }
        @Published var items: [ButtonNewProduct.ViewModel]
        
        private let displayButtonsTypes: [ProductType] = [.card, .deposit, .account]
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()

        init(items: [ButtonNewProduct.ViewModel], model: Model = .emptyMock, isCollapsed: Bool) {
            
            self.items = items
            self.model = model
            super.init(isCollapsed: isCollapsed)
        }
        
        init(_ model: Model) {
            
            self.items = []
            self.model = model
            super.init(isCollapsed: false)
            
            self.items = createItems()
            bind()
        }
        
        func bind() {
            
            model.deposits
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] _ in
                    
                    //TODO: more elegant update required
                    items = createItems()
                    
                }.store(in: &bindings)
        }
        
        private func createItems() -> [ButtonNewProduct.ViewModel] {
            
            displayButtonsTypes.map { type in
                
                let icon = type.openButtonIcon
                let title = type.openButtonTitle
                let subTitle = description(for: type)
                switch type {
                case .card:
                    return ButtonNewProduct.ViewModel(icon: icon, title: title, subTitle: subTitle, url: model.productsOpenAccountURL)
                    
                default:
                    return ButtonNewProduct.ViewModel(icon: icon, title: title, subTitle: subTitle, action: { [weak self] in
                        self?.action.send(MainSectionViewModelAction.OpenProduct.ButtonTapped(productType: type))
                    })
                }
            }
        }
        
        private func description(for type: ProductType) -> String {
            
            switch type {
            case .card: return "Все включено"
            case .account: return "Бесплатно"
            case .deposit: return depositDescription(with: model.deposits.value)
            case .loan: return "от 7% годов."
            }
        }
        
        private func depositDescription(with deposits: [DepositProductData]) -> String {
            
            guard let maxRate = deposits.map({ $0.generalСondition.maxRate }).max(),
                  let maxRateString = NumberFormatter.persent.string(from: NSNumber(value: maxRate / 100)) else {
                
                return "..."
            }
            
            return "\(maxRateString) годовых"
        }
    }
}

extension ProductType {
    
    var openButtonIcon: Image {
        
        switch self {
        case .card: return .ic24NewCardColor
        case .account: return .ic24FilePluseColor
        case .deposit: return .ic24DepositPlusColor
        case .loan: return .ic24CreditColor
        }
    }
    
    var openButtonTitle: String {
        
        switch self {
        case .card: return "Карту"
        case .account: return "Счет"
        case .deposit: return "Вклад"
        case .loan: return "Кредит"
        }
    }
}

//MARK: - View

struct MainSectionOpenProductView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        
        CollapsableSectionView(title: viewModel.title, edges: .horizontal, padding: 20, isCollapsed: $viewModel.isCollapsed) {
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 8) {

                    ForEach(viewModel.items) { itemViewModel in

                        ButtonNewProduct(viewModel: itemViewModel)
                            .frame(width: 112, height: 124)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
//MARK: - Preview

struct MainBlockOpenProductsView_Previews: PreviewProvider {

    static var previews: some View {
        
        MainSectionOpenProductView(viewModel: .previewSample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionOpenProductView.ViewModel {

    static let previewSample = MainSectionOpenProductView.ViewModel(items: [.sample, .sample, .sample,.sample], isCollapsed: false)

    static let sample = MainSectionOpenProductView.ViewModel(.emptyMock)
}
