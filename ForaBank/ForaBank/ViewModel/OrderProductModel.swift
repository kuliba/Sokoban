//
//  OrderProductModel.swift
//  ForaBank
//
//  Created by Mikhail on 01.06.2021.
//

import UIKit

class OrderProductModel {
    var backgroundName: String
    var title: String
    var subtitle: String
    var textColor: UIColor
    var urlString: String
    
    var orderURL: URL? {
        guard let url = URL(string: urlString) else { return URL(string: "") }
        return url
    }

    
    init(image: String, title: String, subtitle: String, url: String ,color: UIColor = #colorLiteral(red: 0.1098039216, green: 0.1098039216, blue: 0.1098039216, alpha: 1)) {
        self.backgroundName = image
        self.title = title
        self.subtitle = subtitle
        self.textColor = color
        self.urlString = url
    }
}
