
//
//  AssetBalanceViewComponent.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 08.03.2022.
//

import Foundation
import SwiftUI

//MARK: - ViewModel

extension AssetBalanceView {
    
    class ViewModel: Identifiable, Equatable, ObservableObject {
        
        let id: UUID
        let icon: Image
        let cardLogo: Image
        let cardName: String
        let balance: String
        let subtitle: String
        @Published var offset: CGFloat
        
        internal init(id: UUID = UUID(), icon: Image, cardLogo: Image, cardName: String, balance: String, subtitle: String, offset: CGFloat = 0) {
            self.id = id
            self.icon = icon
            self.cardLogo = cardLogo
            self.cardName = cardName
            self.balance = balance
            self.subtitle = subtitle
            self.offset = offset
        }
        
        static func == (lhs: AssetBalanceView.ViewModel, rhs: AssetBalanceView.ViewModel) -> Bool {
            
            return lhs.id == rhs.id
        }
    }
}

//MARK: - View

struct AssetBalanceView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        ZStack {

            HStack{
                
                Color.yellow
                    .frame(width: 90)
                    .opacity(viewModel.offset > 0 ? 1 : 0)
                
                Spacer()
                
                Color.red
                    .frame(width: 90)
                    .opacity(viewModel.offset < 0 ? 1 : 0)
            }
            
            HStack {
                
                VStack {
                    viewModel.icon
                        .renderingMode(.original)
                    
                    Spacer()
                }
                
                VStack {
                    
                    HStack {
                        
                        viewModel.cardLogo
                            .renderingMode(.original)
                        
                        Text(viewModel.cardName)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Text(viewModel.balance)
                            .font(.textBodyMM14200())
                            .foregroundColor(.textSecondary)
                            .frame(alignment: .trailing)
                    }
                    .padding(.top, 4)
                    
                    HStack {
                        
                        Text(viewModel.subtitle)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                        
                        Spacer()
                    }
                    
                    Divider()
                }
            }
        }
        .offset(x: viewModel.offset)
        .frame(height: 56)
        .padding(.top, 4)
    }
}

//MARK: - Preview

struct AssetBalanceView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        AssetBalanceView(viewModel: .sample1)
    }
}

//MARK: - Preview Content

extension AssetBalanceView.ViewModel {
    
    static let sample1 =  AssetBalanceView.ViewModel.init(icon: .ic32LogoForaLine,
                                                         cardLogo: .ic24Visa,
                                                         cardName: "Platinum1",
                                                         balance: "19 547 ₽",
                                                         subtitle: "⚫️ 2953 ⚫️ Корпоративная")
    
    static let sample2 =  AssetBalanceView.ViewModel.init(icon: .ic32LogoForaLine,
                                                         cardLogo: .ic24Visa,
                                                         cardName: "Platinum2",
                                                         balance: "19 547 ₽",
                                                         subtitle: "⚫️ 2953 ⚫️ Корпоративная")
    
    static let sample3 =  AssetBalanceView.ViewModel.init(icon: .ic32LogoForaLine,
                                                         cardLogo: .ic24Visa,
                                                         cardName: "Platinum3",
                                                         balance: "19 547 ₽",
                                                         subtitle: "⚫️ 2953 ⚫️ Корпоративная")
    
    static let sample4 =  AssetBalanceView.ViewModel.init(icon: .ic32LogoForaLine,
                                                         cardLogo: .ic24Visa,
                                                         cardName: "Platinum4",
                                                         balance: "19 547 ₽",
                                                         subtitle: "⚫️ 2953 ⚫️ Корпоративная")
}
