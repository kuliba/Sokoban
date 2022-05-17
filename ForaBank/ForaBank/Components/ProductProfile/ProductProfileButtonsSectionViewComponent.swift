//
//  ProductProfileButtonsSectionView.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI
import Combine

//MARK: - ViewModel

extension ProductProfileButtonsSectionView {
    
    class ViewModel: Identifiable, Hashable, ObservableObject {
        
        let action: PassthroughSubject<Action, Never> = .init()

        let id = UUID()
        var buttons: [[ProductProfileButtonView.ViewModel]]
        let kind: ProductType
        
        internal init(kind: ProductType) {
            
            self.kind = kind

            switch kind {
            case .card:
                
                self.buttons = [[.init(title: .pay, image: Image.ic24Plus), .init(title: .transfer, image: Image.ic24ArrowUpRight)],[.init(title: .requisites, image: Image.ic24File), .init(title: .block, image: Image.ic24Lock)]]

            case .account:
                
                self.buttons = [[.init(title: .pay, image: Image.ic24Plus), .init(title: .transfer, image: Image.ic24ArrowUpRight)],[.init(title: .requisites, image: Image.ic24File), .init(title: .close, image: Image.ic24Lock, state: false)]]

            case .deposit:
                
                self.buttons = [[.init(title: .pay, image: Image.ic24Plus), .init(title: .transfer, image: Image.ic24ArrowUpRight, state: false)],[.init(title: .details, image: Image.ic24File), .init(title: .control, image: Image.ic24Server, state: false)]]

            case .loan:
                
                self.buttons = [[.init(title: .pay, image: Image.ic24Plus), .init(title: .control, image: Image.ic24Server)],[.init(title: .requisites, image: Image.ic24File), .init(title: .repay, image: Image.ic24Clock)]]

            }
        }
    }
}

extension ProductProfileButtonsSectionView.ViewModel {
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
    }

    static func == (lhs: ProductProfileButtonsSectionView.ViewModel, rhs: ProductProfileButtonsSectionView.ViewModel) -> Bool {
        
        return lhs.id == rhs.id
    }
}

//MARK: - View

struct ProductProfileButtonsSectionView: View {
    
    @ObservedObject var viewModel: ProductProfileButtonsSectionView.ViewModel
    
    var body: some View {

            VStack(spacing: 8) {
  
                ForEach(viewModel.buttons, id: \.self) { row in
                    
                    HStack(spacing: 8) {
                        
                        ForEach(row) { button in
                            
                            ProductProfileButtonView(viewModel: button)
                        }
                    }
                }
            }
    }
}

//MARK: - Preview

struct ProfileButtonsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProductProfileButtonsSectionView(viewModel: .sample)
                .previewLayout(.fixed(width: 350, height: 104))
    }
}

//MARK: - Preview Content

extension ProductProfileButtonsSectionView.ViewModel {
    
    static let sample = ProductProfileButtonsSectionView.ViewModel(kind: .card)
}
