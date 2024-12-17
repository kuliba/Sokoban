//
//  NoCompanyInListView.swift
//  ForaBank
//
//  Created by Andryusina Nataly on 16.05.2023.
//

import Foundation
import SwiftUI

struct NoCompanyInListView: View {
    
    let viewModel: NoCompanyInListViewModel
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            VStack(spacing: 16) {
                
                Text(viewModel.title)
                    .font(.textH3Sb18240())
                    .foregroundColor(.textSecondary)
                
                Text(viewModel.content)
                    .font(.textBodyMR14200())
                    .foregroundColor(.textPlaceholder)
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                
                VStack(spacing: 8) {
                    
                    ForEach(viewModel.buttons) { button in
                        
                        ButtonSimpleView(viewModel: button)
                            .frame(height: 56)
                            .padding(.horizontal, 16)
                    }
                }
                
                Text(viewModel.subtitle)
                    .font(.textBodyMR14200())
                    .foregroundColor(Color.textPlaceholder)
                    .padding(.horizontal, 16)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct NoCompanyInListView_Previews: PreviewProvider {
    static var previews: some View {
        
        NoCompanyInListView.init(viewModel: .init(title: NoCompanyInListViewModel.defaultTitle, content: NoCompanyInListViewModel.defaultContent, subtitle: NoCompanyInListViewModel.defaultSubtitle, addCompanyAction: {}, requisitesAction: {}))
    }
}
