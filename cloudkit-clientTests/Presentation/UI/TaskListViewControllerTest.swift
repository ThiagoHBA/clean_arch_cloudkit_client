//
//  TaskListViewControllerTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 10/01/23.
//

import XCTest
@testable import cloudkit_client

final class TaskListViewControllerTest: XCTestCase {
    func test_init_with_coder() {
        let sut = TaskListViewController(coder: NSCoder())
        XCTAssertNil(sut)
    }
    func test_viewDidLoad_should_call_initState() {
        let (sut, presenter) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(presenter.initStateCalled, 1)
    }
    
    func test_showLoading_should_change_label_correctly() {
        let (sut, presenterSpy) = makeSUT()
        let expectedLabel = "Start Loading"
        let expectation = XCTestExpectation(description: "call completion")
        presenterSpy.view?.showLoading() {
            XCTAssertEqual(sut.label.text, expectedLabel)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func test_hideLoading_should_change_label_correctly() {
        let (sut, presenterSpy) = makeSUT()
        let expectedLabel = "Finish Loading"
        let expectation = XCTestExpectation(description: "call completion")
        presenterSpy.view?.hideLoading() {
            XCTAssertEqual(sut.label.text, expectedLabel)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func test_displayTasks_should_receive_tasks_correctly() {
        let (sut, presenterSpy) = makeSUT()
        let expectation = XCTestExpectation(description: "call completion")
        let expectedTasks = [
            Task(isOpen: false, name: "", subtasks: []),
            Task(isOpen: true, name: "", subtasks: [])
        ]
        presenterSpy.view?.displayTaskList(expectedTasks, completion: {
            XCTAssertEqual(sut.tasks, expectedTasks)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func test_displayError_should_change_label_correctly() {
        let (sut, presenterSpy) = makeSUT()
        let expectedLabel = "Error: Erro! - Localized description"
        let expectation = XCTestExpectation(description: "call completion")
        presenterSpy.view?.displayError(title: "Erro!", message: RepositoryErrorStub.mockedError.localizedDescription, completion: {
            XCTAssertEqual(sut.label.text, expectedLabel)
            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 1)
    }
    
    func test_navigationItem_should_not_be_nil() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertNotNil(sut.navigationItem)
    }
    
    func test_viewDidLoad_should_replace_addButton() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertNotNil(sut.navigationItem.rightBarButtonItem)
    }

    
    func test_viewDidLoad_should_create_addButton_with_title_add() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.navigationItem.rightBarButtonItem?.title, "add")
    }
    
    func test_viewDidLoad_should_change_color_correctly() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.navigationItem.rightBarButtonItem?.tintColor, .systemBlue)
    }
    
    func test_createTaskDialog_should_create_alert_with_textField() {
        let (sut, _) = makeSUT()
        let alertSpy = UIAlertController(title: "", message: "", preferredStyle: .alert)
        sut.createTaskDialog(alertSpy) { _ in }
        XCTAssertNotNil(alertSpy.textFields)
        XCTAssertFalse(alertSpy.textFields!.isEmpty)
    }
    
    func test_createTaskDialog_should_create_an_cancelAction() {
        let (sut, _) = makeSUT()
        let alertSpy = UIAlertController(title: "", message: "", preferredStyle: .alert)
        sut.createTaskDialog(alertSpy) { _ in }
        XCTAssertEqual(
            alertSpy.actions.filter { action in
            action.title == "Cancelar" &&
            action.style == .cancel
        }.count, 1)
    }
    
    func test_createTaskDialog_should_create_an_saveAction() {
        let (sut, _) = makeSUT()
        let alertSpy = UIAlertController(title: "", message: "", preferredStyle: .alert)
        sut.createTaskDialog(alertSpy) { _ in }
        XCTAssertEqual(
            alertSpy.actions.filter { action in
            action.title == "OK" &&
            action.style == .default
        }.count, 1)
    }
    
    func test_createTaskDialog_saveAction_should_not_be_enabled_if_textfield_is_empty() {
        let (sut, _) = makeSUT()
        let alertSpy = UIAlertController(title: "", message: "", preferredStyle: .alert)
        sut.createTaskDialog(alertSpy) { _ in }
        let saveAction = alertSpy.actions.filter { action in
            action.title == "OK" &&
            action.style == .default
        }.first!
        
        XCTAssertFalse(saveAction.isEnabled)
    }
    
    func test_createTaskDialog_saveAction_should_enabled_if_textfield_is_not_empty() {
        let (sut, _) = makeSUT()
        let alertSpy = UIAlertController(title: "", message: "", preferredStyle: .alert)
        sut.createTaskDialog(alertSpy) { _ in }
        
        let saveAction = alertSpy.actions.filter { action in
            action.title == "OK" &&
            action.style == .default
        }.first!
        
        let textField = alertSpy.textFields?.first!
        textField?.text = "some"
        NotificationCenter.default.post(
            Notification(
                name: UITextField.textDidChangeNotification,
                object: alertSpy.textFields?.first!
            )
        )
        
        XCTAssertTrue(saveAction.isEnabled)
    }
    
    func test_createTaskDialog_saveAction_should_not_be_enabled_if_textfield_is_blank() {
        let (sut, _) = makeSUT()
        let alertSpy = UIAlertController(title: "", message: "", preferredStyle: .alert)
        sut.createTaskDialog(alertSpy) { _ in }
        
        let saveAction = alertSpy.actions.filter { action in
            action.title == "OK" &&
            action.style == .default
        }.first!
        
        let textField = alertSpy.textFields?.first!
        textField?.text = " "
        NotificationCenter.default.post(
            Notification(
                name: UITextField.textDidChangeNotification,
                object: alertSpy.textFields?.first!
            )
        )
        
        XCTAssertFalse(saveAction.isEnabled)
    }
    
    func test_createTaskDialog_alert_should_be_presented() {
        let (sut, _) = makeSUT()
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = sut
        alertWindow.makeKeyAndVisible()
        
        let expectation = XCTestExpectation(description: "Completion called")
        let alertSpy = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        sut.createTaskDialog(
            alertSpy,
            completion: {
                XCTAssertTrue(sut.presentedViewController is UIAlertController)
                expectation.fulfill()
            },
            action: { _ in }
        )
        wait(for: [expectation], timeout: 1)
    }
    
    func test_when_presenter_return_to_include_task_should_call_includeTask() {
        let (sut, presenterSpy) = makeSUT()
        let inputTask = Task(isOpen: false, name: "some", subtasks: [])
        presenterSpy.view?.includeTask(inputTask) {}
        XCTAssertTrue(sut.tasks.contains(inputTask))
    }

}

extension TaskListViewControllerTest: Testing {
    typealias SutAndDoubles = (TaskListViewController, TaskListPresenterSpy)
    
    func makeSUT() -> SutAndDoubles {
        let presenterSpy = TaskListPresenterSpy()
        let sut = TaskListViewController(presenter: presenterSpy)
        presenterSpy.view = sut
        return (sut, presenterSpy)
    }
}

class TaskListPresenterSpy: TaskListPresenting {    
    private(set) var initStateCalled = 0
    private(set) var createTaskCalled = 0
    var view: TaskListViewProtocol?
    
    func initState() {
        initStateCalled += 1
    }

    func createTask(_ task: Task) {
        createTaskCalled += 1
    }
}
