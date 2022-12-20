//
//  QRFilterTeste.swift
//  ForaBankTests
//
//  Created by Константин Савялов on 14.12.2022.
//

import XCTest
@testable import ForaBank

class QRFilterTeste: XCTestCase {

    func testFilter() throws {
        
        // given

        guard let operatorsData = Model.shared.dictionaryAnywayOperators() else { return }
        let operators = operatorsData.map {QRSearchOperatorComponent.ViewModel.init(operators: $0) }
        
        // when

        let searchText = "ЕИРЦ"
        
        let searchInn = "7604194785"
        
        // then
        
//        let result_Text = QRSearchOperatorViewModel.filter(text: searchText, operators: operators) ?? []
        
        let result_Inn = QRSearchOperatorViewModel.filter(text: searchInn, operators: operators) ?? []
        
        print(result_Inn.forEach{ value in
            print(value.title)
        })
        
    }
}
