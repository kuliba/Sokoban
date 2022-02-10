//
//  AuthConfirmView.swift
//  ForaBank
//
//  Created by Дмитрий on 10.02.2022.
//

import SwiftUI

struct AuthConfirmView: View {
    
    var viewModel: AuthConfirmViewModel

    var body: some View {
        NavigationView{
            Text("")
        }
    }
}

struct AuthConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        AuthConfirmView(viewModel: AuthConfirmViewModel())
    }
}
