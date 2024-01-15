//
//  InformerView.swift
//  FastPaymentsSettingsPreview
//
//  Created by Igor Malyarov on 12.01.2024.
//

import SwiftUI

struct InformerView: View {
    
    @StateObject var viewModel: InformerViewModel
    
    init(viewModel: InformerViewModel) {
        
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        (viewModel.informer?.text).map {
            
            Text($0)
                .multilineTextAlignment(.leading)
                .padding()
                .foregroundColor(.white)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .animation(.easeInOut, value: viewModel.informer)
        }
    }
}

struct InformerView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        InformerView(viewModel: .init(
            informer: .init(text: "Ошибка изменения настроек СБП.\nПопробуйте позже.")
        ))
    }
}
