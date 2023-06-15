//
//  File.swift
//  
//
//  Created by Andryusina Nataly on 14.06.2023.
//

@testable import PickerWithPreviewComponent

import XCTest
import SwiftUI

final class ImageMapViewTests: XCTestCase {
    
    //MARK: - test init
    
    func test_init_setPlaceholder_shouldSetAllValue() {
        
        let imageMapView: ImageMapView = .init(
            mapImage: .placeholder
        )
        
        XCTAssertEqual(imageMapView.mapImage, .placeholder)
        XCTAssertNotNil(imageMapView.body)
    }
    
    func test_init_setImage_shouldSetAllValue() {
        
        let imageMapView: ImageMapView = .init(
            mapImage: .image(Image(systemName: "sunrise"))
        )
        
        XCTAssertEqual(imageMapView.mapImage, .image(Image(systemName: "sunrise")))
        XCTAssertNotNil(imageMapView.body)
    }
}
