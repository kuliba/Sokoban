//
//  ProductsSwapView.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 22.09.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension ProductsSwapView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published var items: [ProductSelectorView.ViewModel]
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        lazy var divider: DividerViewModel = .init(swapButton: .init() { [weak self] in
            
            guard let self = self else { return }
            
            switch self.divider.swapButton.state {
            case .normal:
                self.action.send(ProductsSwapAction.Button.Tap())
            case .reset:
                self.action.send(ProductsSwapAction.Button.Reset())
            }
        })
        
        var from: ProductSelectorView.ViewModel? { items.first }
        var to: ProductSelectorView.ViewModel? { items.last }
        
        var productIdFrom: ProductData.ID? {
            
            guard let from = from, let productViewModel = from.productViewModel else {
                return nil
            }
            
            return productViewModel.id
        }
        
        var productIdTo: ProductData.ID? {
            
            guard let to = to, let productViewModel = to.productViewModel else {
                return nil
            }
            
            return productViewModel.id
        }
        
        init(model: Model, items: [ProductSelectorView.ViewModel]) {
            
            self.model = model
            self.items = items
        }
        
        convenience init(_ model: Model, productData: ProductData, mode: PaymentsMeToMeViewModel.Mode) {
            
            switch mode {
            case .general:
                
                let contextFrom: ProductSelectorView.ViewModel.Context = .init(title: "Откуда", direction: .from, checkProductId: productData.id)
                let contextTo: ProductSelectorView.ViewModel.Context = .init(title: "Куда", direction: .to)
                
                let from: ProductSelectorView.ViewModel = .init(model, productData: productData, context: contextFrom)
                let to: ProductSelectorView.ViewModel = .init(model, context: contextTo)
                
                self.init(model: model, items: [from, to])
            }
            
            bind()
            bind(items: items)
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ProductsSwapAction.Button.Tap:
                                                
                        withAnimation {
                            
                            items = items.reversed()
                            divider.isToogleButton.toggle()
                        }
                        
                        self.action.send(ProductsSwapAction.Swapped())
                        
                    case _ as ProductsSwapAction.Button.Reset:
                        break
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
            
            $items
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] items in
                    
                    guard let from = from, let to = to else {
                        return
                    }

                    var contextFrom = from.context.value
                    var contextTo = to.context.value
                    
                    contextFrom.direction = .from
                    contextTo.direction = .to
                    
                    contextFrom.title = "Откуда"
                    contextTo.title = "Куда"
                    
                    from.context.send(contextFrom)
                    to.context.send(contextTo)
                    
                }.store(in: &bindings)
        }
        
        func bind(items: [ProductSelectorView.ViewModel]) {
            
            for item in items {
                
                item.action
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] action in
                        
                        switch action {
                        case let payload as ProductSelectorAction.Selected:
                            
                            if let from = from, item.id == from.id {
                                self.action.send(ProductsSwapAction.Selected.From(productId: payload.id))
                            } else {
                                self.action.send(ProductsSwapAction.Selected.To(productId: payload.id))
                            }

                        default:
                            break
                        }

                    }.store(in: &bindings)
            }
        }
    }
}

extension ProductsSwapView.ViewModel {
    
    // MARK: - Divider
    
    class DividerViewModel: ObservableObject {
        
        @Published var isToogleButton: Bool
        @Published var pathInset: Double
        
        let id: UUID = .init()
        let swapButton: SwapButtonViewModel
        private var bindings = Set<AnyCancellable>()
        
        init(isToogleButton: Bool = false, swapButton: SwapButtonViewModel, pathInset: Double = 5) {
            
            self.isToogleButton = isToogleButton
            self.swapButton = swapButton
            self.pathInset = pathInset
            
            bind()
        }
        
        private func bind() {
            
            $isToogleButton
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isToogleButton in
                    
                    withAnimation {
                        swapButton.isSwap = isToogleButton
                    }

                }.store(in: &bindings)
        }
    }
    
    // MARK: - Button

    class SwapButtonViewModel: ObservableObject {
        
        @Published var isSwap: Bool
        @Published var isUserInteractionEnabled: Bool
        @Published var icon: Image
        @Published var state: State

        let action: () -> Void
        
        private var bindings = Set<AnyCancellable>()
        
        var rotationAngle: Angle {
            isSwap ? .degrees(0) : .degrees(180)
        }
        
        enum State {
            
            case normal
            case reset
        }
        
        init(isSwap: Bool = false, isUserInteractionEnabled: Bool = true, icon: Image = .ic32Swap, action: @escaping () -> Void) {
            
            self.isSwap = isSwap
            self.isUserInteractionEnabled = isUserInteractionEnabled
            self.icon = icon
            self.action = action
            
            state = .normal
            
            bind()
        }
        
        private func bind() {
            
            $isUserInteractionEnabled
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] isEnabled in
                    
                    if isEnabled == false {
                        
                        icon = .init("Swap Reset")
                        state = .reset
                    }
                    
                }.store(in: &bindings)
            
            $state
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] state in
                    
                    if state == .normal {
                        icon = .ic32Swap
                    }
                    
                }.store(in: &bindings)
        }
    }
}

// MARK: - View

struct ProductsSwapView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            ForEach(viewModel.items) { item in
                ProductSelectorView(viewModel: item)
                    .padding(.vertical, 4)
                
                if let from = viewModel.from, item.id == from.id {
                    DividerView(viewModel: viewModel.divider)
                        .padding(.vertical, 8)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(20)
    }
}

extension ProductsSwapView {
    
    // MARK: - Divider
    
    struct DividerView: View {
        
        @ObservedObject var viewModel: ViewModel.DividerViewModel
  
        var body: some View {
            
                HStack(spacing: 20) {
                    
                    GeometryReader { proxy in
                        
                        Path { path in
                            
                            let height = proxy.size.height / 2
                            
                            path.move(to: .init(x: 0, y: height))
                            path.addLine(to: .init(x: 10, y: height))
                            path.addLine(to: .init(x: 16, y: height + viewModel.pathInset))
                            path.addLine(to: .init(x: 22, y: height))
                            path.addLine(to: .init(x: proxy.size.width, y: height))
                        }
                        .stroke()
                        .foregroundColor(.mainColorsGrayMedium)
                    }
                    
                    ProductsSwapView.SwapButtonView(viewModel: viewModel.swapButton)
                }
        }
    }
    
    // MARK: - Button

    struct SwapButtonView: View {

        @ObservedObject var viewModel: ViewModel.SwapButtonViewModel

        var body: some View {

            Button(action: viewModel.action) {

                viewModel.icon
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 32, height: 32)
                    .rotationEffect(viewModel.rotationAngle)
            }
            .buttonStyle(ProductsSwapView.SwapButtonStyle())
            .disabled(viewModel.isUserInteractionEnabled == false)
        }
    }
    
    struct SwapButtonStyle: ButtonStyle {
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(.mainColorsGray)
        }
    }
}

// MARK: - Action

enum ProductsSwapAction {
    
    enum Button {
        
        struct Tap: Action {}
        struct Reset: Action {}
        struct Close: Action {}
    }
    
    struct Swapped: Action {}
    
    enum Selected {
        
        struct From: Action {
            
            let productId: ProductData.ID
        }
        
        struct To: Action {
            
            let productId: ProductData.ID
        }
    }
}

// MARK: - Previews

struct ProductsSwapViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            ProductsSwapView(viewModel: .init(model: .emptyMock, items: [.sample1, .sample2]))
            ProductsSwapView(viewModel: .init(model: .emptyMock, items: [.sample1, .sample3]))
            
        }.previewLayout(.sizeThatFits)
    }
}
