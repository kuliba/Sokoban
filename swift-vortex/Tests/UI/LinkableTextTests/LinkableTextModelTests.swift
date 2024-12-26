//
//  LinkableTextModelTests.swift
//  
//
//  Created by Igor Malyarov on 31.08.2023.
//

import LinkableText
import XCTest

final class LinkableTextModelTests: XCTestCase {
    
    // MARK: - Bad URL String
    
    func test_init_shouldReturnEmptyOnEmptyStringOnBadURLString() {
        
        let badURLString = " "
        let emptyString = ""
        
        let linkableText = make(text: emptyString, urlString: badURLString)
        
        XCTAssertTrue(linkableText.splits.isEmpty)
    }

    func test_init_shouldSplitTextWithTagsInsideOnBadURLString() {
        
        let textWithTagsInside = "Very <u>important</u> message."
        let badURLString = " "
        
        let linkableText = make(text: textWithTagsInside, urlString: badURLString)
        
        XCTAssertNoDiff(linkableText.splits, [
            .text("Very "),
            .text("important"),
            .text(" message."),
        ])
    }
    
    func test_init_shouldNotSplitTextWithNonMatchingTagsOnBadURLString() {
        
        let textWithTagsInside = "Very <i>important</i> message."
        let badURLString = " "
        
        let linkableText = make(text: textWithTagsInside, urlString: badURLString)
        
        XCTAssertNoDiff(linkableText.splits, [
            .text("Very <i>important</i> message.")
        ])
    }
    
    func test_init_tagsLeadingOnBadURLString() {
        
        let textWithTagsLeading = "<u>important</u> message."
        let badURLString = " "
        
        let linkableText = make(text: textWithTagsLeading, urlString: badURLString)
        
        XCTAssertNoDiff(linkableText.splits, [
            .text("important"),
            .text(" message."),
        ])
    }
    
    func test_init_tagsTrailingOnBadURLString() {
        
        let textWithTagsTrailing = "Very <u>important</u>"
        let badURLString = " "
        
        let linkableText = make(text: textWithTagsTrailing, urlString: badURLString)
        
        XCTAssertNoDiff(linkableText.splits, [
            .text("Very "),
            .text("important"),
        ])
    }
    
    // MARK: - Good URL String
    
    func test_init_shouldReturnEmptyOnEmptyStringOnGoodURLString() {
        
        let emptyString = ""
        let goodURLString = "abc"
        
        let linkableText = make(text: emptyString, urlString: goodURLString)
        
        XCTAssertTrue(linkableText.splits.isEmpty)
    }
    
    func test_init_shouldSplitTextWithTagsInsideOnGoodURLString() {
        
        let textWithTagsInside = "Very <u>important</u> message."
        let goodURLString = "abc"
        
        let linkableText = make(text: textWithTagsInside, urlString: goodURLString)
        
        XCTAssertNoDiff(linkableText.splits, [
            .text("Very "),
            .link("important", .init(string: "abc")!),
            .text(" message."),
        ])
    }
    
    func test_init_shouldNotSplitTextWithNonMatchingTagsOnGoodURLString() {

        let textWithTagsInside = "Very <i>important</i> message."
        let goodURLString = "abc"

        let linkableText = make(text: textWithTagsInside, urlString: goodURLString)

        XCTAssertNoDiff(linkableText.splits, [
            .text("Very <i>important</i> message.")
        ])
    }

    func test_init_tagsLeadingOnGoodURLString() {

        let textWithTagsLeading = "<u>important</u> message."
        let goodURLString = "abc"

        let linkableText = make(text: textWithTagsLeading, urlString: goodURLString)

        XCTAssertNoDiff(linkableText.splits, [
            .link("important", URL(string: "abc")!),
            .text(" message."),
        ])
    }

    func test_init_tagsTrailingOnGoodURLString() {

        let textWithTagsTrailing = "Very <u>important</u>"
        let goodURLString = "abc"

        let linkableText = make(text: textWithTagsTrailing, urlString: goodURLString)

        XCTAssertNoDiff(linkableText.splits, [
            .text("Very "),
            .link("important", URL(string: "abc")!),
        ])
    }
    
    // MARK: - Helpers
    
    private func make(text: String, urlString: String) -> LinkableText {
        
        .init(text: text, urlString: urlString, tag: tag)
    }
    
    private let tag: (prefix: String, suffix: String) = ("<u>", "</u>")
}
