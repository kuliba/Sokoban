//
//  TemplatesListViewModelTests.swift
//  ForaBankTests
//
//  Created by Dmitry Martynov on 04.06.2023.
//

import XCTest
@testable import ForaBank

final class TemplatesListViewModelTests: XCTestCase {

    /*
     План тестирования
     
     1. Нет данных шаблонов
        - шаблонов в модели нет
        - загрузки в текущий момент шаблонов нет

        Результат:
        - навБар тайтл “Шаблоны”
        - навБар кнопка поиска не активна
        - навБар кнопка меню не активна

        - стэйт НетШаблонов (Пустой экран)
        - во вьюМоделе стэйта Доступна кнопка с тайтлом "Перейти в историю"
        
     */
    
    func test_initNoTempatesDataNoLoadingData_correct() throws {
    
        let (sut, model) = makeSut(templatesData: [],
                                   isLoadingData: false)
       
        XCTAssertTrue(model.paymentTemplates.value.isEmpty)
        XCTAssertFalse(model.paymentTemplatesUpdating.value)
        
        // wait for bindings
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        let navBarRegularModel = try XCTUnwrap(sut.navBarState.regularModel)
        XCTAssertEqual(navBarRegularModel.title, "Шаблоны")
        XCTAssertEqual(navBarRegularModel.isSearchButtonDisable, true)
        XCTAssertEqual(navBarRegularModel.isMenuDisable, true)
        
        let stateEmptyListModel = try XCTUnwrap(sut.state.emptyListModel)
        XCTAssertEqual(stateEmptyListModel.button.title, "Перейти в историю")
    }
   
    /*
    Тест инит при наличии данных шаблонов
        - шаблонов 2 штуки
        - загрузки в текущий момент шаблонов нет
        - настройка показа шаблонов - Плитка
     
     Результат
        - нав бар тайтл “Шаблоны”
        - кнопка search активна
        - кнопка меню активна
        - в меню 3 айтема
            - первый айтем меню тайтл "Последовательность"
            - второй айтeм меню тайтл "Вид (Список)"
            - третий aйтeм меню тайтл "Удалить"
        - в списке айтомов три шаблона
            - два айтома вида регулярного
            - последний айтом кнопка для Добавления шаблона
        - контекстое меню на айтомах регулярного вида
        - селектор фильтрации показан
            - три селектора фильтрации "Все", "group1", "group2"
    */
    
    func test_initWithTempatesDataNoLoadingData_correct() throws {
    
        let (sut, model) = makeSut(templatesData: [.firstTemplateData, .secondTemplateData],
                                   isLoadingData: false,
                                   styleSetting: .tiles)
        // wait for bindings
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        //data
        XCTAssertEqual(model.paymentTemplates.value.count, 2)
        XCTAssertFalse(model.paymentTemplatesUpdating.value)

        //navBar
        let navBarRegularModel = try XCTUnwrap(sut.navBarState.regularModel)
        XCTAssertEqual(navBarRegularModel.title, "Шаблоны")
        XCTAssertEqual(navBarRegularModel.isSearchButtonDisable, false)
        XCTAssertEqual(navBarRegularModel.isMenuDisable, false)
        
        //menuItems
        XCTAssertEqual(navBarRegularModel.menuList.count, 3)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Последовательность" }, 0)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Вид (Список)" }, 1)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Удалить" }, 2)
        
        //selector
        let selectorModel = try XCTUnwrap(sut.categorySelector)
        XCTAssertEqual(selectorModel.options.count, 3)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "Все" }, 0)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "group1" }, 1)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "group2" }, 2)
        
        //regular items context menu
        let menuItemsModel = try XCTUnwrap(sut.getItemsMenuViewModel())
        XCTAssertEqual(menuItemsModel.count, 2)
        XCTAssertEqual(menuItemsModel.firstIndex { $0.subTitle == "Удалить" }, 0)
        XCTAssertEqual(menuItemsModel.firstIndex { $0.subTitle == "Переименовать" }, 1)
        
        //templateItems
        XCTAssertEqual(sut.items.map(\.kind), [.regular, .regular, .add])
    }

    /*
     Тест инит при наличии данных шаблонов
        - шаблонов 2 штуки
        - загрузки данных шаблонов в текущий момент
        - настройка показа шаблонов - Список
 
     Результат
        - нав бар тайтл “Шаблоны”
        - кнопка search активна
        - кнопка меню активна
        - в меню 3 айтема
            - первый айтем меню тайтл "Последовательность"
            - второй айтeм меню тайтл "Вид (Список)"
            - третий aйтeм меню тайтл "Удалить"
     - в списке айтомов 4 шаблона
            - в верху плейсхолдер айтема
            - два айтома вида регулярного
            - последний айтом кнопка для Добавления шаблона
     - контекстое меню на айтомах регулярного вида
     - селектор фильтрации показан
        - три селектора фильтрации "Все", "group1", "group2"
     */

    func test_initWithTempatesDataAndLoadingData_correct() throws {

        let (sut, model) = makeSut(templatesData: [.firstTemplateData, .secondTemplateData],
                                   isLoadingData: true,
                                   styleSetting: .tiles)
        // wait for bindings
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)

        //data
        XCTAssertEqual(model.paymentTemplates.value.count, 2)
        XCTAssertTrue(model.paymentTemplatesUpdating.value)

        //navBar
        let navBarRegularModel = try XCTUnwrap(sut.navBarState.regularModel)
        XCTAssertEqual(navBarRegularModel.title, "Шаблоны")
        XCTAssertEqual(navBarRegularModel.isSearchButtonDisable, false)
        XCTAssertEqual(navBarRegularModel.isMenuDisable, false)
    
        //menuItems
        XCTAssertEqual(navBarRegularModel.menuList.count, 3)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Последовательность" }, 0)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Вид (Список)" }, 1)
        XCTAssertEqual(navBarRegularModel.menuList.firstIndex { $0.title == "Удалить" }, 2)
    
        //selector
        let selectorModel = try XCTUnwrap(sut.categorySelector)
        XCTAssertEqual(selectorModel.options.count, 3)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "Все" }, 0)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "group1" }, 1)
        XCTAssertEqual(selectorModel.options.firstIndex { $0.title == "group2" }, 2)
    
        //regular items context menu
        let menuItemsModel = try XCTUnwrap(sut.getItemsMenuViewModel())
        XCTAssertEqual(menuItemsModel.count, 2)
        XCTAssertEqual(menuItemsModel.firstIndex { $0.subTitle == "Удалить" }, 0)
        XCTAssertEqual(menuItemsModel.firstIndex { $0.subTitle == "Переименовать" }, 1)
    
        //templateItems
        XCTAssertEqual(sut.items.map(\.kind), [.placeholder, .regular, .regular, .add])
    }
}



//MARK: Helpers

private extension TemplatesListViewModelTests {
    
    func makeSut(templatesData: [PaymentTemplateData] = [],
                 isLoadingData: Bool = false,
                 styleSetting: TemplatesListViewModel.Style = .list)
    -> (sut: TemplatesListViewModel, model: Model) {
        
        let model: Model = .emptyMock
        model.addTemplates(templatesData: templatesData)
        model.paymentTemplatesUpdating.value = isLoadingData
        model.paymentTemplatesViewSettings.value = .init(style: styleSetting)
        
        let sut = TemplatesListViewModel(model, dismissAction: {})
        
        return (sut, model)
    }
}

private extension Model {
   
    func addTemplates(templatesData: [PaymentTemplateData]) {
        
        paymentTemplates.value = templatesData
        XCTAssertEqual(paymentTemplates.value, templatesData)
    }
}



private extension PaymentTemplateData {
    
    static func makeTemplateData(
        groupName: String,
        name: String,
        parameterList: [TransferData],
        paymentTemplateId: Int,
        productTemplate: ProductTemplateData? = nil,
        sort: Int,
        svgImage: SVGImageData,
        type: PaymentTemplateData.Kind) -> PaymentTemplateData {
        
            .init(groupName: groupName,
                  name: name,
                  parameterList: parameterList,
                  paymentTemplateId: paymentTemplateId,
                  productTemplate: productTemplate,
                  sort: sort,
                  svgImage: svgImage,
                  type: type)
        
    }

    static let firstTemplateData = makeTemplateData(
        
        groupName: "group1",
        name: "firstTemplate",
        parameterList: [.init(amount: 101.19,
                              check: true,
                              comment: nil,
                              currencyAmount: "RUB",
                              payer: Self.payer),
                        .init(amount: 102.19,
                              check: true,
                              comment: nil,
                              currencyAmount: "RUB",
                              payer: Self.payer)],
        paymentTemplateId: 1,
        sort: 1,
        svgImage: .init(description: ""),
        type: .byPhone)
    
    static let secondTemplateData = makeTemplateData(
        
        groupName: "group2",
        name: "secondTemplate",
        parameterList: [.init(amount: 10.02,
                              check: true,
                              comment: nil,
                              currencyAmount: "RUB",
                              payer: Self.payer),
                        .init(amount: 11.02,
                              check: true,
                              comment: nil,
                              currencyAmount: "RUB",
                              payer: Self.payer)],
        paymentTemplateId: 2,
        sort: 2,
        svgImage: .init(description: ""),
        type: .betweenTheir)
    
    static let payer: TransferData.Payer = .init(inn: nil,
                                                 accountId: nil,
                                                 accountNumber: nil,
                                                 cardId: nil,
                                                 cardNumber: nil,
                                                 phoneNumber: nil)
}
