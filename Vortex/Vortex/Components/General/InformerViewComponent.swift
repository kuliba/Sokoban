//
//  InformerViewComponent.swift
//  ForaBank
//
//  Created by Pavel Samsonov on 30.06.2022.
//

import SwiftUI
import Combine

// MARK: - ViewModel

extension InformerView {
    
    class ViewModel: ObservableObject {
        
        @Published var informerItemViewModel: InformerItemViewModel?

        private let model: Model
        private var events: [Event]
        private let timer = Timer.publish(every: 1, on: .main, in: .common)
        
        private var currentEvent: (event: Event, startTime: TimeInterval)?
        private var timerBindings = Set<AnyCancellable>()
        private var bindings = Set<AnyCancellable>()
        
        init(informerViewModel: InformerItemViewModel?, model: Model, events: [Event]) {
            
            self.model = model
            self.informerItemViewModel = informerViewModel
            self.events = events
        }
        
        convenience init(_ model: Model) {
            
            self.init(informerViewModel: nil, model: model, events: [])
            bind()
        }
        
        deinit {
            
            stopTimer()
        }
 
        private func bind() {
            
            model.action
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] action in
                    
                    switch action {
                    case let payload as ModelAction.Informer.Show:
                        
                        let informer = payload.informer
                        
                        let informerViewModel: InformerItemViewModel = .init(message: informer.message, icon: informer.icon.image, color: informer.color, interval: informer.interval, type: informer.type)
                        
                        let pauseViewModel: PauseItemViewModel = .init(interval: 1, type: informer.type)
                        
                        events.append(.informer(informerViewModel))
                        events.append(.pause(pauseViewModel))
                        
                        if currentEvent == nil {
                            startTimer()
                        }
                        
                    case let payload as ModelAction.Informer.Dismiss:
                        cancelInformers(for: payload.type)
                        
                    default:
                        break
                    }
                    
                }.store(in: &bindings)
        }
        
        private func startTimer() {
            
            timer
                .autoconnect()
                .map { $0.timeIntervalSinceReferenceDate }
                .sink { [unowned self] time in
                    
                    if let currentEvent = currentEvent {
                        
                        switch currentEvent.event {
                        case .informer(let informerViewModel):
                            
                            guard time - currentEvent.startTime > informerViewModel.interval else {
                                return
                            }
                            
                            resetInformer()
                            makeNextEvent(time)
                            
                        case let .pause(pause):
                            
                            guard time - currentEvent.startTime > pause.interval else {
                                return
                            }
                            
                            resetInformer()
                            makeNextEvent(time)
                        }
                        
                    } else {
                        
                        makeNextEvent(time)
                    }
                    
                }.store(in: &timerBindings)
        }
        
        private func makeNextEvent(_ time: TimeInterval) {
            
            guard events.isEmpty == false else {
                
                stopTimer()
                return
            }
            
            let nextEvent = events.removeFirst()
            currentEvent = (nextEvent, time)
            
            switch nextEvent {
            case .informer(let informerViewModel):
                
                withAnimation {
                    self.informerItemViewModel = informerViewModel
                }
            
            default:
                break
            }
        }

        private func stopTimer() {
            
            for binding in timerBindings {
                binding.cancel()
            }
            
            timerBindings = Set<AnyCancellable>()
        }
        
        private func resetInformer() {
                        
            withAnimation {
                informerItemViewModel = nil
            }
            
            currentEvent = nil
        }
        
        private func cancelInformers(for type: InformerData.CancelableType) {
            
            self.events = events.filter { event -> Bool in
                
                switch event {
                case let .informer(informerViewModel):
                    
                    if let type = informerViewModel.type {
                        
                        switch type {
                        case .openAccount:
                            return false
                        case .copyInfo:
                            return false
                        }
                    }
                    
                case let .pause(pauseViewModel):
                    
                    if let type = pauseViewModel.type {
                        
                        switch type {
                        case .openAccount:
                            return false
                        case .copyInfo:
                            return false
                        }
                    }
                }
                
                return true
            }
            
            resetInformer()
        }
    }
}

extension InformerView {
    
    struct InformerItemViewModel {
        
        let message: String
        let icon: Image
        let color: Color
        let interval: TimeInterval
        let type: InformerData.CancelableType?
        
        init(message: String, icon: Image, color: Color = .mainColorsBlack, interval: TimeInterval = 2, type: InformerData.CancelableType? = nil) {
            
            self.message = message
            self.icon = icon
            self.color = color
            self.interval = interval
            self.type = type
        }
    }
    
    struct PauseItemViewModel {
        
        let interval: TimeInterval
        let type: InformerData.CancelableType?
        
        init(interval: TimeInterval = 2, type: InformerData.CancelableType? = nil) {
            
            self.interval = interval
            self.type = type
        }
    }
    
    enum Event {
        
        case informer(InformerItemViewModel)
        case pause(PauseItemViewModel)
    }
}

// MARK: - View

struct InformerView: View {
    
    let viewModel: InformerItemViewModel
    
    var body: some View {
        
        InformerInternalView(
            message: viewModel.message,
            icon: viewModel.icon,
            color: viewModel.color
        )
    }
}
        
struct InformerInternalView: View {
    
    let message: String
    let icon: Image
    let color: Color
    
    var body: some View {
        
        HStack(spacing: 10) {
            
            icon
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.mainColorsWhite)
            
            Text(message)
                .font(.textH4R16240())
                .foregroundColor(.mainColorsWhite)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding([.leading, .trailing], 16)
        .padding([.top, .bottom], 12)
        .background(color)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.5), lineWidth: 1))
    }
}

// MARK: - Preview Content

extension InformerView.InformerItemViewModel {
    
    static let sample1: InformerView.InformerItemViewModel = .init(
        message: "USD счет открывается", 
        icon: .ic24RefreshCw
    )
    static let sample2: InformerView.InformerItemViewModel = .init(
        message: "USD счет открывается", 
        icon: .ic16Check
    )
    static let sample3: InformerView.InformerItemViewModel = .init(
        message: "USD счет открывается", 
        icon: .ic16Close
    )
}

// MARK: - Preview

struct InformerViewComponent_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            VStack(spacing: 32, content: previewsGroup)
                .previewDisplayName("Xcode 14+")
            
            previewsGroup()
        }
    }
    
    private static func previewsGroup() -> some View {
        
        Group {
            
            InformerView(viewModel: .sample1)
            InformerView(viewModel: .sample2)
            InformerView(viewModel: .sample3)
        }
        .previewLayout(.sizeThatFits)
        .padding(8)
    }
}
