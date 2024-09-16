//
//  StringSerialRemoteDomain.swift
//  ForaBank
//
//  Created by Igor Malyarov on 14.09.2024.
//

import RemoteServices

typealias StringSerialRemoteDomain<Payload, T> = RemoteDomainOf<Payload, RemoteServices.SerialStamped<String, T>, Error>
