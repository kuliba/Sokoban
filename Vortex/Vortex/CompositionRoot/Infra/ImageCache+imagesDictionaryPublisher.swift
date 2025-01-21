//
//  ImageCache+imagesDictionaryPublisher.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.01.2025.
//

import Combine
import SwiftUI

extension ImageCache {
    
    func imagesDictionaryPublisher(
        for keys: [String]
    ) -> AnyPublisher<[String: Image], Never> {
        
        // map into (key, image) tuples
        let perItemPublishers: [AnyPublisher<(String, Image), Never>] = keys.map { key in
            
            image(forKey: .init(key))
                .map { image in (key, image) }
                .handleEvents(receiveOutput: {
                    
                    print("####### image forKey", $0.0, $0.1)
                })
                .eraseToAnyPublisher()
        }
        
        // merge into a dictionary
        return Publishers.MergeMany(perItemPublishers)
            .scan([String: Image]()) { dict, tuple in
                
                var dict = dict
                let (md5, img) = tuple
                dict[md5] = img
                
                return dict
            }
            .eraseToAnyPublisher()
    }
}
