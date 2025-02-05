//
//  TemplateButtonViewComponent.swift
//  Vortex
//
//  Created by Дмитрий Савушкин on 30.05.2023.
//

import Combine
import CombineSchedulers
import SwiftUI

extension TemplateButtonView {
    
    //TODO: https://git.inn4b.ru/dbs/ios/-/merge_requests/1277#note_19249
    class ViewModel: ObservableObject, PaymentsSuccessOptionButtonsButtonViewModel {
        
        let id: Payments.ParameterSuccessOptionButtons.Option = .template
        let action: PassthroughSubject<Action, Never> = .init()
        
        @Published private(set) var state: State
        
        private let model: Model
        private let operation: Payments.Operation?
        private let details: OperationDetailData
        private var bindings = Set<AnyCancellable>()
        private let scheduler: AnySchedulerOf<DispatchQueue>
        
        init(
            model: Model,
            state: State? = nil,
            operation: Payments.Operation?,
            operationDetail details: OperationDetailData,
            scheduler: AnySchedulerOf<DispatchQueue> = .main
        ) {
            self.model = model
            self.operation = operation
            self.details = details
            
            let state = state ?? (details.paymentTemplateId != nil ? .init(details: details) : .idle)
            
            self.state = state
            self.scheduler = scheduler
            
            bind()
        }
        
        func tapAction() {
            
            let operationDetail = details
            
            switch state {
            case let .refresh(templateId: templateId):
                
                guard let template = model.paymentTemplates.value.first(where: { $0.id == templateId } ) 
                else { return }
                
                if case let .template(templateID) = operation?.source {
                    
                    requestUpdate(name: template.name, templateID: templateID)
                    
                } else {
                    
                    let parameterList = TemplateButton.createMe2MeParameterList(
                        model: model,
                        operationDetail: operationDetail
                    )
                    
                    let action = ModelAction.PaymentTemplate.Update.Requested(
                        name: template.name,
                        parameterList: parameterList,
                        paymentTemplateId: templateId
                    )
                    
                    return model.action.send(action)
                }
                
            case let .complete(templateID):
                
                switch operationDetail.paymentTemplateId {
                case let .some(templateID):
                    
                    requestDelete(templateID: templateID)
                    
                default:
                    
                    if case let .template(templateID) = operation?.source {
                        
                        requestDelete(templateID: templateID)
                        
                    } else {
                        
                        requestDelete(templateID: templateID)
                    }
                }
                
            case .idle:
                requestSave()
                
            case .loading:
                return
            }
        }
        
        private func requestUpdate(name: String, templateID: Int) {
            
            let parameterList = TemplateButton.templateParameterList(
                model: model,
                operationDetail: details,
                operation: operation
            )
            
            let action = ModelAction.PaymentTemplate.Update.Requested(
                name: name,
                parameterList: parameterList,
                paymentTemplateId: templateID
            )
            
            model.action.send(action)
        }
        
        private func requestDelete(templateID: Int) {
            
            let action = ModelAction.PaymentTemplate.Delete.Requested(
                paymentTemplateIdList: [templateID]
            )
            model.action.send(action)
        }

        private func requestSave() {
            
            let paymentOperationDetailId = details.paymentOperationDetailId
            let name = details.templateName
            let action = ModelAction.PaymentTemplate.Save.Requested(
                name: name,
                paymentOperationDetailId: paymentOperationDetailId
            )
            return model.action.send(action)
        }
    }
}

// MARK: Binding's

extension TemplateButtonView.ViewModel {
    
    func bind() {
        
        // MARK: - complete
        
        let saveComplete = model.action
            .compactMap { $0 as? ModelAction.PaymentTemplate.Save.Complete }
            .map(\.paymentTemplateId)
        
        let updateComplete = model.action
            .compactMap { $0 as? ModelAction.PaymentTemplate.Update.Complete }
            .map(\.paymentTemplateId)
        
        let complete = Publishers.Merge(saveComplete, updateComplete)
            .map { State.complete(templateId: $0) }
        
        // MARK: - idle
        
        let idle = model.action
            .compactMap { $0 as? ModelAction.PaymentTemplate.Delete.Complete }
            .map { _ in State.idle }
        
        // MARK: - loading
        
        let saveRequested = model.action
            .compactMap { $0 as? ModelAction.PaymentTemplate.Save.Requested }
            .map { _ in () }
        
        let updateRequested = model.action
            .compactMap { $0 as? ModelAction.PaymentTemplate.Delete.Requested }
            .map { _ in () }
        
        let loading = Publishers.Merge(saveRequested, updateRequested)
            .map { _ in State.loading }
        
        // MARK: - Merged state update pipeline
        
        Publishers.Merge3(complete, idle, loading)
            .receive(on: scheduler)
            .assign(to: &$state)
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

// MARK: Sub Type's

extension TemplateButtonView.ViewModel {
    
    enum State {
        
        case idle
        case loading
        case refresh(templateId: Int)
        case complete(templateId: Int)
    }
}

extension TemplateButtonView.ViewModel.State {
    
    init(details: OperationDetailData) {
        
        if let templateId = details.paymentTemplateId {
            self = .complete(templateId: templateId)
        } else {
            self = .idle
        }
    }
}

// MARK: Action

extension TemplateButtonView.ViewModel {
    
    enum ButtonAction: Action {
        
        case tapAction
    }
}

// MARK: View Builder's

extension TemplateButtonView {
    
    @ViewBuilder
    private func bottomView(viewModel: TemplateButtonView.ViewModel) -> some View {
        
        HStack(spacing: 3) {
            
            viewModel.icon.map { icon in
                
                icon
                    .resizable()
                    .frame(width: 12, height: 12, alignment: .center)
                    .accessibilityIdentifier("TemplateButtonStatusIcon")
            }
            
            Text(viewModel.title)
                .font(.textBodySM12160())
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("TemplateButtonTitle")
        }
        .foregroundColor(foregroundColor)
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
            .accessibilityIdentifier("TemplateButtonIdle")
        }
    }
}

// MARK: LoadingView View

extension TemplateButtonView {
    
    struct LoadingView: View {
        
        @State private var isAnimating = false
        
        var body: some View {
            
            ZStack {
                
                Circle()
                    .fill(fillColor)
                    .frame(width: 56, height: 56)
                
                ThreeBounceAnimationView(color: isAnimating ? .black : .white)
            }
            .frame(height: 120)
            .onAppear {
                
                withAnimation(.linear(duration: 0.5)) {
                    
                    self.isAnimating = true
                }
            }
        }
        
        private var fillColor: Color {
            
            isAnimating ? .mainColorsGrayLightest : .systemColorActive
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
            .accessibilityIdentifier("TemplateButtonRefresh")
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
            .accessibilityIdentifier("TemplateButtonComplete")
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
        
        VStack(spacing: 20) {
            
            switch viewModel.state {
            case .idle:
                IdleView(tapAction: viewModel.tapAction)
                
            case .loading:
                LoadingView()
                
            case .refresh:
                RefreshView(tapAction: viewModel.tapAction)
                
            case .complete:
                CompleteView(tapAction: viewModel.tapAction)
            }
            
            bottomView(viewModel: viewModel)
        }
        .frame(maxWidth: 100)
    }
}

struct TemplateButtonView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        TemplateButtonView(viewModel: .preview(state: .idle))
            .previewDisplayName("idle state")
        
        TemplateButtonView(viewModel: .preview(state: .refresh(templateId: 1)))
            .previewDisplayName("refresh state")
        
        TemplateButtonView(viewModel: .preview(state: .loading))
            .previewDisplayName("loading state")
        
        TemplateButtonView(viewModel: .preview(state: .complete(templateId: 1)))
            .previewDisplayName("complete state")
    }
}

private extension TemplateButtonView.ViewModel {
    
    static func preview(state: State) -> TemplateButtonView.ViewModel {
        
        .init(model: .emptyMock, operation: nil, operationDetail: OperationDetailData.stub())
    }
}
