import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerScreenshotTests: XCTestCase {
    
    func testTrackersListOnWhiteTheme() {
        let tab = MainTabBarController()
        tab.loadViewIfNeeded()
        tab.viewControllers?[0].loadViewIfNeeded()
        let listVC = tab.viewControllers?.first as? TrackersListViewController
        listVC?.view.layoutIfNeeded()
        
        assertSnapshot(of: tab, as: .image)
    }
    
}
