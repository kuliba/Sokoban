//
//  PaymentsTaxesViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 07.02.2022.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift

class PaymentTaxesListViewModel: ObservableObject {

    let action: PassthroughSubject<Action, Never> = .init()
    
    let title = "Налоги и госуслуги"
    lazy var qrButton: QRButtonViewModel  = QRButtonViewModel(icon: Image("qr_Icon"), action: {
        //init qrCodeScannerViewModel
        })
    var items: [Items]
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()

    init( _ model: Model) {
    
        self.items = model.paymentTemplates.value.map{ Items(parameters: $0) }
        self.model = model
        getData()
        bind()
    }
    
    func getData() {
        model.action.send(ModelAction.PaymentTemplate.List.Requested())
    }
    
    func bind() {
        model.action
            .receive(on: DispatchQueue.main)
            .sink { action in
                switch action {
                case let a as ModelAction.PaymentTemplate.List.Complete:
                    // Обновить items
                    self.items = a.paymentTemplates.map{ Items(parameters: $0) }
                    print(a.paymentTemplates)
                default: break
                }
 
            }.store(in: &bindings)
    }
    
}

extension PaymentTaxesListViewModel {
    
    struct QRButtonViewModel {
        
        let icon: Image
        let action: () -> Void
    }
    
    struct Items: Identifiable {
        var id = UUID()
        let action: (Items.ID) -> Void = {_ in }
        var item: PaymentsTaxesInfoCellViewComponent.PaymentsTaxesInfoCell
        
        init (parameters: PaymentTemplateData) {
            item = PaymentsTaxesInfoCellViewComponent.PaymentsTaxesInfoCell(viewModel: PaymentsTaxesInfoCellViewComponent.ViewModel(logo: Image(uiImage: parameters.svgImage.uiImage!), title: parameters.name, subTitle: "SubTitle", action: {_ in }))
        }
    
    }
    
}

