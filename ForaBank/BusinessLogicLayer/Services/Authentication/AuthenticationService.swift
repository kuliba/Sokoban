
import Foundation

class AuthenticationService: IAuthenticationService {

    static let shared: IAuthenticationService = AuthenticationServiceInitializer.createAuthenticationService()

    private struct Constants {
        static let expireTime: TimeInterval = 1 * 60
    }

    var refresher: AuthenticationRefresher?
    var isAuthorized: Bool
    var isUserSessionAlive: Bool

    init(isAuthorized: Bool, isUserSessionAlive: Bool) {
        self.isAuthorized = isAuthorized
        self.isUserSessionAlive = isUserSessionAlive
    }

    //TODO: - Refactor

    public func afterLogin() {
        isAuthorized = true
        isUserSessionAlive = true
        refresher?.launchTimer(repeats: false, timeInterval: Constants.expireTime)
    }

    public func startSecurityCheckIfNeeded() {
        guard !isUserSessionAlive else { return }
        if PasscodeService.shared.isPasscodeSetted && PasscodeService.shared.allowedPasscode {
            PasscodeService.shared.showPasscodeScreen()
        } else if !PasscodeService.shared.isPasscodeSetted && PasscodeService.shared.allowedPasscode {
            logoutWithoutClearUserData()
        } else if !PasscodeService.shared.isPasscodeSetted {
            logoutAndClearAllUserData()
        }
    }

    public func logoutAndClearAllUserData() {
        isAuthorized = false
        isUserSessionAlive = false
        store.dispatch(doLogout)
        store.dispatch(clearPasscodeData)
        refresher?.invalidateTimer()
        UserDefaults.standard.removeObject(forKey: "sbpAgree")
        
    }

    public func logoutWithoutClearUserData() {
        isAuthorized = false
        isUserSessionAlive = false
        store.dispatch(doLogout)
        refresher?.invalidateTimer()
    }

    public func onAuthCanceled() {
        logoutAndClearAllUserData()
    }
}

extension AuthenticationService: IRefreshing {
    func refresh() {
        isUserSessionAlive = false
    }
}
