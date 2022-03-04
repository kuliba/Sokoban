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
        
        override var type: MainSectionType { .fastOperations }
        let items: [ButtonIconTextView.ViewModel]

        internal init(items: [ButtonIconTextView.ViewModel], isCollapsed: Bool) {
            
            self.items = items
            super.init(isCollapsed: isCollapsed)
        }
    }
}


//MARK: - View

struct MainSectionFastOperationView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        MainSectionCollapsableView(title: viewModel.title, isCollapsed: $viewModel.isCollapsed) {
            
            ScrollView(.horizontal) {
                
                HStack(spacing: 4) {
                    
                    ForEach(viewModel.items) { itemViewModel in
                       
                        ButtonIconTextView(viewModel: itemViewModel)
                    }
                }
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
    
    static let sample = MainSectionFastOperationView.ViewModel(items:[.qrPayment, .telephoneTranslation, .templates], isCollapsed: false)
}
