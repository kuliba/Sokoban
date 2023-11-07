//
//  URLCache+Extensions.swift
//  ForaBank
//
//  Created by Max Gribov on 03.03.2022.
//

import Foundation

extension URLCache {
    
    static let downloadCache: URLCache = {
       
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cachesURL.appendingPathComponent("DownloadCache")
        return URLCache(memoryCapacity: 10_000_000, diskCapacity: 1_000_000_000, directory: diskCacheURL)
    
    }()
}
