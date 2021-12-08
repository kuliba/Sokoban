//
//  RequisiteDO.swift
//  ForaBank
//
//  Created by Роман Воробьев on 04.12.2021.
//

import Foundation

class RequisiteDO {
    static func convertParameter(_ item: Parameters) -> RequisiteDO {
        let ob = RequisiteDO()
        ob.id = item.id
        ob.order = item.order
        ob.title = item.title
        ob.subTitle = item.subTitle
        ob.viewType = item.viewType
        ob.dataType = item.dataType
        ob.type = item.type
        ob.mask = item.mask
        ob.regExp = item.regExp
        ob.maxLength = item.maxLength
        ob.minLength = item.minLength
        ob.rawLength = item.rawLength
        ob.readOnly = item.readOnly
        ob.content = item.content
        ob.svgImage = item.svgImage
        return  ob
    }

    static func convertParameter(_ item: ParameterListForNextStep2) -> RequisiteDO {
        let ob = RequisiteDO()
        ob.id = item.id
        ob.order = item.order ?? 0
        ob.title = item.title
        ob.subTitle = item.subTitle
        ob.viewType = item.viewType
        ob.dataType = item.dataType
        ob.type = item.type
        ob.mask = item.mask
        ob.regExp = item.regExp
        ob.maxLength = item.maxLength ?? 0
        ob.minLength = item.minLength ?? 0
        ob.rawLength = item.rawLength ?? 0
        ob.readOnly = item.readOnly ?? false
        ob.content = item.content
        ob.svgImage = item.svgImage
        return  ob
    }

    var id: String?
    var order = 0
    var title: String?
    var subTitle: String?
    var viewType: String?
    var dataType: String?
    var type: String?
    var mask: String?
    var regExp: String?
    var maxLength = 0
    var minLength = 0
    var rawLength = 0
    var readOnly = true
    var content: String?
    var svgImage: String?
}
