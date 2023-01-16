//
//  TaskRepositoryTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 31/12/22.
//

import XCTest
import CloudKit
@testable import cloudkit_client

final class TaskRepositoryTest: XCTestCase {
    weak var weakSUT: TaskRepository<TaskMapperSpy>?
    
    override func tearDown() {
        super.tearDown()
        XCTAssertNil(weakSUT)
    }
    
    func test_fetchAllTasks_when_no_values_return_empty_list() {
        let (sut, (taskMock, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")

        sut.fetchAllTasks { result in
            switch result {
                case .success(let taskList):
                    XCTAssertEqual([], taskList)
                case .failure(_):
                    XCTFail("List should be initialized with zero values")
                }
            expectation.fulfill()
        }

        taskMock.fetchAllData!(.success([]))
        wait(for: [expectation], timeout: 1)
    }

    func test_fetchAllTasks_when_no_values_fetch_called_only_once() {
        let (sut, (taskSpy, mapper)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")

        sut.fetchAllTasks { _ in expectation.fulfill() }

        taskSpy.fetchAllData!(.success([]))
        XCTAssertEqual(taskSpy.fetchAllCalled, 1)
        XCTAssertEqual(mapper.mapToDomainCalled, 0)
        wait(for: [expectation], timeout: 1)
    }
    
    func test_fetchAllTasks_when_values_fetch_mapper_call_as_much_need() {
        let (sut, (taskSpy, mapper)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let expectedTask = Task(isOpen: false, name: "", subtasks: [])
        mapper.mapToDomainData = { (expectedTask, nil) }

        sut.fetchAllTasks { _ in expectation.fulfill() }

        taskSpy.fetchAllData!(
            .success([
                CKRecord.init(recordType: "TaskItem"),
                CKRecord.init(recordType: "TaskItem"),
                CKRecord.init(recordType: "TaskItem"),
                CKRecord.init(recordType: "TaskItem")
            ])
        )
        
        XCTAssertEqual(taskSpy.fetchAllCalled, 1)
        XCTAssertEqual(mapper.mapToDomainCalled, 4)
        
        wait(for: [expectation], timeout: 1)
    }

    func test_fetchAllTasks_when_error_should_handle_correctly() {
        let (sut, (taskSpy, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let networkFailureCode = CKError.Code(rawValue: 4)!
        let networkFailureDescription = "Não foi possível concluir a operação devido uma falha na comunicação da internet! Verifique sua conexão e tente novamente"
        let error = CKError(networkFailureCode)


        sut.fetchAllTasks { result in
            switch result {
                case .success(_):
                    XCTFail("fetchAllTasks complete operation successfully while should fail")
                case .failure(let error):
                    XCTAssertEqual(error.localizedDescription,  networkFailureDescription)
                }
            expectation.fulfill()
        }
        taskSpy.fetchAllData!(.failure(error))
        wait(for: [expectation], timeout: 1)
    }

    func test_fetchAllTasks_when_error_should_no_call_fetch_subtasks() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let networkFailureCode = CKError.Code(rawValue: 4)!
        let error = CKError(networkFailureCode)

        sut.fetchAllTasks { _ in expectation.fulfill()}

        taskSpy.fetchAllData!(.failure(error))
        XCTAssertEqual(mapperSpy.mapToDomainCalled, 0)
        wait(for: [expectation], timeout: 1)
    }

    func test_fetchAllTasks_when_fail_should_map_correctly_unkwown_errors() {
        let (sut, (taskSpy, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let unknownErrorFailureCode = CKError.Code(rawValue: 0)! //
        let unknownErrorExpectedDescription = "Erro não mapeado! Verifique se existe alguma atualização do aplicativo disponível e tente novamente."
        let error = CKError(unknownErrorFailureCode)

        sut.fetchAllTasks { result in
            switch result {
                case .success(_):
                    XCTFail("fetchAllTasks complete operation successfully while should fail")
                case .failure(let error):
                    XCTAssertEqual(error.localizedDescription,  unknownErrorExpectedDescription)
            }
            expectation.fulfill()
        }
        taskSpy.fetchAllData!(.failure(error))
        wait(for: [expectation], timeout: 1)
    }

    func test_fetchAllTask_when_multiple_tasks_completion_should_wait_mapper_to_complete() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let expectedTask = Task(isOpen: false, name: "", subtasks: [])
        mapperSpy.mapToDomainData = { (expectedTask, nil) }

        sut.fetchAllTasks { result in
            expectation.fulfill()
            switch result {
                case .success(let taskList):
                    XCTAssertEqual(taskList.filter { $0 == expectedTask }.count, 4)
                case .failure(let error):
                    XCTFail("Should not raise error, but: \(error.localizedDescription)")
            }
        }
        
        taskSpy.fetchAllData!(
            .success([
                CKRecord.init(recordType: "TaskItem"),
                CKRecord.init(recordType: "TaskItem"),
                CKRecord.init(recordType: "TaskItem"),
                CKRecord.init(recordType: "TaskItem")
            ])
        )
        wait(for: [expectation], timeout: 1)
    }

    func test_fetchAllTasks_when_mapper_return_task_should_append_on_list() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectedTask = Task(isOpen: false, name: "", subtasks: [])
        let expectation = XCTestExpectation(description: "completionCalled")
        mapperSpy.mapToDomainData = { (expectedTask, nil) }

        sut.fetchAllTasks { result in
            switch result {
            case .success(let recordList):
                XCTAssertNotNil(recordList.first)
                XCTAssertEqual(recordList.first!, Task(isOpen: false, name: "", subtasks: []))
            case .failure(let error):
                XCTFail("Operation should not return error: \(error)")
            }
            expectation.fulfill()
        }
        taskSpy.fetchAllData!(.success([CKRecord.init(recordType: "TaskItem")]))
        wait(for: [expectation], timeout: 1)
    }

    func test_fetchAllTasks_when_mapper_return_error_should_complete_error() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        mapperSpy.mapToDomainData = { (nil, DomainEntityMapperError(domainEntityErrorDescription: "")) }

        sut.fetchAllTasks { result in
            switch result {
                case .success(let recordList):
                    XCTFail("Operation should not complete with success, but: \(recordList)")
                case .failure(_):
                    break
            }
            expectation.fulfill()
        }
        taskSpy.fetchAllData!(.success([CKRecord.init(recordType: "TaskItem")]))
        wait(for: [expectation], timeout: 1)
    }

    func test_createTask_when_success_should_call_create_on_DAO() {
        let (sut, (taskSpy, mapper)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let inputedTask = Task(isOpen: false, name: "", subtasks: [])
        mapper.mapToDomainData = { return ( inputedTask, nil) }

        sut.createTask(inputedTask) { _ in expectation.fulfill() }

        taskSpy.createData!(.success(CKRecord(recordType: "TaskItem")))
        XCTAssertEqual(taskSpy.createCalled, 1)
        wait(for: [expectation], timeout: 1)
    }

    func test_createTask_when_success_should_call_map_on_mapper() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let expectedTask = Task(isOpen: false, name: "", subtasks: [])
        mapperSpy.mapToDomainData = { return (expectedTask, nil)}

        sut.createTask(expectedTask) { _ in expectation.fulfill() }

        taskSpy.createData!(.success(CKRecord(recordType: "TaskItem")))
        XCTAssertEqual(mapperSpy.mapToDomainCalled, 1)
        wait(for: [expectation], timeout: 1)
    }

    func test_createTask_when_success_should_return_inputed_task_correctly() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let expectedTask = Task(isOpen: false, name: "", subtasks: [])
        mapperSpy.mapToDomainData = { return (expectedTask, nil)}

        sut.createTask(expectedTask) { result in
            switch result {
                case .success(let task):
                    XCTAssertEqual(task, expectedTask)
                case .failure(let error):
                    XCTFail("function \(#function) should not raise error, but: \(error.localizedDescription)")
            }
            expectation.fulfill()
        }
        taskSpy.createData!(.success(CKRecord(recordType: "TaskItem")))
        wait(for: [expectation], timeout: 1)
    }

    func test_createTask_when_error_should_not_call_mapper() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let inputTask = Task(isOpen: false, name: "", subtasks: [])
        let inputError = CKError(CKError.Code(rawValue: 4)!)
        mapperSpy.mapToDomainData = { return (nil, inputError)}

        sut.createTask(inputTask) { _ in expectation.fulfill() }

        taskSpy.createData!(.failure(inputError))
        XCTAssertEqual(mapperSpy.mapToDomainCalled, 0)
        wait(for: [expectation], timeout: 1)
    }

    func test_createTask_when_error_should_handle_correctly() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let inputTask = Task(isOpen: false, name: "", subtasks: [])
        let inputError = CKError(CKError.Code(rawValue: 4)!)
        let expectedErrorDescription = "Não foi possível concluir a operação devido uma falha na comunicação da internet! Verifique sua conexão e tente novamente"

        mapperSpy.mapToDomainData = { return (nil, nil)}

        sut.createTask(inputTask) { result in
            switch result {
                case .success(let task):
                    XCTFail("function \(#function) should raise error, but return \(task)")
                case .failure(let error):
                    XCTAssertEqual(error.localizedDescription, expectedErrorDescription)
            }
            expectation.fulfill()
        }
        taskSpy.createData!(.failure(inputError))
        wait(for: [expectation], timeout: 1)
    }

    func test_createTask_when_mapper_raise_error_handle_correctly() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let inputTask = Task(isOpen: false, name: "", subtasks: [])
        let expectation = XCTestExpectation(description: "completionCalled")
        mapperSpy.mapToDomainData = { return (nil, RepositoryErrorStub.mockedError)}

        sut.createTask(inputTask) { result in
            switch result {
                case .success(let task):
                    XCTFail("function \(#function) should raise error, but return \(task)")
                case .failure(let error):
                    XCTAssertEqual(error.localizedDescription, "Localized description")
            }
            expectation.fulfill()
        }
        taskSpy.createData!(.success(CKRecord(recordType: "TaskItem")))
        wait(for: [expectation], timeout: 1)
    }

    func test_findTask_when_called_should_call_DAO() {
        let (sut, (taskSpy, _)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        sut.findTask(inputTask) { _ in expectation.fulfill() }
        taskSpy.findData!(nil)
        XCTAssertEqual(taskSpy.findCalled, 1)
        wait(for: [expectation], timeout: 1)
    }

    func test_findTask_when_DAO_return_record_should_call_mapper() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        let inputRecord = CKRecord(recordType: "TaskItem")
        mapperSpy.mapToDomainData = { return (inputTask, nil) }
        sut.findTask(inputTask) { _ in expectation.fulfill() }
        taskSpy.findData!(inputRecord)
        XCTAssertEqual(mapperSpy.mapToDomainCalled, 1)
        wait(for: [expectation], timeout: 1)
    }

    func test_findTask_when_DAO_return_nil_record_should_not_call_mapper() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completionCalled")
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        sut.findTask(inputTask) { _ in expectation.fulfill() }
        taskSpy.findData!(nil)
        XCTAssertEqual(mapperSpy.mapToDomainCalled, 0)
        wait(for: [expectation], timeout: 1)
    }

    func test_findTask_when_DAO_return_record_completion_should_be_called() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completion called")
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        let inputRecord = CKRecord(recordType: "TaskItem")

        mapperSpy.mapToDomainData = { return (inputTask, nil) }

        sut.findTask(inputTask) { _ in  expectation.fulfill() }
        taskSpy.findData!(inputRecord)
        wait(for: [expectation], timeout: 1)
    }

    func test_findTask_when_DAO_return_error_completion_should_be_called() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectation = XCTestExpectation(description: "completion called")
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])

        mapperSpy.mapToDomainData = { return (nil, nil) }

        sut.findTask(inputTask) { _ in  expectation.fulfill() }
        taskSpy.findData!(nil)
        wait(for: [expectation], timeout: 1)
    }

    func test_findTask_when_DAO_return_record_completion_should_return_mapped_task() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        
        let expectation = XCTestExpectation(description: "completion called")
        let inputRecord = CKRecord(recordType: "TaskItem")

        mapperSpy.mapToDomainData = { return (inputTask, nil) }

        sut.findTask(inputTask) { task in
            XCTAssertEqual(task, inputTask)
            expectation.fulfill()
        }
        taskSpy.findData!(inputRecord)
        wait(for: [expectation], timeout: 1)
    }

    func test_findTask_when_DAO_return_error_completion_should_return_nil() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let inputTask = Task(isOpen: false, name: "name", subtasks: [])
        let expectation = XCTestExpectation(description: "completion called")

        mapperSpy.mapToDomainData = { return (nil, nil) }

        sut.findTask(inputTask) { task in
            XCTAssertNil(task)
            expectation.fulfill()
        }
        taskSpy.findData!(nil)
        wait(for: [expectation], timeout: 1)
    }
}


extension TaskRepositoryTest: Testing {
    typealias SutAndDoubles = (TaskRepository<TaskMapperSpy>, (TaskDAOSpy, TaskMapperSpy))
    
    func makeSUT() -> SutAndDoubles {
        let taskDAOSpy = TaskDAOSpy()
        let taskMapperSpy = TaskMapperSpy(client: CloudKitClient(database: CloudKitDatabaseSpy()))
        
        let sut = TaskRepository(
            taskDAO: taskDAOSpy,
            errorHandler: CloudKitErrorHandler(),
            mapper: taskMapperSpy
        )
    
        weakSUT = sut
        return (sut, (taskDAOSpy, taskMapperSpy))
    }
}



