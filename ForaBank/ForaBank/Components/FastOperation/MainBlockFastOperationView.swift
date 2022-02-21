//
//  MainBlockFastOperationView.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 21.02.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension MainBlockFastOperationView {
    
    class ViewModel: ObservableObject {

        let buttonIconTextViewModels: [ButtonIconTextView.ViewModel]
        let title: String
        @Published var isCollapsed: Bool
        
        internal init(buttonIconTextViewModels: [ButtonIconTextView.ViewModel], title: String, isCollapsed: Bool) {
            self.buttonIconTextViewModels = buttonIconTextViewModels
            self.title = title
            self.isCollapsed = isCollapsed
        }
    }
}


//MARK: - View

struct MainBlockFastOperationView: View {

    @ObservedObject var viewModel: ViewModel

    var body: some View {

        VStack {
            
            Button {
                viewModel.isCollapsed.toggle()
                } label: {
                    HStack {
                        Text(viewModel.title)
                            .font(.textH2SB20282())
                            .foregroundColor(.textSecondary)
                    
                       if viewModel.isCollapsed {
                           Image.ic24ChevronUp
                               .foregroundColor(.iconGray)
                       } else {
                           Image.ic24ChevronDown
                               .foregroundColor(.iconGray)
                       }
                    
                    Spacer()
                }
            }
            .padding(.leading, 20)
            
            if !viewModel.isCollapsed {
                ScrollView(.horizontal) {
                    HStack(spacing: 4) {
                        ForEach(viewModel.buttonIconTextViewModels, id: \.self) { buttonIconTextViewModels in
                            ButtonIconTextView(viewModel: buttonIconTextViewModels )
                        }
                    }
                }
                .frame(height: 96)
            }
        }
    }
}

//MARK: - Preview

struct MainBlockFastOperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainBlockFastOperationView(viewModel: .sample)
    }
}

//MARK: - Preview Content

extension MainBlockFastOperationView.ViewModel {
    
    static let sample = MainBlockFastOperationView.ViewModel(buttonIconTextViewModels:
                                                                [ButtonIconTextView.ViewModel.qrPayment,
                                                                 ButtonIconTextView.ViewModel.telephoneTranslation,
                                                                 ButtonIconTextView.ViewModel.templates],
                                                             title: "Быстрые операции",
                                                             isCollapsed: false)
}
