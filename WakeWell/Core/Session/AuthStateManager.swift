import Foundation

extension Notification.Name {
    static let authStateDidChange = Notification.Name("wakewell.authStateDidChange")
}

final class AuthStateManager {

    static let shared = AuthStateManager()

    private let keychainService = "com.wakewell.session"
    private let keychainAccount = "active_user_session"
    private let defaultsKey = "ww_logged_in"

    private(set) var currentSession: UserSession?

    private init() {
        _ = restoreSession()
    }

    var isAuthenticated: Bool {
        currentSession != nil
    }

    func restoreSession() -> UserSession? {
        guard let data = KeychainStore.shared.load(service: keychainService, account: keychainAccount),
              let session = try? JSONDecoder().decode(UserSession.self, from: data) else {
            currentSession = nil
            UserDefaults.standard.set(false, forKey: defaultsKey)
            return nil
        }

        currentSession = session
        UserDefaults.standard.set(true, forKey: defaultsKey)
        return session
    }

    func signIn(_ session: UserSession) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        _ = KeychainStore.shared.save(data: data, service: keychainService, account: keychainAccount)
        currentSession = session
        UserDefaults.standard.set(true, forKey: defaultsKey)
        NotificationCenter.default.post(name: .authStateDidChange, object: nil)
    }

    func signOut() {
        KeychainStore.shared.delete(service: keychainService, account: keychainAccount)
        currentSession = nil
        UserDefaults.standard.set(false, forKey: defaultsKey)
        UserDefaults.standard.removeObject(forKey: "wakewell.savedAlarmTime")
        NotificationCenter.default.post(name: .authStateDidChange, object: nil)
    }
}
