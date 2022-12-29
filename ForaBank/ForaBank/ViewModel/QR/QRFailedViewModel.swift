//
//  QRFailedViewModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 14.11.2022.
//

import SwiftUI
import Combine

class QRFailedViewModel: ObservableObject {
    
    let model: Model
    let icon: Image
    let title: String
    let content: String
    @Published var searchOperatorButton: [ButtonSimpleView.ViewModel]
    @Published var alert: Alert.ViewModel?
    @Published var isLinkActive: Bool = false
    @Published var link: Link? { didSet { isLinkActive = link != nil } }
    
    init(model: Model, icon: Image, title: String, content: String, searchOpratorButton: [ButtonSimpleView.ViewModel]) {
        
        self.model = model
        self.icon = icon
        self.title = title
        self.content = content
        self.searchOperatorButton = searchOpratorButton
    }
    
    convenience init(model: Model) {
        
        self.init(model: model, icon: Image.ic48BarcodeScanner, title: "Не удалось распознать QR-код", content: "Воспользуйтесь другими способами оплаты", searchOpratorButton: [])
        
        self.searchOperatorButton = createButtons()
    }
    
    private func createButtons() -> [ButtonSimpleView.ViewModel] {
        
        return [
            ButtonSimpleView.ViewModel(title: "Найти поставщика вручную", style: .gray, action: { [weak self] in
                
                self?.link = .failedView(.init(textFieldPlaceholder: "Название или ИНН", navigationBar:
                        .init(
                            title: "Все регионы",
                            titleButton: .init(icon: Image.ic16ChevronDown, action: {
                                self?.model.action.send(QRSearchOperatorViewModelAction.OpenCityView())
                            }),
                            leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: Image.ic24ChevronLeft,
                                                                                          action: { [weak self] in
                                                                                              self?.link = nil})]),
                                               model: Model.shared))
                
            }),
            ButtonSimpleView.ViewModel(title: "Оплатить по реквизитам", style: .gray, action: { [weak self] in
                self?.alert = .init(title: "Переход на оплату реквизитами", message: "", primary: .init(type: .default, title: "Ok", action: { [weak self] in self?.alert = nil}))
            })
        ]
    }
    
    enum Link {
        
        case failedView(QRSearchOperatorViewModel)
    }
}
