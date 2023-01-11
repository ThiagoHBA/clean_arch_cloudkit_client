//
//  CreateTaskUseCaseTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 10/01/23.
//

import XCTest
@testable import cloudkit_client

final class CreateTaskUseCaseTest: XCTestCase {
    func test_execute_should_not_allow_create_task_with_nil_input() {
        let (sut, (_, outputSpy)) = makeSUT()
        sut.execute()
        XCTAssertEqual(outputSpy.receivedMessages, [])
    }
    
    func test_execute_should_not_allow_create_task_with_name_empty() {
        let (sut, (_, outputSpy)) = makeSUT()
        let expectedError = EmptyTaskNameError()
        sut.input = Task(isOpen: false, name: "   ", subtasks: [])
        sut.execute()
        XCTAssertEqual(outputSpy.receivedMessages, [.errorWhileCreatingTask(expectedError)])
    }
    
    func test_execute_should_call_findTask_if_name_isnt_empty() {
        let (sut, (repoSpy, _)) = makeSUT()
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        repoSpy.findTaskData = { return inputTask }
        sut.input = inputTask
        sut.execute()
        XCTAssertEqual(repoSpy.findTaskCalled, 1)
    }
    
    func test_execute_should_not_allow_create_task_if_task_with_same_name_alreay_exist() {
        let (sut, (repoSpy, outputSpy)) = makeSUT()
        let expectedError = TaskNameAlreadyExistError()
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        repoSpy.findTaskData = { return inputTask }
        sut.input = inputTask
        sut.execute()
        XCTAssertEqual(outputSpy.receivedMessages, [.errorWhileCreatingTask(expectedError)] )
    }
    
    func test_execute_when_success_should_call_output_correctly() {
        let (sut, (repoSpy, outputSpy)) = makeSUT()
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        repoSpy.findTaskData = { return nil }
        sut.input = inputTask
        sut.execute()
        XCTAssertEqual(outputSpy.receivedMessages, [.succesfullyCreateTask(inputTask)])
    }

}

extension CreateTaskUseCaseTest: Testing {
    typealias SutAndDoubles = (CreateTaskUseCase, (TaskRepositorySpy, CreateTaskUseCaseOutputSpy))
    
    func makeSUT() -> SutAndDoubles {
        let repositorySpy = TaskRepositorySpy()
        let useCaseOutputSpy = CreateTaskUseCaseOutputSpy()
        let sut = CreateTaskUseCase(repository: repositorySpy)
        sut.output = useCaseOutputSpy
        return (sut, (repositorySpy, useCaseOutputSpy))
    }
    
}
