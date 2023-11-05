//
//  CryptoStorageFactory.swift
//  ForaBank
//
//  Created by Igor Malyarov on 05.11.2023.
//

enum CryptoStorageFactory {}

extension CryptoStorageFactory {
    
    static func makeLoggingStore(
        logger: LoggerAgentProtocol
    ) -> any Store<RSADomain.KeyPair> {
        
        let log = { logger.log(level: $0, category: .cache, message: $1, file: $2, line: $3) }
        
        let store = KeyTagKeyChainStore<RSADomain.KeyPair>(keyTag: .rsa)
        let rsaKeyPairStore = LoggingStoreDecorator(
            decoratee: store,
            log: log
        )
        
        return rsaKeyPairStore
    }
}
