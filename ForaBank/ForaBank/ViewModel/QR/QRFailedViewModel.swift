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
    
    convenience init(model: Model, addCompanyAction: @escaping () -> Void, requisitsAction: @escaping () -> Void) {
        
        self.init(model: model, icon: Image.ic48BarcodeScanner, title: "Не удалось распознать QR-код", content: "Воспользуйтесь другими способами оплаты", searchOpratorButton: [])
        
        self.searchOperatorButton = createButtons(model, addCompanyAction: addCompanyAction, requisitesAction: requisitsAction)
    }
    
    private func createButtons(_ model: Model, addCompanyAction: @escaping () -> Void, requisitesAction: @escaping () -> Void) -> [ButtonSimpleView.ViewModel] {
        
        return [
            ButtonSimpleView.ViewModel(title: "Найти поставщика вручную", style: .gray, action: { [weak self] in
                
                self?.link = .failedView(.init(searchBar: .init(textFieldPhoneNumberView: .init(style: .general, placeHolder: .text("Название или ИНН")), state: .idle, icon: Image.ic24Search), navigationBar:
                        .init(
                            title: "Все регионы",
                            titleButton: .init(icon: Image.ic16ChevronDown, action: {
                                self?.model.action.send(QRSearchOperatorViewModelAction.OpenCityView())
                            }),
                            leftItems: [NavigationBarView.ViewModel.BackButtonItemViewModel(icon: Image.ic24ChevronLeft,
                                                                                          action: { [weak self] in
                                                                                              self?.link = nil})]),
                                               model: model, addCompanyAction: addCompanyAction, requisitesAction: requisitesAction))
                
            }),
            ButtonSimpleView.ViewModel(title: "Оплатить по реквизитам", style: .gray, action: requisitesAction)
        ]
    }
    
    enum Link {
        
        case failedView(QRSearchOperatorViewModel)
    }
}
