//
//  PaymentsSuccessTransferNumberComponent.swift
//  ForaBank
//
//  Created by Max Gribov on 23.06.2023.
//

import SwiftUI

extension PaymentsSuccessTransferNumberView {
    
    final class ViewModel: PaymentsParameterViewModel, ObservableObject {
        
        let title: String
        @Published private(set) var state: State
        
        enum State {
            
            case copy
            case check
        }
        
        init(
            title: String,
            state: State,
            source: PaymentsParameterRepresentable
        ) {
            self.title = title
            self.state = state
            
            super.init(source: source)
        }
        
        convenience init(_ source: Payments.ParameterSuccessTransferNumber) {
            
            self.init(title: source.value ?? "", state: .copy, source: source)
        }
        
        func copyButtonDidTapped() {
            
            UIPasteboard.general.string = source.value
            
            state = .check
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + .milliseconds(300)
            ) { [weak self] in self?.state = .copy }
        }
    }
}

struct PaymentsSuccessTransferNumberView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        HStack {
            
            Text(viewModel.title)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.black)
                .padding(.leading, 6)
            
            switch viewModel.state {
            case .copy:
                Button(action: viewModel.copyButtonDidTapped) {
                    
                    icon(.ic24Copy)
                }
                .padding(6)
                
            case .check:
                icon(.ic24Check)
                    .padding(6)
            }
        }
        .padding(8)
        .background(Color(hex: "F6F6F7"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.default, value: viewModel.state)
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
            state: .copy,
            source: source
        )
    }
}
