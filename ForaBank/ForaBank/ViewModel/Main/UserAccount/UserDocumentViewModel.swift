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
    
    let navigationBar: NavigationViewModel
    let itemType: DocumentCellType
    @Published var copyButton: GrayButtonView.ViewModel
    
    var items: [DocumentDelailCellView.ViewModel]
    
    private let model: Model
    private var bindings = Set<AnyCancellable>()
    
    init(model: Model, navigationBar: UserDocumentViewModel.NavigationViewModel, items: [DocumentDelailCellView.ViewModel], itemType: DocumentCellType) {
        
        self.model = model
        self.navigationBar = navigationBar
        self.itemType = itemType
        self.items = items
        
        self.copyButton = .init(
            title: "Скопировать все",
            action: {
                print("Copy action")
            })
        
    }

    init(model: Model, itemType: DocumentCellType) {
                
        self.model = model
        self.navigationBar = .init(
            title: "Паспорт РФ",
            backButton: .init(icon: .ic24ChevronLeft, action: {
                print("back")
            }),
            rightButton: .init(icon: .ic24Settings, action: {
                print("right")
            }))
        self.itemType = itemType
        self.items = []
        self.copyButton = .init(
            title: "Скопировать все",
            action: {
                print("Copy action")
            })
                
        bind()
    }
        
    func bind() {
        
        model.clientInfo
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] clientInfo in
                
                guard let clientInfo = clientInfo else { return }
                createItems(from: clientInfo)

            }.store(in: &bindings)
        
    }
    
    
    // addressInfo.country
    // addressInfo.region
    // addressInfo.area
    // addressInfo.street
    // addressInfo.house addressInfo.frame addressInfo.flat
    // addressInfo.postIndex

    // addressResidentialInfo
    
    // lastName firstName patronymic
    // regSeries regNumber
    // dateOfIssue
    // codeDepartment
    // birthPlace
    // birthDay
    
    func createItems(from: ClientInfoData) {
        
        switch itemType {
        case .passport:
            items = [
                .init(title: "ФИО", content: "\(from.lastName) \(from.firstName) \(from.patronymic ?? "")"),
                .init(title: "Серия и номер", content: "\(from.regSeries ?? "") \(from.regNumber)"),
                .init(title: "Дата выдачи", content: from.dateOfIssue),
                .init(title: "Код подразделения", content: from.codeDepartment),
                .init(title: "Место рождения", content: from.birthPlace),
                .init(title: "Дата рождения", content: from.birthDay)
            ]
        case .inn:
            break
        case .adressPass:
            items = [
                .init(title: "Страна", content: from.addressInfo?.country),
                .init(title: "Регион", content: from.addressInfo?.region),
                .init(title: "Район", content: from.addressInfo?.area),
//                .init(title: "Город", content: from.codeDepartment),
//                .init(title: "Населенный пункт", content: from.birthPlace),
                .init(title: "Улица", content: from.addressInfo?.street),
                .init(title: "Индекс", content: from.addressInfo?.postIndex)
                
            ]
        case .adress:
            items = [
                .init(title: "Страна", content: from.addressResidentialInfo?.country),
                .init(title: "Регион", content: from.addressResidentialInfo?.region),
                .init(title: "Район", content: from.addressResidentialInfo?.area),
//                .init(title: "Город", content: from.codeDepartment),
//                .init(title: "Населенный пункт", content: from.birthPlace),
                .init(title: "Улица", content: from.addressResidentialInfo?.street),
                .init(title: "Индекс", content: from.addressResidentialInfo?.postIndex)
                
            ]
        }
        
        
    }
    
}


extension UserDocumentViewModel {
    
    struct NavigationViewModel {
        
        let title: String
        let backButton: NavigationButtonViewModel
        let rightButton: NavigationButtonViewModel
        
        struct NavigationButtonViewModel {
            
            let icon: Image
            let action: () -> Void
            
            init(icon: Image, action: @escaping () -> Void) {
                
                self.icon = icon
                self.action = action
            }
        }
    }
}

extension UserDocumentViewModel.NavigationViewModel {
    
    static let sample = UserDocumentViewModel.NavigationViewModel(
        title: "Паспорт РФ",
        backButton: .init(icon: .ic24ChevronLeft, action: {
            print("back")
        }),
        rightButton: .init(icon: .ic24Share, action: {
            print("right")
        }))
}
