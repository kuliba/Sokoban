//
//  Unimplemented.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 12.05.2023.
//

@testable import ForaBank
import ServerAgent

func unimplemented<T>(
    _ message: String = "",
    file: StaticString = #file,
    line: UInt = #line
) -> T {

    fatalError("Unimplemented: \(message)", file: file, line: line)
}

extension Model {

    /// Special helper that creates model that crashes at first cal to its internals.
    /// Used in tests to provide assurance that even if model is required by existing API,
    /// its in not actually used inside.
    static func unimplementedMock() -> Model {
        
        .init(
            sessionAgent:        .unimplementedMock(),
            serverAgent:         .unimplementedMock(),
            localAgent:          .unimplementedMock(),
            keychainAgent:       .unimplementedMock(),
            settingsAgent:       .unimplementedMock(),
            biometricAgent:      .unimplementedMock(),
            locationAgent:       .unimplementedMock(),
            contactsAgent:       .unimplementedMock(),
            cameraAgent:         .unimplementedMock(),
            imageGalleryAgent:   .unimplementedMock(),
            networkMonitorAgent: .unimplementedMock(),
            clientInformAlertManager: AlertManagerSpy()
        )
    }
}

extension SessionAgentProtocol where Self == SessionAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}

extension ServerAgentProtocol where Self == ServerAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}

extension LocalAgentProtocol where Self == LocalAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}

extension KeychainAgentProtocol where Self == ValetKeychainAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}

extension SettingsAgentProtocol where Self == UserDefaultsSettingsAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}

extension BiometricAgentProtocol where Self == BiometricAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}

extension LocationAgentProtocol where Self == LocationAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}

extension ContactsAgentProtocol where Self == ContactsAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}

extension CameraAgentProtocol where Self == CameraAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}

extension ImageGalleryAgentProtocol where Self == ImageGalleryAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}

extension NetworkMonitorAgentProtocol where Self == NetworkMonitorAgent {
    
    static func unimplementedMock() -> Self { unimplemented() }
}
