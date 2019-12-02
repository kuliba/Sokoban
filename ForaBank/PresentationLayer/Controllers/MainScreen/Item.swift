//
//  Item.swift
//  ForaBank
//
//  Created by Дмитрий on 19/11/2019.
//  Copyright © 2019 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import UIKit

class ICollectionViewCell {
    
    var name: String!
    var image: UIImage!
    
    class func getArray() -> [ICollectionViewCell] {
        var items = [ICollectionViewCell]()
        
        if let imageURLs = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: nil) {
            for url in imageURLs {
                let item = ICollectionViewCell()
                item.name = url.deletingPathExtension().lastPathComponent
                item.image = UIImage(contentsOfFile: url.path)
                items.append(item)
            }
        }
        
        return items
    }
}
