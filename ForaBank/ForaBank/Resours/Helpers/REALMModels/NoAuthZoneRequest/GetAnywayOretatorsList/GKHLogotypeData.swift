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
