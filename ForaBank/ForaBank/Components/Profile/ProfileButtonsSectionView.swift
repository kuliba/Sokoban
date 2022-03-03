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
        let buttons: [[ProfileButtonView.ViewModel]]

        internal init(buttons: [[ProfileButtonView.ViewModel]]) {
            
            self.buttons = buttons
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
            .padding(20)
    }
}

struct ProfileButtonsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        
        ProfileButtonsSectionView(viewModel: .init(buttons: [[.ussualyButton, .transferButton],[ .requisitsButton, .disableButton]]))
                .previewLayout(.fixed(width: 350, height: 104))
    }
}
