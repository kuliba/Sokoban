//
//  ProductsSwapViewComponent.swift
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
        
        var items: [ProductSelectorView.ViewModel]
        @Published var isReversed: Bool = false
        
        private let model: Model
        private var bindings = Set<AnyCancellable>()
        
        lazy var swapViewModel: SwapViewModel = .init(swapButton: .init() {
            
            switch self.swapViewModel.swapButton.state {
            case .normal:
                self.action.send(ProductsSwapAction.Button.Tap())
            case .reset:
                self.action.send(ProductsSwapAction.Button.Reset())
            }
        })
        
        var from: ProductSelectorView.ViewModel? { items.first }
        var to: ProductSelectorView.ViewModel? { items.last }
        
        init(model: Model, items: [ProductSelectorView.ViewModel]) {
            
            self.model = model
            self.items = items
            
            bind()
        }
        
        private func bind() {
            
            action
                .receive(on: DispatchQueue.main)
                .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
                .sink { [unowned self] action in
                    
                    switch action {
                    case _ as ProductsSwapAction.Button.Tap:
                        
                        items = items.reversed()
                        
                        withAnimation {
                            isReversed.toggle()
                        }
                        
                    case _ as ProductsSwapAction.Button.Reset:
                        break
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
    }
}

extension ProductsSwapView.ViewModel {
    
    // MARK: - Swap
    
    class SwapViewModel: ObservableObject {
        
        @Published var isToogleButton: Bool
        @Published var pathInset: Double
        
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
                    
                    withAnimation(.easeInOut) {
                        swapButton.isCurrencySwap.toggle()
                    }
                }.store(in: &bindings)
        }
    }
    
    // MARK: - Button

    class SwapButtonViewModel: ObservableObject {
        
        @Published var isCurrencySwap: Bool
        @Published var isUserInteractionEnabled: Bool
        @Published var icon: Image
        @Published var state: State

        let action: () -> Void
        
        private var bindings = Set<AnyCancellable>()
        
        var rotationAngle: Angle {
            isCurrencySwap ? .degrees(0) : .degrees(180)
        }
        
        enum State {
            
            case normal
            case reset
        }
        
        init(isCurrencySwap: Bool = false, isUserInteractionEnabled: Bool = true, icon: Image = .ic32Swap, action: @escaping () -> Void) {
            
            self.isCurrencySwap = isCurrencySwap
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
    
    @Namespace private var namespace
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ZStack {

            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.mainColorsGrayLightest)
            
            VStack(alignment: .leading, spacing: 0) {
                
                if viewModel.isReversed == false {
                    
                    if let from = viewModel.items.first {
                        
                        ProductSelectorView(viewModel: from)
                            .matchedGeometryEffect(id: from.id, in: namespace)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 12)
                    }
                    
                } else {
                    
                    if let to = viewModel.items.first {
                        
                        ProductSelectorView(viewModel: to)
                            .matchedGeometryEffect(id: to.id, in: namespace)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 12)
                    }
                }

                SwapView(viewModel: viewModel.swapViewModel)
                    .padding(.horizontal, 20)
                
                if viewModel.isReversed == false {
                    
                    if let to = viewModel.items.last {
                        
                        ProductSelectorView(viewModel: to)
                            .matchedGeometryEffect(id: to.id, in: namespace)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                    }
                    
                } else {
                    
                    if let from = viewModel.items.last {
                        
                        ProductSelectorView(viewModel: from)
                            .matchedGeometryEffect(id: from.id, in: namespace)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                    }
                }
            }
            
        }.fixedSize(horizontal: false, vertical: true)
    }
}

extension ProductsSwapView {
    
    // MARK: - Swap
    
    struct SwapView: View {
        
        @ObservedObject var viewModel: ViewModel.SwapViewModel
  
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
}

// MARK: - Previews

struct ProductsSwapViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            ProductsSwapView(viewModel: .init(model: .emptyMock, items: [.sample1, .sample2]))
            ProductsSwapView(viewModel: .init(model: .emptyMock, items: [.sample1, .sample3]))
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
