import Foundation
import AppMetricaCore

final class AnalyticsService {

    // MARK: - Static Methods
    static func initAnalytics() {
        guard let configuration = AppMetricaConfiguration(apiKey: "3f8e5a6b-8dff-4066-a2f7-38fb4074cd7a") else {
            return
        }
        AppMetrica.activate(with: configuration)
    }
    static func reportEvent(event: String, screen: String, item: String? = nil) {
        var params : [AnyHashable : Any] = ["event": event, "screen": screen]
        if let item = item {
            params["item"] = item
        }
        AppMetrica.reportEvent(name: event, parameters: params) { error in
            print("[AnalyticsService.reportEvent]: Ошибка: \(String(describing: error))")
        }
    }
}

