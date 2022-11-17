//
//  QRSearchOperatorView.swift
//  ForaBank
//
//  Created by Константин Савялов on 17.11.2022.
//

import SwiftUI

struct QRSearchOperatorView: View {
    
    @ObservedObject var viewModel: QRSearchOperatorViewModel
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct QRSearchOperatorView_Previews: PreviewProvider {
    static var previews: some View {
        QRSearchOperatorView.init(viewModel: .init())
    }
}
