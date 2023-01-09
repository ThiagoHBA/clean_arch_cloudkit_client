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
        let (sut, (taskMock, mapper)) = makeSUT()
        taskMock.fetchAllData = { .success([]) }
        mapper.mapToDomainData = { return (nil, nil) }


        sut.fetchAllTasks { result in
            switch result {
                case .success(let taskList):
                    XCTAssertEqual([], taskList)
                case .failure(_):
                    XCTFail("List should be initialized with zero values")
            }
        }
    }

    func test_fetchAllTasks_when_no_values_fetch_called_only_once() {
        let (sut, (taskSpy, mapper)) = makeSUT()
        taskSpy.fetchAllData = { .success([]) }
        mapper.mapToDomainData = { return (nil, nil) }

        sut.fetchAllTasks { _ in }
        XCTAssertEqual(taskSpy.fetchAllCalled, 1)
        XCTAssertEqual(mapper.mapToDomainCalled, 0)
    }

//    func test_fetchAllTasks_when_value_should_map_correctly() {
//        let (sut, (taskSpy, mapper)) = makeSUT()
//
//        let inputData = CKRecord(recordType: "TaskItem")
//
//        inputData.setValuesForKeys([ "isOpen": true, "name": "", "subtasks": [] ])
//
//        taskSpy.fetchAllData = { .success([ inputData ]) }
//        mapper.mapToDomainData = {}
//
//        sut.fetchAllTasks { result in
//            switch result {
//            case .success(let tasklist):
//                XCTAssertEqual(
//                    tasklist.filter {
//                        $0 == Task(isOpen: true, name: "", subtasks: [])
//                }.count, 1)
//            case .failure(let error):
//                XCTFail("unexpected error raised by fetchAllTask function: \(error.localizedDescription)")
//            }
//        }
//    }

//    func test_fetchAllTasks_when_value_should_map_all_subtasks_correctly() {
//        let (sut, (taskSpy, subtaskSpy)) = makeSUT()
//        let inputData = CKRecord(recordType: "TaskItem")
//        let subtaskRecord = CKRecord(recordType: "SubtaskItem")
//
//        inputData.setValuesForKeys([ "isOpen": true, "name": "" ])
//        subtaskRecord.setValuesForKeys([ "done": false, "name": "", "task": CKRecord.Reference(record: inputData, action: .none) ])
//        inputData.setValuesForKeys([ "subtasks": [ CKRecord.Reference(record: subtaskRecord, action: .none)] ])
//
//        taskSpy.fetchAllData = { .success([ inputData ]) }
//        subtaskSpy.fetchSubtaskData = { .success(subtaskRecord) }
//
//        let expectedTask = Task(isOpen: true, name: "", subtasks: [])
//        let expectedSubtask = Subtask(done: false, name: "", task: expectedTask)
//
//        sut.fetchAllTasks { result in
//            switch result {
//                case .success(let tasklist):
//                    XCTAssertEqual(tasklist.filter {
//                        $0.subtasks.contains(expectedSubtask)
//                    }.count, 1)
//                case .failure(let error):
//                    XCTFail("unexpected error raised by fetchAllTask function: \(error.localizedDescription)")
//            }
//        }
//    }
//
    func test_fetchAllTasks_when_error_should_handle_correctly() {
        let (sut, (taskSpy, _)) = makeSUT()
        let networkFailureCode = CKError.Code(rawValue: 4)!
        let networkFailureDescription = "Não foi possível concluir a operação devido uma falha na comunicação da internet! Verifique sua conexão e tente novamente"
        let error = CKError(networkFailureCode)

        taskSpy.fetchAllData = { .failure( error ) }

        sut.fetchAllTasks { result in
            switch result {
            case .success(_):
                XCTFail("fetchAllTasks complete operation successfully while should fail")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription,  networkFailureDescription)
            }
        }
    }

    func test_fetchAllTasks_when_error_should_no_call_fetch_subtasks() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let networkFailureCode = CKError.Code(rawValue: 4)!
        let error = CKError(networkFailureCode)
        taskSpy.fetchAllData = { .failure( error ) }
        
        sut.fetchAllTasks { _ in }

        XCTAssertEqual(mapperSpy.mapToDomainCalled, 0)
    }

    func test_fetchAllTasks_when_fail_should_map_correctly_unkwown_errors() {
        let (sut, (taskSpy, _)) = makeSUT()
        let unknownErrorFailureCode = CKError.Code(rawValue: 0)! //
        let unknownErrorExpectedDescription = "Erro não mapeado! Verifique se existe alguma atualização do aplicativo disponível e tente novamente."
        let error = CKError(unknownErrorFailureCode)

        taskSpy.fetchAllData = { .failure( error ) }

        sut.fetchAllTasks { result in
            switch result {
            case .success(_):
                XCTFail("fetchAllTasks complete operation successfully while should fail")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription,  unknownErrorExpectedDescription)
            }
        }
    }
    
    func test_fetchAllTasks_when_mapper_return_task_should_append_on_list() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectedTask = Task(isOpen: false, name: "", subtasks: [])
        taskSpy.fetchAllData = {
            .success([CKRecord.init(recordType: "TaskItem")])
        }
        mapperSpy.mapToDomainData = { (expectedTask, nil) }
        
        sut.fetchAllTasks { result in
            switch result {
                case .success(let recordList):
                    XCTAssertNotNil(recordList.first)
                    XCTAssertEqual(recordList.first!, Task(isOpen: false, name: "", subtasks: []))
                case .failure(let error):
                    XCTFail("Operation should not return error: \(error)")
            }
        }
    }
    
    func test_fetchAllTasks_when_mapper_return_error_should_not_append_on_list() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        
        taskSpy.fetchAllData = {
            .success([CKRecord.init(recordType: "TaskItem")])
        }
        mapperSpy.mapToDomainData = { (nil, DomainEntityMapperError(domainEntityErrorDescription: "")) }
        
        sut.fetchAllTasks { result in
            switch result {
                case .success(let recordList):
                    XCTAssertEqual(recordList, [])
                case .failure(let error):
                    XCTFail("Operation should not return error: \(error)")
            }
        }
    }
    
    func test_fetchAllTasks_when_mapper_return_task_and_error_should_not_append_on_list() {
        let (sut, (taskSpy, mapperSpy)) = makeSUT()
        let expectedTask = Task(isOpen: false, name: "", subtasks: [])
        
        taskSpy.fetchAllData = {
            .success([CKRecord.init(recordType: "TaskItem")])
        }
        mapperSpy.mapToDomainData = { (expectedTask, DomainEntityMapperError(domainEntityErrorDescription: "")) }
        
        sut.fetchAllTasks { result in
            switch result {
                case .success(let recordList):
                    XCTAssertEqual(recordList, [])
                case .failure(let error):
                    XCTFail("Operation should not return error: \(error)")
            }
        }
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



