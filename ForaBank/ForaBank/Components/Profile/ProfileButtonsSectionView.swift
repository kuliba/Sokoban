//
//  ProfileButtonsSectionView.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI

extension ProfileButtonsSectionView {
    
    class ViewModel: Identifiable, Hashable, ObservableObject {
        
        let id = UUID()
        var buttons: [[ProfileButtonView.ViewModel]]
        let kind: ProductType
        
        internal init(kind: ProductType) {
            
            self.kind = kind

            switch kind {
            case .card:
                
                self.buttons = [[.init(title: .topUp, image: Image.ic24Plus), .init(title: .transfer, image: Image.ic24ArrowUpRight)],[.init(title: .requisites, image: Image.ic24File), .init(title: .block, image: Image.ic24Lock, state: false)]]

            case .account:
                
                self.buttons = [[.init(title: .topUp, image: Image.ic24Plus), .init(title: .transfer, image: Image.ic24ArrowUpRight)],[.init(title: .requisites, image: Image.ic24File), .init(title: .block, image: Image.ic24Lock, state: false)]]

            case .deposit:
                
                self.buttons = [[.init(title: .topUp, image: Image.ic24Plus), .init(title: .transfer, image: Image.ic24ArrowUpRight)],[.init(title: .requisites, image: Image.ic24File), .init(title: .block, image: Image.ic24Lock, state: false)]]

            case .loan:
                
                self.buttons = [[.init(title: .topUp, image: Image.ic24Plus), .init(title: .transfer, image: Image.ic24ArrowUpRight)],[.init(title: .requisites, image: Image.ic24File), .init(title: .block, image: Image.ic24Lock, state: false)]]

            }
        }
    }
}

extension ProfileButtonsSectionView.ViewModel {
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
    }

    static func == (lhs: ProfileButtonsSectionView.ViewModel, rhs: ProfileButtonsSectionView.ViewModel) -> Bool {
        
        return lhs.id == rhs.id
    }
}

struct ProfileButtonsSectionView: View {
    
    @ObservedObject var viewModel: ProfileButtonsSectionView.ViewModel
    
    var body: some View {

            VStack(spacing: 8) {
  
                ForEach(viewModel.buttons, id: \.self) { row in
                    
                    HStack(spacing: 8) {
                        
                        ForEach(row) { button in
                            
                            ProfileButtonView(viewModel: button)
                        }
                    }
                }
            }
    }
}

struct ProfileButtonsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProfileButtonsSectionView(viewModel: .sample)
                .previewLayout(.fixed(width: 350, height: 104))
    }
}

extension ProfileButtonsSectionView.ViewModel {
    
    static let sample = ProfileButtonsSectionView.ViewModel(kind: .card)
}
