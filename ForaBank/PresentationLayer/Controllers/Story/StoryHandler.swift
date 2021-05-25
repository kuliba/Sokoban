//
//  StoryHandler.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.07.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation
import UIKit

class StoryHandler {
    var images: [FeedOffer]
    var storyIndex: Int = 0
    static var userIndex: Int = 0
    
    init(imgs: [FeedOffer]) {
        images = imgs
    }
}
