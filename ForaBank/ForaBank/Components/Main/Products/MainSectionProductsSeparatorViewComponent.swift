//
//  MainSectionProductsSeparatorView.swift
//  ForaBank
//
//  Created by Max Gribov on 18.05.2022.
//

import SwiftUI

extension MainSectionProductsSeparatorView {
    
    class ViewModel: MainSectionProductsListItemViewModel {}
}

struct MainSectionProductsSeparatorView: View {
    
    let viewModel: ViewModel
    
    var body: some View {
        
        Capsule(style: .continuous)
            .frame(width: 1)
            .foregroundColor(.mainColorsGrayLightest)
            .padding(.vertical, 40)
    }
}

struct MainSectionProductsSeparatorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        MainSectionProductsSeparatorView(viewModel: .init())
            .previewLayout(.fixed(width: 375, height: 200))
    }
}
