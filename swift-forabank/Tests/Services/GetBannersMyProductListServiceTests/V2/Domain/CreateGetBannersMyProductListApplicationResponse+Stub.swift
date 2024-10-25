//
//  CreateGetBannersMyProductListApplicationResponse+Stub.swift
//
//
//  Created by Valentin Ozerov on 23.10.2024.
//

import RemoteServices
import GetBannersMyProductListService
    
extension ResponseMapper.CreateGetBannersMyProductListApplicationDomain {

    static func makeStub(
        productName: String = anyMessage(),
        link: String = anyMessage(),
        md5hash: String = anyMessage(),
        actionType: Response.Banner.Action.ActionType = .allCases.randomElement() ?? .unknown,
        landingDate: String? = anyMessage(),
        target: String? = anyMessage()
    ) -> Self {

        let banner = Banner.makeStub(
            productName: productName,
            link: link,
            md5hash: md5hash,
            actionType: actionType,
            landingDate: landingDate,
            target: target
        )
        
        return Self(
            loanBannerList: [banner],
            cardBannerList: [banner]
        )
    }
    
    typealias Response = ResponseMapper.CreateGetBannersMyProductListApplicationDomain
}

extension ResponseMapper.CreateGetBannersMyProductListApplicationDomain.Banner {

    static func makeStub(
        productName: String,
        link: String,
        md5hash: String,
        actionType: Response.Banner.Action.ActionType,
        landingDate: String?,
        target: String?
    ) -> Self {

        var action: Action?
        
        action = .makeStub(
            actionType: actionType,
            landingDate: landingDate,
            target: target
        )
        
        return Self(
            productName: productName,
            link: link,
            md5hash: md5hash,
            action: action
        )
    }
    
    typealias Response = ResponseMapper.CreateGetBannersMyProductListApplicationDomain
}

extension ResponseMapper.CreateGetBannersMyProductListApplicationDomain.Banner.Action {

    static func makeStub(
        actionType: Response.Banner.Action.ActionType,
        landingDate: String?,
        target: String?
    ) -> Self {

        Self(
            actionType: actionType,
            landingDate: landingDate,
            target: target
        )
    }
    
    typealias Response = ResponseMapper.CreateGetBannersMyProductListApplicationDomain
}
