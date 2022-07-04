//
//  MainSectionProductsGroupViewComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 18.05.2022.
//

import Foundation
import SwiftUI
import Combine
import ScrollViewProxy

//MARK: - ViewModel

extension MainSectionProductsGroupView {
    
    class ViewModel: Identifiable, ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        var id: String { productType.rawValue }
        let productType: ProductType
        @Published var visible: [ProductView.ViewModel]
        @Published var newProduct: ButtonNewProduct.ViewModel?
        @Published var groupButton: GroupButtonViewModel?
        @Published var isCollapsed: Bool
        @Published var isSeparator: Bool
        @Published var isUpdating: Bool
        let dimensions: Dimensions = .initial
        
        private var products: CurrentValueSubject<[ProductView.ViewModel], Never> = .init([])
        private let settings: MainProductsGroupSettings
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        init(productType: ProductType, visible: [ProductView.ViewModel], newProduct: ButtonNewProduct.ViewModel?, groupButton: GroupButtonViewModel?, isCollapsed: Bool, isSeparator: Bool, isUpdating: Bool, settings: MainProductsGroupSettings = .base, model: Model = .emptyMock) {
            
            self.productType = productType
            self.visible = visible
            self.newProduct = newProduct
            self.groupButton = groupButton
            self.isCollapsed = isCollapsed
            self.isSeparator = isSeparator
            self.isUpdating = isUpdating
            self.products.value = visible
            self.settings = settings
            self.model = model
        }
        
        init(productType: ProductType, products: [ProductView.ViewModel], settings: MainProductsGroupSettings = .base, model: Model) {
            
            self.productType = productType
            self.products.value = products
            self.settings = settings
            self.visible = []
            self.groupButton = nil
            self.isCollapsed = true
            self.isSeparator = true
            self.isUpdating = false
            self.model = model
            
            bind()
        }
        
        func update(with products: [ProductView.ViewModel]) {
            
            self.products.value = products
        }
        
        var width: CGFloat {
            
            var result: CGFloat = 0
            
            // products width
            result += CGFloat(visible.count) * dimensions.widths.product
            result += CGFloat(max(visible.count - 1, 0)) * dimensions.spacing
            
            // new product width
            if newProduct != nil {
                
                result += dimensions.spacing
                result += dimensions.widths.new
            }
            
            // group button width
            if groupButton != nil {
                
                result += dimensions.spacing
                result += dimensions.widths.button
            }
            
            // separator width
            if isSeparator == true {
                
                result += dimensions.spacing
                result += dimensions.widths.separator
            }
            
            return result
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as MainSectionProductsGroupAction.GroupButtonDidTapped:
                        isCollapsed.toggle()
                        
                        if self.isCollapsed == true {
                            
                            self.action.send(MainSectionProductsGroupAction.Group.Collapsed())
                        } 
  
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            products
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] products in
                    
                    withAnimation {
                        
                        let result = reduce(products: products, isCollapsed: isCollapsed, settings: settings)
                        visible = reduce(products: result.products, isUpdating: isUpdating)
                        groupButton = result.groupButton
                        
                        if productType == .card, visible.count <= settings.maxCardsAmountRequeredNewProduct {
                            
                            newProduct = ButtonNewProduct.ViewModel(icon: .ic24NewCardColor, title: "Хочу карту", subTitle: "Бесплатно", url: model.productsOpenAccountURL)
                            
                        } else {
                            
                            newProduct = nil
                        }
                    }
                    
                }.store(in: &bindings)
            
            $isCollapsed
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isCollapsed in
                    
                    withAnimation {
                        
                        let result = reduce(products: products.value, isCollapsed: isCollapsed, settings: settings)
                        visible = reduce(products: result.products, isUpdating: isUpdating)
                        groupButton = result.groupButton
                    }
                    
                }.store(in: &bindings)
            
            $isUpdating
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isUpdating in
                    
                    withAnimation {
                        
                        visible = reduce(products: visible, isUpdating: isUpdating)
                    }
                    
                }.store(in: &bindings)
        }
        
        func reduce(products: [ProductView.ViewModel], isCollapsed: Bool, settings: MainProductsGroupSettings) -> (products: [ProductView.ViewModel], groupButton: GroupButtonViewModel?) {
            
            if products.count <= settings.minVisibleProductsAmount {
                
                return (products, nil)
                
            } else {
                
                let groupButtonAction: () -> Void = { [weak self] in self?.action.send(MainSectionProductsGroupAction.GroupButtonDidTapped())}
                
                if isCollapsed == true {
                    
                    let visibleProducts = Array(products.prefix(settings.minVisibleProductsAmount))
                    let remainProductsAmount = products.count - settings.minVisibleProductsAmount
                    let groupButton = GroupButtonViewModel(content: .title("+\(remainProductsAmount)"), action: groupButtonAction)
                    
                    return (visibleProducts, groupButton)
                    
                } else {
                    
                    let groupButton = GroupButtonViewModel(content: .icon(.ic24ChevronsLeft), action: groupButtonAction)
                    
                    return (products, groupButton)
                }
            }
        }
        
        func reduce(products: [ProductView.ViewModel], isUpdating: Bool) -> [ProductView.ViewModel] {
            
            for product in products {
                
                product.isUpdating = isUpdating
            }
            
            return products
        }
    }
}

//MARK: - Action

enum MainSectionProductsGroupAction {
    
    struct GroupButtonDidTapped: Action {}
    
    enum Group {
    
        struct Expanded: Action {}
        
        struct Collapsed: Action {}
    }
}

//MARK: - ViewModel Types

extension MainSectionProductsGroupView.ViewModel {
    
    struct Dimensions {
        
        let spacing: CGFloat
        let widths: Widths
        
        struct Widths {
            
            let product: CGFloat
            let new: CGFloat
            let button: CGFloat
            let separator: CGFloat
        }
        
        static let initial = Dimensions(spacing: 8, widths: .init(product: 170, new: 112, button: 48, separator: 1))
    }
    
    struct GroupButtonViewModel {
        
        let content: Content
        let action: () -> Void
        
        enum Content {
            
            case title(String)
            case icon(Image)
        }
    }
}

//MARK: - View

struct MainSectionProductsGroupView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: viewModel.dimensions.spacing) {
            
            ForEach(viewModel.visible) { productViewModel in

                VStack {
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 12)
                            .frame(width: viewModel.dimensions.widths.product - 25 * 2, height: 104)
                            .foregroundColor(.mainColorsBlack)
                            .opacity(0.15)
                            .offset(x: 0, y: 13)
                            .blur(radius: 8)
                        
                        ProductView(viewModel: productViewModel)
                            .frame(width: viewModel.dimensions.widths.product, height: 104)
                    }
                    
                    Spacer()
                    
                }.frame(height: 127)

            }
            
            if let newProductViewModel = viewModel.newProduct {
                
                ButtonNewProduct(viewModel: newProductViewModel)
                    .frame(width: viewModel.dimensions.widths.new, height: 104)
                
            }
            
            if let groupButtonViewModel = viewModel.groupButton {
                
                GroupButtonView(viewModel: groupButtonViewModel)
                    .frame(width: viewModel.dimensions.widths.button, height: 104)
            }
            
            if viewModel.isSeparator == true {
                
                Capsule(style: .continuous)
                    .foregroundColor(.mainColorsGrayLightest)
                    .padding(.vertical, 20)
                    .frame(width: viewModel.dimensions.widths.separator, height: 104)
            }
            
        }.frame(height: 132)
    }
}

extension MainSectionProductsGroupView {
    
    struct GroupButtonView: View {
        
        let viewModel: MainSectionProductsGroupView.ViewModel.GroupButtonViewModel
        
        var body: some View {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.mainColorsGrayLightest)
                
                switch viewModel.content {
                case .title(let title):
                    Text(title)
                        .font(.textBodyMM14200())
                        .foregroundColor(.textSecondary)
                    
                case .icon(let icon):
                    icon
                        .foregroundColor(.iconBlack)
                }
                
            }.onTapGesture { viewModel.action() }
        }
    }
}

//MARK: - Preview

struct MainSectionProductsGroupView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            MainSectionProductsGroupView(viewModel: .sampleProductsOne)
                .previewLayout(.fixed(width: 375, height: 200))
            
            ScrollView(.horizontal) {
                
                MainSectionProductsGroupView(viewModel: .sampleProducts)
            }
            .previewLayout(.fixed(width: 400, height: 200))
            
            MainSectionProductsGroupView(viewModel: .sampleWant)
                .previewLayout(.fixed(width: 375, height: 200))
            
            MainSectionProductsGroupView(viewModel: .sampleGroup)
                .previewLayout(.fixed(width: 375, height: 200))
            
            MainSectionProductsGroupView(viewModel: .sampleGroupCollapsed)
                .previewLayout(.fixed(width: 375, height: 200))
            
            MainSectionProductsGroupView.GroupButtonView(viewModel: .init(content: .title("+5"), action: {}))
                .previewLayout(.fixed(width: 200, height: 100))
            
            MainSectionProductsGroupView.GroupButtonView(viewModel: .init(content: .icon(.ic24ChevronsLeft), action: {}))
                .previewLayout(.fixed(width: 200, height: 100))
        }
    }
}

//MARK: - Preview Content

extension MainSectionProductsGroupView.ViewModel {
    
    static let sampleWant = MainSectionProductsGroupView.ViewModel(productType: .card, visible: [.classic], newProduct: .sampleWantCard, groupButton: nil, isCollapsed: false, isSeparator: false, isUpdating: false)
    
    static let sampleGroup = MainSectionProductsGroupView.ViewModel(productType: .card, visible: [.classic], newProduct: nil, groupButton: .init(content: .title("+5"), action: {}), isCollapsed: false, isSeparator: true, isUpdating: false)
    
    static let sampleGroupCollapsed = MainSectionProductsGroupView.ViewModel(productType: .card, visible: [.classic], newProduct: nil, groupButton: .init(content: .title("+5"), action: {}), isCollapsed: true, isSeparator: true, isUpdating: false)
    
    static let sampleProducts = MainSectionProductsGroupView.ViewModel(productType: .card, products: [.classic, .account, .blocked], model: .emptyMock)
    
    static let sampleProductsOne = MainSectionProductsGroupView.ViewModel(productType: .card, products: [.classic], model: .emptyMock)
}

extension ButtonNewProduct.ViewModel {
    
    static let sampleWantCard = ButtonNewProduct.ViewModel(icon: .ic24NewCardColor, title: "Хочу карту", subTitle: "Бесплатно", action: {})
}
