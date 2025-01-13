//
//  PaymentsSuccessTransferNumberComponent.swift
//  Vortex
//
//  Created by Max Gribov on 23.06.2023.
//

import CombineSchedulers
import SwiftUI

extension PaymentsSuccessTransferNumberView {
    
    final class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let title: String
        @Published private(set) var state: State
        
        private let timeout: Timeout
        private let scheduler: AnySchedulerOf<DispatchQueue>
        
        typealias Timeout = DispatchQueue.SchedulerTimeType.Stride
        
        enum State {
            
            case copy
            case check
        }
        
        init(
            title: String,
            state: State,
            source: PaymentsParameterRepresentable,
            timeout: Timeout = .seconds(2),
            scheduler: AnySchedulerOf<DispatchQueue> = .main
        ) {
            self.title = title
            self.state = state
            self.timeout = timeout
            self.scheduler = scheduler
            
            super.init(source: source)
        }
        
        convenience init(
            _ source: Payments.ParameterSuccessTransferNumber,
            timeout: Timeout = .seconds(2),
            scheduler: AnySchedulerOf<DispatchQueue> = .main
        ) {
            self.init(
                title: source.value ?? "", 
                state: .copy,
                source: source,
                timeout: timeout,
                scheduler: scheduler
            )
        }
        
        func copyButtonDidTapped() {
            
            UIPasteboard.general.string = source.value
            
            state = .check
            
            scheduler.delay(for: timeout) { [weak self] in
                
                self?.state = .copy
            }
        }
    }
}

struct PaymentsSuccessTransferNumberView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        Group {
            
            switch viewModel.state {
            case .copy:  button(label(image: .ic24Copy))
            case .check: label(image: .ic24Check)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "F6F6F7"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.default, value: viewModel.state)
    }
    
    private func button(
       _ label: @autoclosure () -> some View
    ) -> some View {
        
        Button(action: viewModel.copyButtonDidTapped, label: label)
    }
    
    private func label(image: Image) -> some View {
        
        HStack(spacing: 8) {
            
            title()
            icon(image)
        }
    }
    
    private func title() -> some View {
        
        Text(viewModel.title)
            .font(.textBodyMM14200())
            .foregroundColor(.textSecondary)
    }
    
    private func icon(_ image: Image) -> some View {
        
        image
            .resizable()
            .foregroundColor(.iconGray)
            .frame(width: 24, height: 24)
    }
}

struct PaymentsSuccessTransferNumberView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        Group {
            
            VStack(spacing: 32, content: previewsGroup)
                .previewDisplayName("Xcode 14+")
            
            previewsGroup()
        }
    }
    
    private static func previewsGroup() -> some View {
        
        Group {
            
            PaymentsSuccessTransferNumberView(viewModel: .preview(.check))
                .previewDisplayName("check")
            
            PaymentsSuccessTransferNumberView(viewModel: .preview(.copy))
                .previewDisplayName("copy")
        }
    }
}

private extension PaymentsSuccessTransferNumberView.ViewModel {
    
    static func preview(
        transferNumber: String = "219771514",
        _ state: PaymentsSuccessTransferNumberView.ViewModel.State
    ) -> PaymentsSuccessTransferNumberView.ViewModel {
        
        let source = Payments.ParameterSuccessTransferNumber(
            number: transferNumber
        )
        
        return .init(
            title: transferNumber,
            state: state,
            source: source
        )
    }
}
