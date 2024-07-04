//
//  NotificationObserver.swift
//
//
//  Created by Дмитрий Савушкин on 04.07.2024.
//

import Foundation
import Combine

public class NotificationObserver<T>: ObservableObject {

    private var bindings = Set<AnyCancellable>()

    public init(
        notificationName: String,
        userInfoKey: String,
        onReceive: @escaping (T) -> Void
    ) {
        NotificationCenter.default
            .observe(
                notificationName: notificationName,
                userInfoKey: userInfoKey
            )
            .receive(on: DispatchQueue.main)
            .sink { [onReceive] in onReceive($0) }
            .store(in: &bindings)
    }
}
