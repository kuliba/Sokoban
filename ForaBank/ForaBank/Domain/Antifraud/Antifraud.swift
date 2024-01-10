//
//  Antifraud.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 10.01.2024.
//

import Foundation

enum AntiFraudScenario: String, Codable {
    
    case suspect = "SCOR_SUSPECT_FRAUD"
    case ok = "OK"
}
