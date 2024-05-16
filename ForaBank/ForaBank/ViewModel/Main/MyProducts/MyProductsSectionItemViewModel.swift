//
//  MyProductsSectionItemViewModel.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 17.04.2022.
//  Full refactored by Dmitry Martynov on 18.09.2022
//

import Foundation
import Combine
import SwiftUI

class MyProductsSectionItemViewModel: ObservableObject, Identifiable {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let id: ProductData.ID
    
    @Published var icon: IconViewModel
    @Published var balance: String
    @Published var sideButton: SideButtonViewModel?
    @Published var name: String
    
    let paymentSystemIcon: Image?
    let descriptions: [String]
    let orderModePadding: CGFloat
    let parentID: Int
  
    private let model: Model
    private let getProduct: (ProductData.ID) -> ProductData?

    private var bindings = Set<AnyCancellable>()
    
    init(id: ProductData.ID, icon: IconViewModel, paymentSystemIcon: Image?, name: String, balance: String, descriptions: [String], sideButton: SideButtonViewModel?, orderModePadding: CGFloat = 0, model: Model) {
        
        self.id = id
        self.icon = icon
        self.paymentSystemIcon = paymentSystemIcon
        self.name = name
        self.balance = balance
        self.descriptions = descriptions
        self.sideButton = sideButton
        self.orderModePadding = orderModePadding
        self.model = model
        self.getProduct = { model.product(productId: $0) }
        self.parentID = model.product(productId: id)?.asCard?.idParent ?? -1
        bind()
    }

    convenience init(productData: ProductData, model: Model) {

        let icon = IconViewModel(with: productData, model: model)
        let paymentSystemIcon = ProductViewModel.paymentSystemIcon(from: productData, getImage: { model.images.value[.init($0)]?.image })
        let name = ProductViewModel.name(
            product: productData,
            style: .profile,
            creditProductName: .myProductsSectionItem
        )
        let balance = ProductViewModel.balanceFormatted(product: productData, style: .main, model: model)
        let descriptions = productData.description
        var orderModePadding: CGFloat = 0
        
        if #available(iOS 16, *) {
            orderModePadding = 12
        }
        
        self.init(id: productData.id,
                  icon: icon,
                  paymentSystemIcon: paymentSystemIcon,
                  name: name, balance: balance,
                  descriptions: descriptions,
                  sideButton: nil,
                  orderModePadding: orderModePadding,
                  model: model)
    }
    
    var isHidden: Bool {
        get {
            guard let product = getProduct(self.id) else { return true }
            return !product.productStatus.contains(.visible) //!productData.visibility
        }
        
        set {
            model.action.send(ModelAction.Products.UpdateVisibility(productId: self.id, visibility: !newValue))
        }
    }
    
    func update(with productData: ProductData) {
        
        icon = IconViewModel(with: productData, model: model)
        name = ProductViewModel.name(product: productData, style: .profile, creditProductName: .myProductsSectionItem)
        balance = ProductViewModel.balanceFormatted(product: productData, style: .main, model: model)
    }
    
    private func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {
                case _ as MyProductsSectionItemAction.SideButtonTapped.Activate:
                    //TODO: send activation action to model
                    dismissSideButton()
                    
                case _ as MyProductsSectionItemAction.SideButtonTapped.Add:
                    model.action.send(ModelAction.Products.UpdateVisibility(productId: id, visibility: true))
                    dismissSideButton()
                    
                case _ as MyProductsSectionItemAction.SideButtonTapped.Remove:
                    model.action.send(ModelAction.Products.UpdateVisibility(productId: id, visibility: false))
                    dismissSideButton()
  
                default:
                    break
                }
                
            }.store(in: &bindings)
        
        model.productsVisibilityUpdating
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] updatingSet in
               
                icon.isUpdating = updatingSet.contains(id)
            
        }.store(in: &bindings)
        
        model.images
            .receive(on: DispatchQueue.main)
            .sink { [unowned self ] images in
                
                guard let productData = self.getProduct(self.id) else { return }
                update(with: productData)
        }
        .store(in: &bindings)
        
    }
    
    func isSwipeAvailable(direction: SwipeDirection) -> Bool {
        
        guard let sideButton = sideButton else { return true }

        switch (sideButton, direction) {
        case (.left, .right), (.right, .left):
            return true
            
        default:
            return false
        }
    }
    
    func actionButton(for direction: SwipeDirection) -> ActionButtonViewModel? {
        
        guard let product = getProduct(id)
        else { return nil }
        
        switch direction {
        case .right:
            
            guard false, !product.productStatus.contains(.active) //fix if activated button need
            else { return nil }
            
            return ActionButtonViewModel(type: .activate, action: { [weak self] in self?.action.send(MyProductsSectionItemAction.SideButtonTapped.Activate())})
            
        case .left:
            
            guard product.productStatus.contains(.active),
                  !model.productsVisibilityUpdating.value.contains(id)
                  
            else { return nil }
            
            if product.isVisible {
                
                return ActionButtonViewModel(type: .remove, action: { [weak self] in self?.action.send(MyProductsSectionItemAction.SideButtonTapped.Remove())})
                
            } else {
                
                return ActionButtonViewModel(type: .add, action: { [weak self] in self?.action.send(MyProductsSectionItemAction.SideButtonTapped.Add())})
            }
        }
    }
    
    func dismissSideButton() {
        
        withAnimation {
            
            sideButton = nil
        }
    }
    
    func clover() -> Image? {
        
        return getProduct(id)?.cloverImage
    }
}

//MARK: - Types

extension MyProductsSectionItemViewModel {

    class IconViewModel: ObservableObject {
        
        @Published var isUpdating: Bool
        
        let background: Background
        let overlay: Overlay?
        
        init(background: Background, overlay: Overlay?, isUpdating: Bool) {
            
            self.background = background
            self.overlay = overlay
            self.isUpdating = isUpdating
        }
        
        convenience init(with productData: ProductData, model: Model) {
            
            let isUpdating = model.productsVisibilityUpdating.value.contains(productData.id)
            
            let backgroundImage = model.images.value[productData.smallDesignMd5hash]?.image
            let backgroundDesignImage = model.images.value[productData.smallBackgroundDesignHash]?.image
            
            switch productData.productStatus {
            case [.active, .blocked, .visible]:
                self.init(background: .init(img: backgroundDesignImage, color: productData.backgroundColor),
                          overlay: .init(image: .ic16Lock,
                                         imageColor: productData.overlayImageColor),
                          isUpdating: isUpdating)
                
            case [.active, .blocked]:
                // active, blocked, not visible
                self.init(background: .init(img: backgroundDesignImage, color: productData.backgroundColor),
                          overlay: .init(image: .ic12Lockandeyeoff,
                                         imageColor: productData.overlayImageColor),
                          isUpdating: isUpdating)
                
            case [.active, .visible]:
                // active, not blocked, visible
                self.init(background: .init(img: backgroundImage, color: productData.backgroundColor),
                          overlay: nil,
                          isUpdating: isUpdating)
                
            case .active:
                // active, not blocked, not visible
                self.init(background: .init(img: backgroundDesignImage, color: productData.backgroundColor),
                          overlay: .init(image: .ic16EyeOff,
                                         imageColor: productData.overlayImageColor),
                          isUpdating: isUpdating)
            default:
                // not active
                self.init(background: .init(img: backgroundDesignImage, color: productData.backgroundColor),
                          overlay: .init(image: .ic16ArrowRightCircle,
                                         imageColor: productData.overlayImageColor),
                          isUpdating: isUpdating)
            }
        }
        
        enum Background {
            
            case image(Image)
            case color(Color)
            
            init(img: Image?, color: Color) {

                if let img = img {
                    self = .image(img)
                } else {
                    self = .color(color) }
                }
        }
        
        struct Overlay {
            
            let image: Image
            let imageColor: Color
        }
    }
    
    enum SideButtonViewModel {

        case left(ActionButtonViewModel)
        case right(ActionButtonViewModel)
    }
    
    enum SwipeDirection {
        
        case left
        case right
        
        @available(iOS 15.0, *)
        init(with edge: HorizontalEdge) {
            
            switch edge {
            case .leading: self = .right
            case .trailing: self = .left
            }
        }
    }
    
    struct ActionButtonViewModel {
        
        let type: ActionButtonType
        let action: () -> Void
    }
    
    enum ActionButtonType {
        
        case activate
        case add
        case remove
        
        var icon: Image {
            
            switch self {
            case .activate: return .ic24Lock
            case .add: return .ic24Eye
            case .remove: return .ic24EyeOff
            }
        }
        
        var title: String {
            
            switch self {
            case .activate: return "Активировать"
            case .add: return "Вернуть\nна главный"
            case .remove: return "Скрыть с\nглавного"
            }
        }
        
        var color: Color {
            
            switch self {
            case .activate: return .systemColorActive
            case .add: return .mainColorsBlack
            case .remove: return .mainColorsGray
            }
        }
    }
    
}

enum MyProductsSectionItemAction {
    
    enum SideButtonTapped {
        
        struct Add: Action {}
        
        struct Remove: Action {}
        
        struct Activate: Action {}
    }
    
    struct Swiped: Action {
        
        let direction: MyProductsSectionItemViewModel.SwipeDirection
        let editMode: EditMode
    }
}

extension MyProductsSectionItemViewModel {
    
    static let sample7 = MyProductsSectionItemViewModel(
        id: 10002585806,
        icon: .init(background: .color(.orange),
                    overlay: .init(image: Image("lock-and-eye-off"),
                                   imageColor: .white), isUpdating: true),
        paymentSystemIcon: .init("Logo Visa"),
        name: "СБЕРЕГАТЕЛЬНЫЙ ОН-ЛАЙН",
        balance: "19 547 ₽",
        descriptions: ["2953", "Дебетовая", "29.08.22"],
        sideButton: nil,
        model: .emptyMock)
    
    static let sample8 = MyProductsSectionItemViewModel(
        id: 10002585806,
        icon: .init(background: .color(.orange),
                    overlay: .init(image: Image("lock-and-eye-off"),
                                   imageColor: .white), isUpdating: false),
        paymentSystemIcon: .init("Logo Visa"),
        name: "Кредит",
        balance: "19 547 ₽",
        descriptions: ["2953", "Дебетовая", "29.08.22"],
        sideButton: .right(.init(type: .add, action: {})),
        model: .emptyMock)
    
    static let sample9 = MyProductsSectionItemViewModel(
        id: 10002585806,
        icon: .init(background: .color(.orange),
                    overlay: .init(image: Image("lock-and-eye-off"),
                                   imageColor: .white), isUpdating: false),
        paymentSystemIcon: .init("Logo Visa"),
        name: "Кредит",
        balance: "19 547 ₽",
        descriptions: ["2953", "Дебетовая", "29.08.22"],
        sideButton: .left(.init(type: .activate, action: {})),
        model: .emptyMock)
}



