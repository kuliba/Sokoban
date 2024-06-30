//
//  AsyncImageViewTests.swift
//
//
//  Created by Igor Malyarov on 30.06.2024.
//

import SwiftUI
import UIPrimitives
import XCTest

final class AsyncImageViewTests: XCTestCase {
    
    func test_shouldCallFetchOnAppear() {
        
        let exp = expectation(description: "wait for fetch")
        
        let initialImage = Image.photo
        
        let view = AsyncImageView(
            initialImage: initialImage,
            imageView: { $0 },
            fetchImage: { callback in
                
                exp.fulfill() // Indicate that fetch was called
                callback(.star)  // Provide a dummy image
            }
        )
        view.simulateOnAppear()
        
        wait(for: [exp], timeout: 1.0)
    }
}
