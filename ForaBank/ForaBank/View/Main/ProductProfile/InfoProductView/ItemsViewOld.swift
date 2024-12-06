//
//  ItemsViewOld.swift
//  Vortex
//
//  Created by Andryusina Nataly on 22.06.2023.
//

import SwiftUI

struct ItemsViewOld: View {
    
    let items: [InfoProductViewModel.ItemViewModel]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 24) {
            
            ForEach(items, id: \.self) { item in
                
                InfoProductView.ButtonView(viewModel: item)
            }
        }
        .padding(.top, 28)
        .padding(.horizontal, 20)
        .frame(alignment: .leading)
    }
}

struct InfoProductViewOld_Previews: PreviewProvider {
    static var previews: some View {
        
        ItemsViewOld(items: InfoProductViewModel.list)
    }
}

