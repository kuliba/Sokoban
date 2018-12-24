//
//  DepositsService.swift
//  ForaBank
//
//  Created by Sergey on 24/12/2018.
//  Copyright © 2018 BraveRobin. All rights reserved.
//

import Foundation
import Alamofire

class TestDepositsService: DepositsServiceProtocol {
    
    private var bonds: [Bond] = {
        var b1 = Bond.init(corporateLogo: UIImage(named: "deposits_obligations_afk"),
                           corporate: "АФК-Система, Sistema-19",
                           rate: 8.83,
                           tempInfo: "Предложений по бумаге нет")
        var b2 = Bond.init(corporateLogo: UIImage(named: "deposits_obligations_gazprom"),
                           corporate: "Газпром, GAZ-37",
                           rate: 5.37,
                           tempInfo: "Предложений по бумаге нет")
        var b3 = Bond.init(corporateLogo: UIImage(named: "deposits_obligations_veb"),
                           corporate: "ВЭБ, VEB-23",
                           rate: 4.04,
                           tempInfo: "Предложений по бумаге нет")
        var b4 = Bond.init(corporateLogo: UIImage(named: "deposits_obligations_rosnef"),
                           corporate: "Роснэфть, RosNef-22",
                           rate: 3.84,
                           tempInfo: "Гипермаркет")

        return [b1, b2, b3, b4]
    }()
    
    func getBonds(headers: HTTPHeaders, completionHandler: @escaping (Bool, [Bond]?, String?) -> Void) {
        completionHandler(true, bonds, nil)
    }
}
