import XCTest
import SnapshotTesting
@testable import Tracker_UIKIt

final class TrackerTests: XCTestCase {
    func testViewController() {
        let vc = TabBarController()
                assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .light)), named: "light")
                assertSnapshot(of: vc, as: .image(traits: .init(userInterfaceStyle: .dark)), named: "dark")
    }
}
