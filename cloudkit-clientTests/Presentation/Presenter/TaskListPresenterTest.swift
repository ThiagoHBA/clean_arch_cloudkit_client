//
//  TaskListPresenterTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 09/01/23.
//

import XCTest
@testable import cloudkit_client

final class TaskListPresenterTest: XCTestCase {
    func test_initState_should_call_useCase() {
        let (sut, (repositorySpy, _)) = makeSUT()
        repositorySpy.fetchAllTasksData = {.success([])}
        sut.initState()
        XCTAssertEqual(repositorySpy.fetchAllTasksCalled, 1)
    }
    
    func test_initState_when_success_should_call_delegate_correctly() {
        let (sut, (repositorySpy, viewDelegateSpy)) = makeSUT()
        let inputTasks = [Task(isOpen: false, name: "", subtasks: [])]
        let expectedTasks = [Task(isOpen: false, name: "", subtasks: [])]
        
        repositorySpy.fetchAllTasksData = {.success(inputTasks)}
        sut.initState()
        XCTAssertEqual(viewDelegateSpy.receivedMessages, [.showLoading, .hideLoading, .displayTaskList(expectedTasks)])
    }
    
    func test_initState_when_error_should_call_delegate_correctly() {
        let (sut, (repositorySpy, viewDelegateSpy)) = makeSUT()
        let inputError = RepositoryErrorStub.mockedError
        repositorySpy.fetchAllTasksData = {.failure(inputError)}
        sut.initState()
        XCTAssertEqual(viewDelegateSpy.receivedMessages, [.showLoading, .hideLoading, .displayError("Erro ao listar taféfas!", "Localized description")])
    }
    
    func test_createTask_should_call_useCase() {
        let (sut, (repoSpy, _)) = makeSUT()
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        repoSpy.findTaskData = { return nil }
        repoSpy.createTaskData = { .success(inputTask) }
        sut.createTask(inputTask)
        XCTAssertEqual(repoSpy.createTaskCalled, 1)
    }
    
    func test_createTask_should_call_view_loading() {
        let (sut, (repoSpy, viewSpy)) = makeSUT()
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        repoSpy.findTaskData = { return nil }
        repoSpy.createTaskData = { .success(inputTask) }
        sut.createTask(inputTask)
        XCTAssertTrue(viewSpy.receivedMessages.contains(.showLoading))
    }
    
    func test_createTask_when_success_should_call_delegate_correctly() {
        let (sut, (repoSpy, viewSpy)) = makeSUT()
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        repoSpy.findTaskData = { return nil }
        repoSpy.createTaskData = { .success(inputTask) }
        sut.createTask(inputTask)
        XCTAssertEqual(viewSpy.receivedMessages, [.showLoading, .hideLoading, .includeTask(inputTask)])
    }
    
    func test_createTask_when_error_should_call_delegate_correctly() {
        let (sut, (repoSpy, viewSpy)) = makeSUT()
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        let inputError = RepositoryErrorStub.mockedError
        repoSpy.findTaskData = { return nil }
        repoSpy.createTaskData = { .failure(inputError) }
        sut.createTask(inputTask)
        XCTAssertEqual(viewSpy.receivedMessages, [.showLoading, .hideLoading, .displayError("Erro ao criar taréfa!", inputError.localizedDescription)])
    }
}

extension TaskListPresenterTest: Testing {
    typealias SutAndDoubles = (TaskListPresenter, (TaskRepositorySpy, TaskListViewSpy))
    
    func makeSUT() -> SutAndDoubles {
        let repositorySpy = TaskRepositorySpy()
        let listUseCase = ListTasksUseCase(repository: repositorySpy)
        let createTaskUseCase = CreateTaskUseCase(repository: repositorySpy)
        let taskViewSpy = TaskListViewSpy()
        let sut = TaskListPresenter(
            listTaskUseCase: listUseCase,
            createTaskUseCase: createTaskUseCase
        )
        listUseCase.output = sut
        createTaskUseCase.output = sut
        sut.view = taskViewSpy
        return (sut, (repositorySpy, taskViewSpy))
    }
}
