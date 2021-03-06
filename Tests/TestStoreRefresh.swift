@testable import holbox
import XCTest

final class TestStoreRefresh: XCTestCase {
    private var store: Store!
    private var shared: StubShared!
    private var coder: Coder!
    private var session: Session!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
        coder = .init()
        shared = .init()
        session = .init()
        store = .init()
        try? FileManager.default.removeItem(at: store.url)
        store.shared = shared
        store.prepare()
        session.store = store
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: store.url)
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session"))
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project"))
    }
    
    func testRefresh() {
        let expect = expectation(description: "")
        DispatchQueue.global(qos: .background).async {
            self.session.refresh {
                XCTAssertTrue($0.isEmpty)
                XCTAssertEqual(Thread.main, Thread.current)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testRefreshable() {
        XCTAssertFalse(session.refreshable)
        session.refreshed = 0
        XCTAssertTrue(session.refreshable)
    }
    
    func testRefreshInterval() {
        let expectStore = expectation(description: "")
        let expectAll = expectation(description: "")
        let store = StubStore()
        session.refreshed = 0
        store.refresh = { _ in
            expectStore.fulfill()
        }
        self.session.store = store
        self.session.refresh {
            XCTAssertTrue($0.isEmpty)
            DispatchQueue.global(qos: .background).async {
                self.session.refresh {
                    XCTAssertTrue($0.isEmpty)
                    expectAll.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNoSession() {
        let expect = expectation(description: "")
        store.refresh(session) {
            XCTAssertTrue($0.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNoProjects() {
        let expect = expectation(description: "")
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
        store.refresh(session) {
            XCTAssertTrue($0.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNothingNew() {
        let expect = expectation(description: "")
        session.items[0] = .init()
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
        shared.load = {
            $0.forEach {
                XCTAssertEqual("session", $0)
            }
        }
        store.refresh(session) {
            XCTAssertTrue($0.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testNothingNewWithProject() {
        let expect = expectation(description: "")
        var project = Project()
        project.time = .init(timeIntervalSince1970: 100)
        session.items[0] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(session).write(to: shared.url["session"]!)
        shared.load = {
            $0.forEach {
                XCTAssertEqual("session", $0)
            }
        }
        store.refresh(session) {
            XCTAssertTrue($0.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDownloadFailed() {
        let expect = expectation(description: "")
        let online = Session()
        var project = Project()
        project.mode = .kanban
        online.items[99] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        try! coder.global(online).write(to: shared.url["session"]!)
        store.refresh(session) {
            XCTAssertTrue($0.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testDownload() {
        let expect = expectation(description: "")
        let online = Session()
        var project = Project()
        project.mode = .kanban
        online.items[99] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["99"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(online).write(to: shared.url["session"]!)
        try! coder.project(project).write(to: shared.url["99"]!)
        store.refresh(session) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(99, $0.first)
            let session = Session()
            try! self.coder.session(session, data: .init(contentsOf: self.store.url.appendingPathComponent("session.holbox")))
            let stored = try! self.coder.project(.init(contentsOf: self.store.url.appendingPathComponent("99")))
            XCTAssertNotNil(session.items[99])
            XCTAssertEqual(.off, session.items.first?.1.mode)
            XCTAssertNotNil(self.session.items[99])
            XCTAssertEqual(.kanban, self.session.items.first?.1.mode)
            XCTAssertEqual(.kanban, stored.mode)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testUpdate() {
        let expect = expectation(description: "")
        var project = Project()
        project.name = "lorem"
        session.items[0] = project
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["0"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(session).write(to: shared.url["session"]!)
        try! coder.project(project).write(to: shared.url["0"]!)
        session.items[0]!.time = .init(timeIntervalSince1970: 10)
        session.items[0]!.name = "ipsum"
        store.refresh(session) {
            XCTAssertEqual(1, $0.count)
            XCTAssertEqual(0, $0.first)
            let session = Session()
            try! self.coder.session(session, data: .init(contentsOf: self.store.url.appendingPathComponent("session.holbox")))
            let stored = try! self.coder.project(.init(contentsOf: self.store.url.appendingPathComponent("0")))
            XCTAssertEqual("lorem", self.session.items.first?.1.name)
            XCTAssertEqual("lorem", stored.name)
            XCTAssertEqual(1, session.items.count)
            XCTAssertEqual(1, self.session.items.count)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
    
    func testReturnsProjects() {
        let expect = expectation(description: "")
        session.items = [33: .init(), 41: .init()]
        shared.url["session"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_session")
        shared.url["33"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        shared.url["41"] = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tmp_project")
        try! coder.global(session).write(to: shared.url["session"]!)
        try! coder.project(.init()).write(to: shared.url["33"]!)
        try! coder.project(.init()).write(to: shared.url["41"]!)
        session.items = [:]
        store.refresh(session) {
            XCTAssertEqual(2, $0.count)
            XCTAssertTrue($0.contains(33))
            XCTAssertTrue($0.contains(41))
            expect.fulfill()
        }
        waitForExpectations(timeout: 1)
    }
}
