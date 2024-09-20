//
//  LocalAgentLoaderComposer+LocalAgentProtocol.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

extension LocalAgentLoaderComposer
where Model: Codable,
      LoadPayload == Model.Type {
    
    func compose(agent: LocalAgentProtocol) -> Loader {
        
        self.compose(
            load: agent.load,
            save: { model in
                
                let serial = agent.serial(for: type(of: model))
                try agent.store(model, serial: serial)
            }
        )
    }
}
