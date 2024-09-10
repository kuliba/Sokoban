//
//  LocalAgentLoaderComposer+LocalAgentProtocol.swift
//  ForaBank
//
//  Created by Igor Malyarov on 09.09.2024.
//

extension LocalAgentLoaderComposer
where Model: Codable,
      LoadPayload == Model.Type {
    
    func compose(
        agent: LocalAgentProtocol,
        serial: @escaping (Model) -> String?
    ) -> Loader {
        
        self.compose(
            load: agent.load,
            save: { model in try agent.store(model, serial: serial(model)) }
        )
    }
}
