//
//  PaymentsTaxesParameterSwitchViewComponent.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.02.2022.
//

import SwiftUI
import Combine

class PaymentsTaxesParameterSwitchViewModel: ObservableObject {
    
    @Published var options: [OptionViewModel]
    @Published var selected: Option.ID
 
    internal init(options: [Option], selected: Option.ID) {
        self.options = []
        self.selected = selected
        self.options = options.map{ OptionViewModel(id: $0.id, title: $0.name)}
    }
}

extension PaymentsTaxesParameterSwitchViewModel {
    
    struct OptionViewModel: Identifiable {
        
        let id: Option.ID
        let title: String
    }
}

struct PaymentsTaxesParameterSwitchView: View {
    
    @ObservedObject var viewModel: PaymentsTaxesParameterSwitchViewModel
    
    var body: some View {
        HStack {
            Picker("", selection: $viewModel.selected, content: {
                ForEach(viewModel.options, content: { options in
                    Text(options.title)
                })
            })
                .pickerStyle(.segmented)
        }
    }
}

struct PaymentsTaxesParameterSwitchViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsTaxesParameterSwitchView(viewModel: .init(options: [ .init(id: "ФССП", name: "ФССП"),
                                                                     .init(id: "ФНС", name: "ФНС"),
                                                                    .init(id: "ФМС", name: "ФМС")],
                                                                    selected: "ФССП"))
            .previewLayout(.fixed(width: 375, height: 56))
    }
}


