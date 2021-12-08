//
//  GKHLogotypeData.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.08.2021.
//

import Foundation
import RealmSwift

// MARK: - LogotypeData
class LogotypeData: Object {
    
    @objc dynamic var content: String?
    @objc dynamic var name: String?
    @objc dynamic var code: String?
    @objc dynamic var svgImage: String?
}

extension LogotypeData {
    
    convenience init(with data: LogotypeList, and code: String?) {
        
        self.init()
        self.content = data.content
        self.name    = data.name
        self.code    = code
        self.svgImage = data.svgImage
        
        //FIXME: contentType missed from LogotypeList
    }
}
