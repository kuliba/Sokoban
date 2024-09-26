//
//  CategoryPickerSectionFlowTests.swift
//
//
//  Created by Igor Malyarov on 23.08.2024.
//

import XCTest

class CategoryPickerSectionFlowTests: XCTestCase {
    
    struct Category: Equatable {
        
        let value: String
    }
    
    func makeCategory(
        _ value: String = anyMessage()
    ) -> Category {
        
        return .init(value: value)
    }
    
    struct SelectedCategory: Equatable {
        
        let value: String
    }
    
    func makeSelectedCategory(
        _ value: String = anyMessage()
    ) -> SelectedCategory {
        
        return .init(value: value)
    }
    
    struct CategoryList: Equatable {
        
        let value: String
    }
    
    func makeCategoryList(
        _ value: String = anyMessage()
    ) -> CategoryList {
        
        return .init(value: value)
    }
    
    struct Failure: Error, Equatable {
        
        let value: String
    }
    
    func makeFailure(
        _ value: String = anyMessage()
    ) -> Failure {
        
        return .init(value: value)
    }
}
