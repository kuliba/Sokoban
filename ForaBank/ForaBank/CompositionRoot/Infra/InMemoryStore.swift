//
//  InMemoryStore.swift
//  ForaBank
//
//  Created by Igor Malyarov on 22.10.2023.
//

import CVVPINServices

#warning("move `InMemoryStore` to `Infra` module")
typealias InMemoryStore<Model> = CVVPINServices.InMemoryStore<Model>
