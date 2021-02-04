import XCTest
import Combine
@testable import Cancellor

#if os(iOS)
import UIKit
typealias ViewController = UIViewController
#elseif os(macOS)
import Cocoa
typealias ViewController = NSViewController
#endif

fileprivate var testCancelEvents = [String]()
fileprivate var testCancelOwnerEvents = [String]()

final class CancellorTests: XCTestCase {
    
    class TestViewController: ViewController {
        let subject = CurrentValueSubject<Int, Never>(1)

        override func viewDidLoad() {
            ownedCancellables {
                subject.handleEvents { _ in
                    testCancelEvents.append("subscribe")
                } receiveOutput: {
                    testCancelEvents.append("emit \($0)")
                } receiveCompletion: { _ in
                } receiveCancel: {
                    testCancelEvents.append("cancel")
                } receiveRequest: { _ in
                }
                .sink(receiveValue: { _ in })
            }
        }
    }
    
    func testCancel() {
        var vc: TestViewController? = TestViewController()
        vc?.viewDidLoad()
        XCTAssertEqual(testCancelEvents, ["subscribe", "emit 1"])
        vc?.subject.send(2)
        XCTAssertEqual(testCancelEvents, ["subscribe", "emit 1", "emit 2"])
        vc = nil
        XCTAssertEqual(testCancelEvents, ["subscribe", "emit 1", "emit 2", "cancel"])
    }
    
    class TestViewModel: NSObject { }
    
    func testOwnerCancel() {
        var vm: TestViewModel? = TestViewModel()
        let subject = CurrentValueSubject<Int, Never>(1)
        
        subject
            .handleEvents { _ in
                testCancelOwnerEvents.append("subscribe")
            } receiveOutput: {
                testCancelOwnerEvents.append("emit \($0)")
            } receiveCompletion: { _ in
            } receiveCancel: {
                testCancelOwnerEvents.append("cancel")
            } receiveRequest: { _ in
            }
            .sink(receiveValue: { _ in })
            .owned(by: vm!)
        
        XCTAssertEqual(testCancelOwnerEvents, ["subscribe", "emit 1"])
        subject.send(2)
        XCTAssertEqual(testCancelOwnerEvents, ["subscribe", "emit 1", "emit 2"])
        vm = nil
        XCTAssertEqual(testCancelOwnerEvents, ["subscribe", "emit 1", "emit 2", "cancel"])
    }
}
