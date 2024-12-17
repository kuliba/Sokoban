//
//  UserDocumentViewModel.swift
//  ForaBank
//
//  Created by Mikhail on 29.05.2022.
//

import Foundation
import SwiftUI
import Combine

class UserDocumentViewModel: ObservableObject {
    
    let action: PassthroughSubject<Action, Never> = .init()
    
    let navigationBar: NavigationBarView.ViewModel
    let itemType: DocumentCellType
    var items: [DocumentDelailCellView.ViewModel]
    @Published var copyButton: ButtonSimpleView.ViewModel?
    @Published var sheet: Sheet?
     
    private var bindings = Set<AnyCancellable>()
    
    init(navigationBar: NavigationBarView.ViewModel, itemType: DocumentCellType, items: [DocumentDelailCellView.ViewModel], copyButton: ButtonSimpleView.ViewModel?) {
        
        self.navigationBar = navigationBar
        self.itemType = itemType
        self.items = items
        self.copyButton = copyButton
    }
    
    init(clientInfo: ClientInfoData, itemType: DocumentCellType, dismissAction: @escaping () -> Void) {
        
        self.itemType = itemType
        self.navigationBar = .init(
            title: itemType.title,
            leftItems: [
                NavigationBarView.ViewModel.BackButtonItemViewModel(icon: .ic24ChevronLeft, action: dismissAction)
            ],
            rightItems: [],
            background: itemType.backgroundColor,
            foreground: .textWhite)
                
        self.items = Self.createItems(from: clientInfo, itemType: itemType)
        
        navigationBar.rightItems = [ NavigationBarView.ViewModel.ButtonItemViewModel(icon: .ic24Share, action: { [weak self] in
            self?.action.send(UserDocumentViewModelAction.Share(clientInfo: clientInfo, itemType: itemType))
        })]
        
        copyButton = .init(title: "Скопировать все", style: .gray, action: { [weak self] in
            self?.action.send(UserDocumentViewModelAction.Copy(clientInfo: clientInfo, itemType: itemType))
        })
        
        bind()
    }
    
    func bind() {
        
        action
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] action in
                
                switch action {

                case let payload as UserDocumentViewModelAction.Copy:
                    var info = ""
                    
                    switch payload.itemType {
                    case .passport:
                        info = "ФИО: \(payload.clientInfo.lastName) \(payload.clientInfo.firstName) \(payload.clientInfo.patronymic ?? "") \nПаспорт: \(payload.clientInfo.regSeries ?? "") \(payload.clientInfo.regNumber)\nДата выдачи: \(payload.clientInfo.dateOfIssue ?? "") Код подразделения: \(payload.clientInfo.codeDepartment ?? "")\nМесто рождения: \(payload.clientInfo.birthPlace ?? "")\nДата рождения: \(payload.clientInfo.birthDay ?? "")"
                        
                    default:
                        break
                    }
                    
                    UIPasteboard.general.string = info
                    copyButton?.title = "Скопировано"
                    
                case let payload as UserDocumentViewModelAction.Share:
                    var info = ""
                    switch payload.itemType {
                    case .passport:
                        info = "ФИО: \(payload.clientInfo.lastName) \(payload.clientInfo.firstName) \(payload.clientInfo.patronymic ?? "") \nПаспорт: \(payload.clientInfo.regSeries ?? "") \(payload.clientInfo.regNumber)\nДата выдачи: \(payload.clientInfo.dateOfIssue ?? "") Код подразделения: \(payload.clientInfo.codeDepartment ?? "")\nМесто рождения: \(payload.clientInfo.birthPlace ?? "")\nДата рождения: \(payload.clientInfo.birthDay ?? "")"
                        
                    default:
                        break
                    }
                    
                    sheet = .init(sheetType: .share(ActivityView.ViewModel(activityItems: [info])))
                    
                default:
                    break
                    
                }
                
            }.store(in: &bindings)
    }
    
    static func createItems(from: ClientInfoData, itemType: DocumentCellType) -> [DocumentDelailCellView.ViewModel] {
        
        switch itemType {
            
        case .passport:
            return [
                .init(title: "ФИО", content: "\(from.lastName) \(from.firstName) \(from.patronymic ?? "")"),
                .init(title: "Серия и номер", content: "\(from.regSeries ?? "") \(from.regNumber)"),
                .init(title: "Дата выдачи", content: from.dateOfIssue),
                .init(title: "Код подразделения", content: from.codeDepartment),
                .init(title: "Место рождения", content: from.birthPlace),
                .init(title: "Дата рождения", content: from.birthDay)
            ]
            
        case .adressPass:
            return [
                .init(title: "Страна", content: from.addressInfo?.country),
                .init(title: "Регион", content: from.addressInfo?.region),
                .init(title: "Район", content: from.addressInfo?.area),
                .init(title: "Улица", content: from.addressInfo?.street),
                .init(title: "Индекс", content: from.addressInfo?.postIndex)
            ]
            
        case .adress:
            return [
                .init(title: "Страна", content: from.addressResidentialInfo?.country),
                .init(title: "Регион", content: from.addressResidentialInfo?.region),
                .init(title: "Район", content: from.addressResidentialInfo?.area),
                .init(title: "Улица", content: from.addressResidentialInfo?.street),
                .init(title: "Индекс", content: from.addressResidentialInfo?.postIndex)
            ]
            
        default:
            return []
        }
    }
    
    struct Sheet: Identifiable {
        
        let id = UUID()
        let sheetType: SheetType
        
        enum SheetType {
            case share(ActivityView.ViewModel)
        }
    }
}

enum UserDocumentViewModelAction {

    struct Share: Action {
        
        let clientInfo: ClientInfoData
        let itemType: DocumentCellType
    }
    
    struct Copy: Action {
        
        let clientInfo: ClientInfoData
        let itemType: DocumentCellType
    }
    
}
