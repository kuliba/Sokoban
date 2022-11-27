//
//  QRSearchOperatorView.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.11.2022.
//

import SwiftUI

struct QRSearchOperatorView: View {
    
    @ObservedObject var viewModel: QRSearchOperatorViewModel
    @State private var username: String = ""
    
    var body: some View {
        
        TextField(viewModel.textFieldPlaceholder, text: $username)
            .padding(20)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                
                }) { Image("back_button") })
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    
                    HStack {
                        
                        Text(viewModel.navigationBar.title).font(.headline)
                        
                        Button {
                            viewModel.navigationBar.changeRegionButton.action()
                        } label: {
                            viewModel.navigationBar.changeRegionButton.icon
                        }
                    }
                }
            }
    }
}

struct QRSearchOperatorView_Previews: PreviewProvider {
    static var previews: some View {
        QRSearchOperatorView.init(viewModel: .init(textFieldPlaceholder: "Название или ИНН", navigationBar: .init(action: {}), operators: [], model: .emptyMock))
    }
}
