//
//  TaskListViewControllerTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 10/01/23.
//

import XCTest
@testable import cloudkit_client

final class TaskListViewControllerTest: XCTestCase {
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
    var view: TaskListViewProtocol?
    
    func initState() {
        initStateCalled += 1
    }
}
