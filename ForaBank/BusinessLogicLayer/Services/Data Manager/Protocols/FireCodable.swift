//
//  FireCodable.swift
//  ForaBank
//
//  Created by Дмитрий Савушкин on 07.09.2020.
//  Copyright © 2020 (C) 2017-2019 OОО "Бриг Инвест". All rights reserved.
//

import Foundation

protocol BaseCodable: class {
  
  var id: String { get set }
  
}

protocol FireCodable: BaseCodable, Codable {
  
  var id: String { get set }
  
}

protocol FireStorageCodable: FireCodable {
  
  var profilePic: UIImage? { get set }
  var profilePicLink: String? { get set }
  
}
