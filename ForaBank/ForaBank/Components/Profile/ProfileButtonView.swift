//
//  ProfileButtonView.swift
//  ForaBank
//
//  Created by Дмитрий on 02.03.2022.
//

import SwiftUI

extension ProfileButtonView {
    
    class ViewModel: Identifiable, Hashable, ObservableObject {
            
        let id = UUID()
        let title: String
        let image: Image
        let state: State
        
        internal init(title: String, image: Image, state: State) {
            
            self.title = title
            self.image = image
            self.state = state
        }
        
        enum State {
            
            case active
            case disable
        }
        
    }
}


extension ProfileButtonView.ViewModel {
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(id)
    }

    static func == (lhs: ProfileButtonView.ViewModel, rhs: ProfileButtonView.ViewModel) -> Bool {
        
        return lhs.id == rhs.id
    }
}

struct ProfileButtonView: View {
    
    @ObservedObject var viewModel: ProfileButtonView.ViewModel
    
    var body: some View {
        
        if viewModel.state == .active {
         
            Button {
                
            } label: {
                
                HStack(spacing: 12) {
                    
                    viewModel.image
                        .foregroundColor(.iconBlack)
                    
                    Text(viewModel.title)
                        .font(.system(size: 14))
                        .foregroundColor(.buttonBlack)
                }
                .frame(width: 164, height: 48, alignment: .leading)
                .padding(.leading, 12)
            }
            .background(Color.mainColorsGrayLightest)
            .cornerRadius(8)
            
        } else {
            
            Button {
                
            } label: {
                
                HStack(spacing: 12) {
                    viewModel.image
                        .foregroundColor(.iconBlack)
                    Text(viewModel.title)
                        .font(.system(size: 14))
                        .foregroundColor(.buttonBlack)
                }
                .frame(width: 164, height: 48, alignment: .leading)
                .padding(.leading, 12)
            }

            .background(Color.mainColorsGrayLightest)
            .cornerRadius(8)
            .disabled(true)
            .opacity(0.3)
        }
    }
}

struct ProfileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            ProfileButtonView(viewModel: .ussualyButton)
                .previewLayout(.fixed(width: 200, height: 100))

            ProfileButtonView(viewModel: .disableButton)
                .previewLayout(.fixed(width: 200, height: 100))
            
            ProfileButtonView(viewModel: .requisitsButton)
                .previewLayout(.fixed(width: 200, height: 100))
            
            ProfileButtonView(viewModel: .transferButton)
                .previewLayout(.fixed(width: 200, height: 100))
        }
    }
}

extension ProfileButtonView.ViewModel {
    
    static let ussualyButton = ProfileButtonView.ViewModel(title: "Пополнить", image: Image.ic24Plus, state: .active)
    
    static let disableButton = ProfileButtonView.ViewModel(title: "Блокировать", image: Image.ic24Lock, state: .disable)
    
    static let requisitsButton = ProfileButtonView.ViewModel(title: "Реквизиты", image: Image.ic24File, state: .active)
    
    static let transferButton = ProfileButtonView.ViewModel(title: "Перевести", image: Image.ic24ArrowUpRight, state: .active)
}

