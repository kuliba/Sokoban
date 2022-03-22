//
//  AllMoneyView.swift
//  ForaBank
//
//  Created by Андрей Лятовец on 08.03.2022.
//

import Foundation
import SwiftUI

//MARK: - View

struct AllMoneyView: View {
    
    @ObservedObject var viewModel: AllMoneyViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack() {
                
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(.barsTabbar)
                
                VStack(spacing: 0) {
                    
                    HStack {
                        Text(viewModel.topView.title)
                            .padding(.leading, 20)
                            .font(.textH2SB20282())
                        Spacer()
                        
                        Text(viewModel.topView.balance)
                            .padding(.trailing, 7)
                            .font(.textH2SB20282())
                        
                        currencyButton
                            .padding(.trailing, 19)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 4)
                    
                    HStack {
                        
                        Spacer()
                        
                        Text(viewModel.topView.actionSubtitle)
                            .font(.textBodySR12160())
                            .foregroundColor(.textPlaceholder)
                            .padding(.trailing, 19)
                        
                    }
                    .padding(.bottom, 12)
                }
            }
            .frame(height: 76)
            .padding(.bottom, 16)
            
            ScrollView {
                
                ForEach(viewModel.items) { itemViewModel in
                    
                    MyProductsSectionAllMoneyView(viewModel: itemViewModel)
                        .padding(.leading, 20)
                        .padding(.trailing, 19)
                        .padding(.bottom, 16)
                }
            }.background(Color.mainColorsWhite)
        }
        .navigationBarTitle(Text(viewModel.navigationBar.title).font(.textH3M18240()),
                            displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .navigationBarItems(trailing: addButton)
    }
    
    var backButton: some View {

        Button(action: {}){
            HStack {
                Image.ic24ChevronLeft
                    .foregroundColor(.black)
            }
        }
    }

    var addButton: some View {

        Button(action: viewModel.navigationBar.addAction){
            Image.ic24Plus
                .foregroundColor(.textPlaceholder)
        }
    }
    var currencyButton: some View {
        
        Button(action: {}) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.buttonPrimaryDisabled)
                    .frame(width: 40, height: 24)
                
                HStack(spacing: 3) {
                    
                    Text(viewModel.topView.buttonLabel)
                        .foregroundColor(.textWhite)
                    
                    Image.ic16ChevronDown
                        .foregroundColor(.iconWhite)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

//MARK: - Preview

struct AllMoneyView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            AllMoneyView(viewModel: .sample)
        }
    }
}

//MARK: - Preview Content

extension AllMoneyViewModel {
    
    static let sample = AllMoneyViewModel(navigationBar: .init(title: "Мои продукты",
                                                               addAction: {}),
                                          topView: .init(title: "Всего денег",
                                                         balance: "170 897",
                                                         buttonLabel: "₽",
                                                         actionSubtitle: "По курсу ЦБ",
                                                         buttonAction: {}),
                                          items: [.sample1, .sample2, .sample3])
}
