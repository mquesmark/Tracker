

import Foundation
import AppMetricaCore

final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}

    func reportUIEvent(screen: String, event: String, item: String? = nil) {
        var params: [String: String] = [
            "event": event,
            "screen": screen
        ]
        if let item = item { params["item"] = item }
        let name = "ui_event"
        print("METRICA SEND -> \(name) params: \(params)")
        AppMetrica.reportEvent(name: name, parameters: params) { error in
            print("DID FAIL REPORT EVENT: \(name)")
            print("REPORT ERROR: \(error.localizedDescription)")
        }
    }
}
