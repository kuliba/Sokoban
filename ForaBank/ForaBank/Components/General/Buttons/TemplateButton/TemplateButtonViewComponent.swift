//
//  TemplateButtonViewComponent.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 30.05.2023.
//

import SwiftUI
import Combine

extension TemplateButtonView {
    
    class ViewModel: ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()
        private var bindings = Set<AnyCancellable>()

        @Published var state: State
        let tapAction: () -> Void
        
        private let model: Model
        
        init(state: State,
             model: Model,
             tapAction: @escaping () -> Void) {
            
            self.model = model
            self.state = state
            self.tapAction = tapAction
            
            bind()
        }
        
        convenience init(
            model: Model,
            state: State? = nil,
            operationDetail: OperationDetailData
        ) {
            
            let state = state ?? (operationDetail.paymentTemplateId != nil ? .complete : .idle)
            
            let action = Self.buttonAction(
                model: model,
                with: state,
                operationDetail: operationDetail
            )
            
            self.init(
                state: state,
                model: model,
                tapAction: action
            )
        }

        static func buttonAction(
            model: Model,
            with state: State,
            operationDetail: OperationDetailData
            ) -> () -> Void {
                
                switch state {
                case .refresh:
                    guard let paymentTemplateId = operationDetail.paymentTemplateId else {
                        return {}
                    }
                    
                    let name = operationDetail.templateName
                    let action = ModelAction.PaymentTemplate.Update.Requested(
                        name: name,
                        parameterList: [],
                        paymentTemplateId: paymentTemplateId)
                    return { model.action.send(action) }
                    
                case .complete:
                    guard let paymentTemplateId = operationDetail.paymentTemplateId else {
                        return {}
                    }
                    
                    let action = ModelAction.PaymentTemplate.Delete.Requested(
                        paymentTemplateIdList: [paymentTemplateId]
                    )
                    return { model.action.send(action) }
                    
                case .idle:
                    
                    let paymentOperationDetailId = operationDetail.paymentOperationDetailId
                    let name = operationDetail.templateName
                    let action = ModelAction.PaymentTemplate.Save.Requested(
                        name: name,
                        paymentOperationDetailId: paymentOperationDetailId
                    )
                    return { model.action.send(action) }
                    
                case .loading:
                    return {}
                }
            }
    }
}

// MARK: Helpers
extension TemplateButtonView.ViewModel {
    
    var title: String {
        
        switch state {
        case .idle, .loading, .complete:
            return "Шаблон"
        case .refresh:
            return "Обновить шаблон?"
        }
    }
    
    var icon: Image? {
        
        switch state {
        case .idle, .loading:
            return Image.ic16Plus
        case .refresh:
            return nil
        case .complete:
            return Image.ic24Check
        }
    }
}

// MARK: View Builder's

extension TemplateButtonView {
    
    @ViewBuilder
    private func bottomView(viewModel: TemplateButtonView.ViewModel) -> some View {
        
        HStack(spacing: 3) {
            
            if let icon = viewModel.icon {
                
                icon
                    .resizable()
                    .foregroundColor(foregroundColor)
                    .frame(width: 12, height: 12, alignment: .center)
            }
            
            Text(viewModel.title)
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(foregroundColor)
        }
    }
    
    private var foregroundColor: Color {
        
        switch viewModel.state {
        case .complete:
            return .systemColorActive
        default:
            return .mainColorsBlack
        }
    }
}

// MARK: Binding's

extension TemplateButtonView.ViewModel {
    
    func bind() {
        
        //MARK: bind model action
        
        let complete = Publishers.CombineLatest(
            model.action.compactMap { $0 as? ModelAction.PaymentTemplate.Save.Complete },
            model.action.compactMap { $0 as? ModelAction.PaymentTemplate.Update.Complete }
        )
            .map { _ in State.complete}
        
        let idle = model.action
            .compactMap { $0 as? ModelAction.PaymentTemplate.Delete.Complete }
            .map { _ in State.idle}
        
        let loading = Publishers.CombineLatest(
            model.action.compactMap { $0 as? ModelAction.PaymentTemplate.Save.Requested },
            model.action.compactMap { $0 as? ModelAction.PaymentTemplate.Delete.Requested }
        )
            .map { _ in State.loading}
        
        let refresh = model.action
            .compactMap { $0 as? ModelAction.PaymentTemplate.Update.Complete }
            .map { _ in State.complete}
        
        Publishers.Merge3(complete, idle, refresh)
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)

        model.action
            .receive(on: DispatchQueue.main)
            .sink { action in
                
                switch action {
                case _ as ModelAction.PaymentTemplate.Save.Requested:
                    self.state = .loading(isComplete: false)
                    
                case _ as ModelAction.PaymentTemplate.Delete.Requested:
                    self.state = .loading(isComplete: true)

                default:
                    break
                }
                
            }.store(in: &bindings)
    }
}

// MARK: Sub Type's

extension TemplateButtonView.ViewModel {
    
    enum State {
        
        case idle
        case loading(isComplete: Bool)
        case refresh
        case complete
    }
}

// MARK: Action

extension TemplateButtonView.ViewModel {
    
    enum ButtonAction: Action {
            
       case tapAction
    }
}

// MARK: Idle View

extension TemplateButtonView {
    
    struct IdleView: View {
        
        let tapAction: () -> Void
        
        var body: some View {
            
            Button(action: tapAction) {
                
                VStack(spacing: 12) {
                    
                    ZStack {
                        
                        Circle()
                            .fill(Color.mainColorsGrayLightest)
                            .frame(CGSize(width: 56, height: 56))
                        
                        StarShape(corners: 5, smoothness: 0.50)
                            .stroke(lineWidth: 1)
                            .fill(Color.black)
                            .frame(width: 19.5, height: 19)
                    }
                }
            }
        }
    }
}

// MARK: LoadingView View

extension TemplateButtonView {
    
    struct LoadingView: View {
        
        let state: State
        
        var body: some View {
            
            ZStack {
                
                Circle()
                    .fill(state == .idle ? Color.mainColorsGrayLightest : .systemColorActive)
                    .frame(width: 56, height: 56)
                
                ThreeBounceAnimationView(color: state == .idle ? .black : .white)
            }
        }
        
        enum State {
            
            case idle
            case complete
        }
    }
}

// MARK: RefreshView View

extension TemplateButtonView {
    
    struct RefreshView: View {
        
        let tapAction: () -> Void
        
        var body: some View {
            
            Button(action: tapAction) {
                
                ZStack {
                    
                    Circle()
                        .fill(Color.mainColorsGrayLightest)
                        .frame(width: 56, height: 56)
                    
                    Image.ic24RefreshCw
                        .foregroundColor(Color.mainColorsBlack)
                    
                    ZStack {
                        
                        Circle()
                            .fill(Color.systemColorActive)
                            .frame(width: 24, height: 24)
                        
                        StarShape(corners: 5, smoothness: 0.50)
                            .fill(.white)
                            .frame(width: 9.75, height: 9.5)
                    }
                    .offset(x: 20, y: -20)
                }
            }
        }
    }
}

// MARK: CompleteView View

extension TemplateButtonView {
    
    struct CompleteView: View {
        
        @State private var startAnimation = false
        
        let tapAction: () -> Void
        
        var body: some View {
            
            Button(action: tapAction ) {
                
                ZStack {
                    
                    stars(startAnimation: startAnimation)
                    
                    filledCircle(animation: startAnimation)
                        .frame(height: 56)
                    
                    Circle()
                        .fill(startAnimation ? Color.systemColorActive : .mainColorsGrayLightest)
                        .frame(width: 56)
                        .animation(.easeInOut(duration: 0.4).delay(0.3))
                    
                    StarShape(corners: 5, smoothness: 0.5)
                        .frame(width: 19, height: 19, alignment: .center)
                        .opacity(startAnimation ? 1 : 0)
                        .foregroundColor(startAnimation ? Color.white : Color.gray)
                        .animation(.easeInOut(duration: 0.2))
                        .scaleEffect(startAnimation ? 1 : 0.7)
                        .animation(.timingCurve(0.01, 2, 0.65, 0.65, duration: 0.5))
                    
                }
            }
            .onAppear {
                
                self.startAnimation = true
                
            }
        }
        
        @ViewBuilder
        func stars(startAnimation: Bool) -> some View {
            
            let starView = StarShape(corners: 5, smoothness: 0.45)
            
            starView
                .rotation(.init(degrees: 100))
                .frame(.init(width: 25, height: 25))
                .modifier(StarModifier(startAnimation: startAnimation))
                .offset(x: startAnimation ? 0 : 0, y: startAnimation ? 30 : 10)
                .rotationEffect(.init(degrees: 220))
            
            starView
                .rotation(.init(degrees: 100))
                .modifier(StarModifier(startAnimation: startAnimation))
                .offset(x: startAnimation ? 10 : 5, y: startAnimation ? 40 : 10)
                .rotationEffect(.init(degrees: 188))
            
            starView
                .rotation(.init(degrees: 100))
                .frame(.init(width: 25, height: 25))
                .modifier(StarModifier(startAnimation: startAnimation))
                .offset(x: startAnimation ? 30 : 10, y: startAnimation ? 30 : 10)
                .rotationEffect(.init(degrees: 170))
        }
        
        @ViewBuilder
        func filledCircle(animation: Bool) -> some View {
            
            Circle()
                .fill(Color.systemColorActive)
                .opacity(startAnimation ? 1 : 0)
                .frame(width: 90)
                .mask(
                    circleView(startAnimation: startAnimation, position: 0.5)
                )
                .animation(.easeInOut(duration: 0.8))
            
            Circle()
                .fill(Color.systemColorActive)
                .opacity(startAnimation ? 1 : 0)
                .frame(width: 100)
                .mask(
                    circleView(startAnimation: startAnimation, position: 0.4)
                )
                .animation(.easeInOut(duration: 0.4).delay(0.1))
            
            Circle()
                .fill(Color.systemColorActive)
                .opacity(startAnimation ? 1 : 0)
                .frame(width: 80)
                .mask(
                    circleView(startAnimation: startAnimation, position: 0.3)
                )
                .animation(.easeInOut(duration: 0.4).delay(0.2))
        }
        
        private struct StarModifier: ViewModifier {
            
            let startAnimation: Bool
            
            func body(content: Content) -> some View {
                
                content
                    .frame(width: 19.5, height: 19.5)
                    .foregroundColor(Color.systemColorActive)
                    .opacity(startAnimation ? 1 : 0)
                    .offset(x: startAnimation ? 10 : 0, y: startAnimation ? 50 : 20)
                    .animation(.easeInOut(duration: 0.6))
                    .opacity(startAnimation ? 0 : 1)
                    .animation(.linear(duration: 0.6))
                
            }
        }
        
        @ViewBuilder
        func circleView(startAnimation: Bool, position: Double) -> some View {
            
            Circle()
                .scale(x: startAnimation ? 1 : position, y: startAnimation ? 1 : position)
                .stroke(lineWidth: startAnimation ? 0 : 10)
        }
    }
}

// MARK: Main View

struct TemplateButtonView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        VStack(spacing: 12) {
            
            switch viewModel.state {
            case .idle:
                IdleView(tapAction: viewModel.tapAction)
                
            case let .loading(isComplete: isComplete):
                LoadingView(state: isComplete ? .complete : .idle)
                
            case .refresh:
                RefreshView(tapAction: viewModel.tapAction)
                
            case .complete:
                CompleteView(tapAction: viewModel.tapAction)
            }
            
            bottomView(viewModel: viewModel)
        }
        .frame(width: 70, height: 120)
    }
}

struct TemplateButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TemplateButtonView(viewModel: .preview(state: .idle))
            .previewDisplayName("idle state")
        
        TemplateButtonView(viewModel: .preview(state: .refresh))
            .previewDisplayName("refresh state")
        
        TemplateButtonView(viewModel: .preview(state: .loading(isComplete: true)))
            .previewDisplayName("loading state")
        
        TemplateButtonView(viewModel: .preview(state: .complete))
            .previewDisplayName("complete state")
    }
}

private extension TemplateButtonView.ViewModel {
 
    static func preview(state: State) -> TemplateButtonView.ViewModel {
        
        .init(state: state, model: .emptyMock, tapAction: {})
    }
}
