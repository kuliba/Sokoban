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
        @Published var showInformer: Bool
        
        private lazy var timer = Timer.publish(every: interval, on: .main, in: .common)
        
        private let interval: TimeInterval
        private let closeAction: () -> Void
        
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
        
        init(interval: TimeInterval = 3, closeAction: @escaping () -> Void) {
            
            self.interval = interval
            self.closeAction = closeAction
            
            informers = []
            showInformer = true
            
            bind()
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
                        startTimer()
                    }
                    
                }.store(in: &bindings)
        }
        
        private func makeInformerViewModel() {
            
            guard informers.isEmpty == false else {
                return
            }
            
            let informer = informers.removeFirst()
            
            withAnimation {
                informerViewModel = .init(message: informer.message, icon: informer.icon, color: informer.color)
            }
        }
        
        private func startTimer() {
            
            timer
                .autoconnect()
                .sink { [unowned self] _ in
                    
                    if informers.isEmpty == false {
                        
                        makeInformerViewModel()
                        
                    } else {
                        
                        reset()
                        stopTimer()
                    }
                    
                }.store(in: &timerBindings)
        }
        
        private func stopTimer() {
            
            for binding in timerBindings {
                binding.cancel()
            }
            
            timerBindings = Set<AnyCancellable>()
        }
        
        private func reset() {
            
            closeAction()
            informerViewModel = nil
            showInformer = false
        }
    }
}

// MARK: - View

struct InformerView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        if let informerViewModel = viewModel.informerViewModel, viewModel.showInformer == true {
            
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
