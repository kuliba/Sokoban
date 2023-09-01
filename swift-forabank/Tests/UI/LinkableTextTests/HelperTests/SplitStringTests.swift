//
//  SplitStringTests.swift
//  
//
//  Created by Igor Malyarov on 31.08.2023.
//

@testable import LinkableText
import XCTest

final class SplitStringTests: XCTestCase {
    
    func test_split_shouldReturnEmptyOnEmptyString() {
        
        let emptyString = ""
        
        let splits = emptyString.split(with: tag)
        
        XCTAssertTrue(splits.isEmpty)
    }
    
    func test_split_shouldSplitTextWithTagsInside() {
        
        let textWithTagsInside = "Very <u>important</u> message."
        
        let splits = textWithTagsInside.split(with: tag)
        
        XCTAssertNoDiff(splits, [
            .outsideTag("Very "),
            .insideTag("important"),
            .outsideTag(" message."),
        ])
    }
    
    func test_split_shouldNotSplitTextWithNonMatchingTags() {
        
        let textWithTagsInside = "Very <i>important</i> message."
        
        let splits = textWithTagsInside.split(with: tag)
        
        XCTAssertNoDiff(splits, [
            .outsideTag("Very <i>important</i> message.")
        ])
    }
    
    func test_split_tagsLeading() {
        
        let textWithTagsLeading = "<u>important</u> message."
        
        let splits = textWithTagsLeading.split(with: tag)
        
        XCTAssertNoDiff(splits, [
            .insideTag("important"),
            .outsideTag(" message."),
        ])
    }
    
    func test_split_tagsTrailing() {
        
        let textWithTagsTrailing = "Very <u>important</u>"
        
        let splits = textWithTagsTrailing.split(with: tag)
        
        XCTAssertNoDiff(splits, [
            .outsideTag("Very "),
            .insideTag("important"),
        ])
    }
    
    // MARK: - Helpers
    
    private let tag: (prefix: String, suffix: String) = ("<u>", "</u>")
}
