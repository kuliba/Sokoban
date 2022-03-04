//
//  MainSectionFastOperationViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 21.02.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension MainSectionFastOperationView {
    
    class ViewModel: MainSectionCollapsableViewModel {
        
        let items: [ButtonIconTextView.ViewModel]
        let title: String
        
        internal init(items: [ButtonIconTextView.ViewModel], title: String, isCollapsed: Bool) {
            
            self.items = items
            self.title = title
            super.init(isCollapsed: isCollapsed)
        }
    }
}


//MARK: - View

struct MainSectionFastOperationView: View {
    
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
                        ForEach(viewModel.items) { itemViewModel in
                            ButtonIconTextView(viewModel: itemViewModel)
                        }
                    }
                }
                .frame(height: 96)
            }
        }
    }
}

//MARK: - Preview

struct MainSectionFastOperationView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionFastOperationView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionFastOperationView.ViewModel {
    
    static let sample = MainSectionFastOperationView.ViewModel(items:
                                                                [ButtonIconTextView.ViewModel.qrPayment,
                                                                 ButtonIconTextView.ViewModel.telephoneTranslation,
                                                                 ButtonIconTextView.ViewModel.templates],
                                                               title: "Быстрые операции",
                                                               isCollapsed: false)
}
