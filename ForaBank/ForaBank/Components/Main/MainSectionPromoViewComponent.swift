//
//  MainSectionPromoViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 04.03.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension MainSectionPromoView {
    
    class ViewModel: MainSectionViewModel {
        
        override var type: MainSectionType { .promo }
        let items: [PromotionViewModel]
        
        internal init(items: [PromotionViewModel]) {
            
            self.items = items
            super.init()
        }
    }
    
    struct PromotionViewModel: Identifiable {

        let id: UUID
        let image: Image
        let action: () -> Void

        internal init(id: UUID = UUID(), image: Image, action: @escaping () -> Void) {

            self.id = id
            self.image = image
            self.action = action
        }
    }
}

//MARK: - View

struct MainSectionPromoView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.items) { promotionViewModel in
                    Button {
                        
                        promotionViewModel.action()
                        
                    } label: {
                        
                        promotionViewModel.image
                            .frame(width: 288, height: 124)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
}
//MARK: - Preview

struct MainSectionPromotionsView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionPromoView(viewModel: .sample)
            .previewLayout(.fixed(width: 375, height: 300))
    }
}

//MARK: - Preview Content

extension MainSectionPromoView.ViewModel {

    static let sample = MainSectionPromoView.ViewModel(items: [.init(image: Image("Promo Banner Cashback"), action: {}), .init(image: Image("Promo Banner Mig"), action: {})])
}
