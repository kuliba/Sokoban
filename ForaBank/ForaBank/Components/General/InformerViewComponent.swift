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
        
        @Published var informers: [InformerData]
        @Published var informerViewModel: InformerViewModel?
        
        private let interval: TimeInterval
        private let closeAction: () -> Void
        
        private lazy var timer = Timer.publish(every: interval, on: .main, in: .common)
        
        private var timerBindings = Set<AnyCancellable>()
        private var bindings = Set<AnyCancellable>()
        
        struct InformerViewModel {
            
            let message: String
            let icon: Image
            let color: Color
            
            init(message: String, icon: Image, color: Color = .mainColorsBlack) {
                
                self.message = message
                self.icon = icon
                self.color = color
            }
        }
        
        init(interval: TimeInterval = 4, closeAction: @escaping () -> Void) {
            
            self.closeAction = closeAction
            self.interval = interval
            informers = []
            
            bind()
            startTimer()
        }
        
        convenience init(_ informerViewModel: InformerViewModel?) {
            
            self.init {}
            self.informerViewModel = informerViewModel
        }
        
        private func bind() {
            
            $informers
                .receive(on: DispatchQueue.main)
                .sink { [unowned self] informers in
                    
                    if informers.isEmpty == false, informerViewModel == nil {
                        makeInformerViewModel()
                    }
                    
                }.store(in: &bindings)
        }
        
        private func makeInformerViewModel() {
            
            let informer = informers.removeFirst()
            informerViewModel = .init(message: informer.message, icon: informer.icon, color: informer.color)
        }
        
        private func startTimer() {
            
            timer
                .autoconnect()
                .map { date in date.timeIntervalSinceReferenceDate }
                .sink { [unowned self] time in
                    
                    if informers.isEmpty == true {
                        
                        stopTimer()
                        
                    } else {
                        
                        makeInformerViewModel()
                    }
                    
                }.store(in: &timerBindings)
        }
        
        private func stopTimer() {
            
            for binding in timerBindings {
                binding.cancel()
            }
            
            closeAction()
            timerBindings = Set<AnyCancellable>()
        }
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

//MARK: - Preview

struct InformerViewComponent_Previews: PreviewProvider {
    static var previews: some View {

        Group {

            InformerView(viewModel: .init(.init(message: "USD счет открывается", icon: .ic24RefreshCw)))
            InformerView(viewModel: .init(.init(message: "USD счет открыт", icon: .ic16Check)))
            InformerView(viewModel: .init(.init(message: "USD счет не открыт", icon: .ic16Close)))
        }
        .previewLayout(.sizeThatFits)
        .padding(8)
    }
}
