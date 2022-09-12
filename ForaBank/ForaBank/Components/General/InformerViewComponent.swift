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
        
        @Published var informerViewModel: InformerViewModel?

        private let model: Model
        private var events: [Event]
        private let timer = Timer.publish(every: 1, on: .main, in: .common)
        
        private var currentEvent: (event: Event, startTime: TimeInterval)?
        private var timerBindings = Set<AnyCancellable>()
        private var bindings = Set<AnyCancellable>()
        
        init(informerViewModel: InformerViewModel?, model: Model, events: [Event]) {
            
            self.model = model
            self.informerViewModel = informerViewModel
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
                        
                        let informerViewModel: InformerViewModel = .init(message: payload.message, icon: payload.icon.image, color: payload.color, interval: payload.interval)
                        
                        events.append(.informer(informerViewModel))
                        events.append(.pause(1))
                        
                        if currentEvent == nil {
                            startTimer()
                        }
                        
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
                            
                            guard time - currentEvent.startTime > pause else {
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
                    self.informerViewModel = informerViewModel
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
                informerViewModel = nil
            }
            
            currentEvent = nil
        }
    }
}

extension InformerView {
    
    struct InformerViewModel {
        
        let message: String
        let icon: Image
        let color: Color
        let interval: TimeInterval
        
        init(message: String, icon: Image, color: Color = .mainColorsBlack, interval: TimeInterval = 2) {
            
            self.message = message
            self.icon = icon
            self.color = color
            self.interval = interval
        }
    }
    
    enum Event {
        
        case informer(InformerViewModel)
        case pause(TimeInterval)
    }
}

// MARK: - View

struct InformerView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        if let informerViewModel = viewModel.informerViewModel {
            
            ZStack {
                
                HStack(spacing: 10) {
                    
                    informerViewModel.icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.mainColorsWhite)
                    
                    Text(informerViewModel.message)
                        .font(.textH4R16240())
                        .foregroundColor(.mainColorsWhite)
                }
                .padding([.leading, .trailing], 16)
                .padding([.top, .bottom], 12)
                
            }
            .background(informerViewModel.color)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(informerViewModel.color.opacity(0.5), lineWidth: 1))
            
        } else {
            
            EmptyView()
        }
    }
}

// MARK: - Preview Content

extension InformerView.ViewModel {
    
    static let sample1: InformerView.ViewModel = .init(informerViewModel: .init(message: "USD счет открывается", icon: .ic24RefreshCw), model: .emptyMock, events: [])
    
    static let sample2: InformerView.ViewModel = .init(informerViewModel: .init(message: "USD счет открыт", icon: .ic16Check), model: .emptyMock, events: [])
    
    static let sample3: InformerView.ViewModel = .init(informerViewModel: .init(message: "USD счет не открыт", icon: .ic16Close), model: .emptyMock, events: [])
}

//MARK: - Preview

struct InformerViewComponent_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            
            InformerView(viewModel: .sample1)
            InformerView(viewModel: .sample2)
            InformerView(viewModel: .sample3)
        }
        .previewLayout(.sizeThatFits)
        .padding(8)
    }
}
