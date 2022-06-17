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
    
    let navigationBar: NavigationBarView.ViewModel
    let itemType: DocumentCellType
    @Published var copyButton: ButtonSimpleView.ViewModel?
    
    var items: [DocumentDelailCellView.ViewModel] = []
            
    init(model: Model, navigationBar: NavigationBarView.ViewModel, items: [DocumentDelailCellView.ViewModel], itemType: DocumentCellType) {
        self.itemType = itemType
        self.navigationBar = navigationBar
        self.items = items
        
        self.copyButton = .init(
            title: "Скопировать все",
            style: .gray,
            action: {
                
                print("Copy action")
            })
    }
    
    init(clientInfo: ClientInfoData, itemType: DocumentCellType, dismissAction: @escaping () -> Void) {
        
        self.itemType = itemType
        navigationBar = .init(
            title: itemType.title,
            leftButtons: [
                .init(icon: .ic24ChevronLeft, action: dismissAction )
            ],
            rightButtons: [],
            background: itemType.backgroundColor,
            foreground: .textWhite)
                
        items = createItems(from: clientInfo, itemType: itemType)
        
        navigationBar.rightButtons = [
            .init(icon: .ic24Share, action: { [weak self] in
                self?.shareAction()
            })
        ]
        
        copyButton = .init(
            title: "Скопировать все",
            style: .gray,
            action: {
                self.copyAction(with: clientInfo, for: itemType)
            })
        
    }
        
    func copyAction(with clientInfo: ClientInfoData, for itemType: DocumentCellType ) {
        var info = ""
        
        switch itemType {
        case .passport:
            info = "ФИО: \(clientInfo.lastName) \(clientInfo.firstName) \(clientInfo.patronymic ?? "") \nПаспорт: \(clientInfo.regSeries ?? "") \(clientInfo.regNumber)\nДата выдачи: \(clientInfo.dateOfIssue ?? "") Код подразделения: \(clientInfo.codeDepartment ?? "")\nМесто рождения: \(clientInfo.birthPlace ?? "")/nДата рождения: \(clientInfo.birthDay ?? "")"
            
        default:
            break
        }
        
        UIPasteboard.general.string = info
        copyButton?.title = "Скопировано"
    }
    
    func shareAction() {
        
    }
    
    func createItems(from: ClientInfoData, itemType: DocumentCellType) -> [DocumentDelailCellView.ViewModel] {
        
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
//                .init(title: "Город", content: from.codeDepartment),
//                .init(title: "Населенный пункт", content: from.birthPlace),
                .init(title: "Улица", content: from.addressInfo?.street),
                .init(title: "Индекс", content: from.addressInfo?.postIndex)
                
            ]
            
        case .adress:
            return [
                .init(title: "Страна", content: from.addressResidentialInfo?.country),
                .init(title: "Регион", content: from.addressResidentialInfo?.region),
                .init(title: "Район", content: from.addressResidentialInfo?.area),
//                .init(title: "Город", content: from.codeDepartment),
//                .init(title: "Населенный пункт", content: from.birthPlace),
                .init(title: "Улица", content: from.addressResidentialInfo?.street),
                .init(title: "Индекс", content: from.addressResidentialInfo?.postIndex)
                
            ]
            
        default:
            return []
        }
    }
}

