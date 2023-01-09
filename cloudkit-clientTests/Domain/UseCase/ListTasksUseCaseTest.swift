//
//  ListTasksUseCaseTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 09/01/23.
//

import XCTest
@testable import cloudkit_client

final class ListTasksUseCaseTest: XCTestCase {
    weak var weakSUT: ListTasksUseCase?
    
    override func tearDown() { XCTAssertNil(weakSUT) }
    
    func test_execute_should_call_repository() {
        let (sut, (repository, _)) = makeSUT()
        repository.fetchAllTasksData = {.success([])}
        sut.execute()
        XCTAssertEqual(repository.fetchAllTasksCalled, 1)
    }
    
    func test_execute_when_repository_fetch_should_call_output() {
        let (sut, (repository, output)) = makeSUT()
        let expectedTasks = [Task(isOpen: false, name: "", subtasks: [])]
        repository.fetchAllTasksData = { .success(expectedTasks) }
        sut.execute()
        XCTAssertEqual(output.receivedMessages, [.tasksAreFetched(expectedTasks)])
    }
    
    func test_execute_when_repository_return_error_should_call_output_with_error() {
        let (sut, (repository, output)) = makeSUT()
        let expectedError = RepositoryErrorStub.mockedError
        repository.fetchAllTasksData = { .failure(expectedError) }
        sut.execute()
        XCTAssertEqual(output.receivedMessages, [.errorWhileFetchingTasks(expectedError)])
    }
    
}

extension ListTasksUseCaseTest: Testing {
    typealias SutAndDoubles = (ListTasksUseCase, (TaskRepositorySpy, ListTasksUseCaseOutputSpy))
    
    func makeSUT() -> SutAndDoubles {
        let repositorySpy = TaskRepositorySpy()
        let outputSpy = ListTasksUseCaseOutputSpy()
        let sut = ListTasksUseCase(repository: repositorySpy)
        sut.output = outputSpy
        weakSUT = sut
        return (sut, (repositorySpy, outputSpy))
    }
}
