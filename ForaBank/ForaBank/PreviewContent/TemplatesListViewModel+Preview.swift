//
//  TemplatesListViewModel+Preview.swift
//  ForaBank
//
//  Created by Max Gribov on 25.01.2022.
//

import SwiftUI

extension TemplatesListViewModel {
    
    static let sampleComplete: TemplatesListViewModel = {
        
        var viewModel = TemplatesListViewModel(
            state: .normal,
            style: .list,
            title: "Шаблоны",
            navButtonBack: .init(icon: .ic24ChevronLeft, action: {}),
            navButtonsRight: [
                .init(icon: Image("searchBarIcon"), action: {
                    //TODO: set action
                }),
                .init(icon: Image("more-horizontal"), action: {
                    //TODO: set action
                })
            ],
            categorySelector: .init(options: [
                .init(id: "all", name: "Все" ),
                .init(id: "add", name: "Пополнение"),
                .init(id: "addi", name: "Коммунальные"),
                .init(id: "addit", name: "Переводы")
            ], selected: "all", style: .template),
            items: [
                .init(id: 0, sortOrder: 0, state: .normal, image: Image("Bank Logo Sample"),
                      title: "Маме на Сбер",
                      subTitle: "Перевод по СБП",
                      logoImage: nil, ammount: "450 ₽", tapAction: {_ in}, deleteAction: {_ in}
                     ),
                
                .init(id: 1, sortOrder: 1, state: .select(.init(isSelected: true, action: { _ in })), image: Image("Bank Logo Sample"),
                      title: "Паме на Сбер",
                      subTitle: "Перевод по СБП",
                      logoImage: nil, ammount: "324 000 ₽", tapAction: {_ in}, deleteAction: {_ in}
                     ),
                
                .init(id: 2, sortOrder: 2, state: .delete(.init(icon: Image("trash_empty"), subTitle: "Удалить", action: { _ in })), image: Image("Bank Logo Sample"),
                      title: "Жене на Сбер",
                      subTitle: "Перевод по СБП",
                      logoImage: nil, ammount: " 1,31 млн. ₽", tapAction: {_ in}, deleteAction: {_ in}
                     ),
                
                .init(id: 3, sortOrder: 3, state: .deleting(.init(progress: 0.76, countTitle: "3", cancelButton: .init(title: "Отменить", action: { _ in }))), image: Image("Bank Logo Sample"),
                      title: "Жене на Сбер",
                      subTitle: "Удаление...",
                      logoImage: nil, ammount: " 1,31 млн. ₽", tapAction: {_ in}, deleteAction: {_ in}
                 ),
                
                    .init(id: 4, sortOrder: 4, state: .normal, image: Image("Templates Add New Icon"),
                          title: "Добавить шаблон",
                          subTitle: "Из операции в разделе История",
                          logoImage: nil, ammount: "", tapAction: {_ in}, deleteAction: {_ in}, kind: .add
                 )
            ],
            contextMenu: nil,
            deletePannel: nil,
            model: .emptyMock
        )
        
        return viewModel
        
    }()
    
    static let sampleTiles: TemplatesListViewModel = {
        
        var viewModel = TemplatesListViewModel(
            state: .normal,
            style: .tiles,
            title: "Шаблоны",
            navButtonBack: .init(icon: .ic24ChevronLeft, action: {}),
            navButtonsRight: [
                .init(icon: Image("more-horizontal"), action: {
                    //TODO: set action
                }),
                .init(icon: Image("searchBarIcon"), action: {
                    //TODO: set action
                })
            ],
            categorySelector: .init(options: [
                .init(id: "all", name: "Все" ),
                .init(id: "add", name: "Пополнение"),
                .init(id: "addi", name: "Коммунальные"),
                .init(id: "addit", name: "Переводы")
            ], selected: "all", style: .template),
            items: [
                .init(id: 0, sortOrder: 0, state: .normal,
                      image: Image("Bank Logo Sample"),
                      title: "Между своими счетами",
                      subTitle: "Перевод по СБП",
                      logoImage: nil, ammount: "450 ₽", tapAction: {_ in}, deleteAction: {_ in}),
                
                .init(id: 1, sortOrder: 1, state: .normal,
                      image: Image("Bank Logo Sample"),
                      title: "Паме на Сбер",
                      subTitle: "Перевод по СБП",
                      logoImage: nil, ammount: "324 000 ₽", tapAction: {_ in}, deleteAction: {_ in}),
                
                .init(id: 2, sortOrder: 2, state: .normal,
                      image: Image("Bank Logo Sample"),
                      title: "Жене на Сбер",
                      subTitle: "Перевод по СБП",
                      logoImage: Image("beline"), ammount: " 1,31 млн. ₽", tapAction: {_ in}, deleteAction: {_ in}),
                
                    .init(id: 4, sortOrder: 4, state: .normal, image: Image("Templates Add New Icon"),
                          title: "Добавить шаблон",
                          subTitle: "Из операции в разделе История",
                          logoImage: nil, ammount: "", tapAction: {_ in}, deleteAction: {_ in}, kind: .add
                 )
            ],
            contextMenu: nil,
            deletePannel: nil,
            model: .emptyMock
        )
        
        return viewModel
        
    }()
    
    static let sampleDeleting: TemplatesListViewModel = {
        
        var viewModel = TemplatesListViewModel(
            state: .select,
            style: .tiles,
            title: "Выбрать объекты",
            navButtonBack: .init(icon: .ic24ChevronLeft, action: {}),
            navButtonsRight: [
                .init(icon: Image("Operation Details Close Button Icon"), action: {
                    //TODO: set action
                })
            ],
            categorySelector: .init(options: [
                .init(id: "all", name: "Все" ),
                .init(id: "add", name: "Пополнение"),
                .init(id: "addi", name: "Коммунальные"),
                .init(id: "addit", name: "Переводы")
            ], selected: "all", style: .template),
            items: [
                .init(id: 0, sortOrder: 0, state: .select(.init(isSelected: false, action: { _ in })),
                      image: Image("Bank Logo Sample"),
                      title: "Маме на Сбер",
                      subTitle: "Перевод по СБП",
                      logoImage: nil, ammount: "450 ₽", tapAction: {_ in}, deleteAction: {_ in}),
                
                    .init(id: 1, sortOrder: 1, state: .select(.init(isSelected: true, action: { _ in })),
                      image: Image("Bank Logo Sample"),
                      title: "Паме на Сбер",
                      subTitle: "Перевод по СБП",
                          logoImage: nil, ammount: "324 000 ₽", tapAction: {_ in}, deleteAction: {_ in}),
                
                    .init(id: 2, sortOrder: 2, state: .deleting(.init(progress: 0.35, countTitle: "3", cancelButton: .init(title: "Отменить", action: { _ in }))),
                      image: Image("Bank Logo Sample"),
                      title: "Жене на Сбер",
                      subTitle: "Удаление...",
                          logoImage: Image("beline"), ammount: " 1,31 млн. ₽", tapAction: {_ in}, deleteAction: {_ in})
            ],
            contextMenu: .init(
                items:[
                    .init(icon: Image("bar-in-order"),
                          title: "Последовательность",
                          action: {
                              //TODO: set action
                          }),
                    .init(icon: Image("grid"),
                          title: "Вид (Плитка)",
                          action: {
                              //TODO: set action
                          }),
                    .init(icon: Image("trash_empty"),
                          title: "Удалить",
                          action: {
                              //TODO: set action
                          })
                ]),
            deletePannel: .init(description: "Выбрано 1 объект", button: .init(icon: Image("trash"), caption: "Удалить все", isEnabled: true, action: { })),
            model: .emptyMock
        )
        
        return viewModel
        
    }()
}

extension TemplatesListViewModel.OnboardingViewModel {
    
    static let sample = TemplatesListViewModel.OnboardingViewModel(icon: Image("Templates Onboarding Icon"),
                                     title: "Нет шаблонов", message: "Вы можете создать шаблон из любой успешной операции в разделе История",
                                     button: .init(title: "Перейти в историю",
                                                   action: { }))
}
