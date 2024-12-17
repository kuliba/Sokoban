//
//  GKHParametersModel.swift
//  ForaBank
//
//  Created by Константин Савялов on 30.08.2021.
//

import Foundation
import RealmSwift

// MARK: - ParameterList
class Parameters: Object {

    @objc dynamic var id: String?
    @objc dynamic var order = 0
    @objc dynamic var title: String?
    @objc dynamic var subTitle: String?
    @objc dynamic var viewType: String?
    @objc dynamic var dataType: String?
    @objc dynamic var type: String?
    @objc dynamic var mask: String?
    @objc dynamic var regExp: String?
    @objc dynamic var maxLength = 0
    @objc dynamic var minLength = 0
    @objc dynamic var rawLength = 0
    @objc dynamic var readOnly = false
    @objc dynamic var content: String?
    @objc dynamic var svgImage: String?
}

extension Parameters {
    
    convenience init?(with data: ParameterList, for types: [String]?) {
        
        if let types = types {
            
            guard let viewType = data.viewType, types.contains(viewType) == true else {
                return nil
            }
            
            self.init(with: data)
            
        } else {
            
            self.init(with: data)
        }
    }
    
    convenience init(with data: ParameterList) {
        
        self.init()
        id        = data.id
        order     = data.order ?? 0
        title     = data.title
        subTitle  = data.subTitle
        viewType  = data.viewType
        dataType  = data.dataType
        type      = data.type
        mask      = data.mask
        regExp    = data.regExp
        maxLength = data.maxLength ?? 0
        minLength = data.minLength ?? 0
        rawLength = data.rawLength ?? 0
        readOnly  = data.readOnly ?? false
        content   = data.content
        svgImage  = data.svgImage
    }
}
