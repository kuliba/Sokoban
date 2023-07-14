//
//  FilteredTests.swift
//  
//
//  Created by Igor Malyarov on 14.06.2023.
//

import Foundation

struct Filter<Region: Equatable>: Equatable {
    
    let textFilter: TextFilter?
    let region: Region?
    
    enum TextFilter: Equatable {
        
        case inn(String)
        case name(String)
    }
}

extension Filter.TextFilter {
    
    init?(with text: String?) {
        
        guard let text,
              !text.isEmpty
        else { return nil }
        
        if text.allSatisfy({ $0.isNumber }) {
            self = .inn(text)
        } else {
            self = .name(text)
        }
    }
}

protocol INNed {
    
    var inn: String { get }
}

protocol Located {
    
    var region: String? { get }
}

protocol Named {
    
    var name: String { get }
}

typealias INNedLocatedNamed = INNed & Located & Named

extension Array where Element: INNedLocatedNamed {
    
    func filtered(
        withText text: String?,
        andRegion region: String?
    ) -> Self {
        
        filtered(with: .init(textFilter: .init(with: text), region: region))
    }
    
    func filtered(with filter: Filter<String>) -> Self {
        
        let textPredicate: (Element) -> Bool = {
            
            guard let textFilter = filter.textFilter
            else { return true }
            
            switch textFilter {
            case let .inn(inn):
                return $0.inn == inn
                
            case let .name(name):
                return $0.name.localizedLowercase.contains(name.localizedLowercase)
            }
        }
        
        let regionPredicate: (Element) -> Bool = {
            
            guard let region = filter.region,
                  !region.isEmpty
            else { return true }
            
            return $0.region?.localizedLowercase == region.localizedLowercase
        }
        
        return self
            .filter(regionPredicate)
            .filter(textPredicate)
    }
}

import XCTest

final class FilteredTests: XCTestCase {
    
    func test_filtered_empty_shouldReturnEmpty_onNilFilterParams() {
        
        let given: [TestElement] = []
        
        let filtered = given.filtered(withText: nil, andRegion: nil)
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_empty_shouldReturnEmpty_onEmptyTextNilRegion() {
        
        let given: [TestElement] = []
        
        let filtered = given.filtered(withText: "", andRegion: nil)
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_empty_shouldReturnEmpty_onEmptyTextEmptyRegion() {
        
        let given: [TestElement] = []
        
        let filtered = given.filtered(withText: "", andRegion: "")
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_empty_shouldReturnEmpty_onEmptyTextNonEmptyRegion() {
        
        let given: [TestElement] = []
        
        let filtered = given.filtered(withText: "", andRegion: "X")
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_empty_shouldReturnEmpty_onNonEmptyTextNilRegion() {
        
        let given: [TestElement] = []
        
        let filtered = given.filtered(withText: "A", andRegion: nil)
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_empty_shouldReturnEmpty_onNonEmptyTextEmptyRegion() {
        
        let given: [TestElement] = []
        
        let filtered = given.filtered(withText: "A", andRegion: "X")
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_empty_shouldReturnEmpty_onNonEmptyTextNonEmptyRegion() {
        
        let given: [TestElement] = []
        
        let filtered = given.filtered(withText: "A", andRegion: "X")
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_nonEmpty_shouldReturnSame_onNilFilterParams() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: nil, andRegion: nil)
        
        XCTAssertNoDiff(filtered, given)
    }
    
    func test_filtered_nonEmpty_shouldReturnSame_onEmptyTextNilRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "", andRegion: nil)
        
        XCTAssertNoDiff(filtered, given)
    }
    
    func test_filtered_nonEmpty_shouldReturnSame_onEmptyTextEmptyRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "", andRegion: "")
        
        XCTAssertNoDiff(filtered, given)
    }
    
    func test_filtered_nonEmpty_shouldReturnWithMatchingRegion_onEmptyTextNonEmptyRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "", andRegion: "X")
        
        XCTAssertNoDiff(filtered, [.a])
        XCTAssertNoDiff(TestElement.a.region, "X")
    }
    
    func test_filtered_nonEmpty_shouldReturnEmpty_onEmptyTextNonEmptyNonMatchingRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "", andRegion: "R")
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_nonEmpty_shouldReturnWithMatchingName_onNonEmptyTextNilRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "a", andRegion: nil)
        
        XCTAssertNoDiff(filtered, [.a])
    }
    
    func test_filtered_nonEmpty_shouldReturnWithMatchingINN_onNonEmptyTextNilRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "2", andRegion: nil)
        
        XCTAssertNoDiff(filtered, [.b])
    }
    
    func test_filtered_nonEmpty_shouldReturnEmpty_onMatchingNameTextNonNilRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "F", andRegion: nil)
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_nonEmpty_shouldReturnEmpty_onNonMatchingINNTextNilRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "7", andRegion: nil)
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_nonEmpty_shouldReturnWithMatchingName_onNonEmptyTextEmptyRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "B", andRegion: "")
        
        XCTAssertNoDiff(filtered, [.b])
    }
    
    func test_filtered_nonEmpty_shouldReturnWithMatchingINN_onNonEmptyTextEmptyRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "2", andRegion: "")
        
        XCTAssertNoDiff(filtered, [.b])
    }
    
    func test_filtered_nonEmpty_shouldReturnEmpty_onNonMatchingNameTextEmptyRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "R", andRegion: "")
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_nonEmpty_shouldReturnEmpty_onNonMatchingINNTextEmptyRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "10", andRegion: "")
        
        XCTAssertNoDiff(filtered, [])
    }
    
    func test_filtered_nonEmpty_shouldReturnWithMatchingRegion_onNilTextMatchingRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: nil, andRegion: "Y")
        
        XCTAssertNoDiff(filtered, [.b, .c])
        XCTAssertNoDiff(TestElement.b.region, "Y")
        XCTAssertNoDiff(TestElement.c.region, "Y")
    }
    
    func test_filtered_nonEmpty_shouldReturnWithMatchingRegion_onEmptyTextMatchingRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "", andRegion: "Y")
        
        XCTAssertNoDiff(filtered, [.b, .c])
        XCTAssertNoDiff(TestElement.b.region, "Y")
        XCTAssertNoDiff(TestElement.c.region, "Y")
    }
    
    func test_filtered_nonEmpty_shouldReturnWithMatchingNameAndMathcingRegion_onMatchingTextMatchingRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "c", andRegion: "Y")
        
        XCTAssertNoDiff(filtered, [.c])
        XCTAssertNoDiff(TestElement.c.region, "Y")
    }
    
    func test_filtered_nonEmpty_shouldReturnWithMatchingINNAndMathcingRegion_onMatchingTextMatchingRegion() {
        
        let given: [TestElement] = .all
        
        let filtered = given.filtered(withText: "3", andRegion: "Y")
        
        XCTAssertNoDiff(filtered, [.c])
        XCTAssertNoDiff(TestElement.c.region, "Y")
    }
}

struct TestElement: INNedLocatedNamed, Equatable {
    
    let inn: String
    let name: String
    let region: String?
}

extension TestElement {
    
    static let a: Self = .init(inn: "1", name: "Aaa", region: "X")
    static let b: Self = .init(inn: "2", name: "Bbb", region: "Y")
    static let c: Self = .init(inn: "3", name: "Ccc", region: "Y")
    static let d: Self = .init(inn: "4", name: "Ddd", region: "Z")
    static let w: Self = .init(inn: "9", name: "Www", region: nil)
}

extension Array where Element == TestElement {
    
    static let all: Self = [.a, .b, .c, .d, .w]
}
