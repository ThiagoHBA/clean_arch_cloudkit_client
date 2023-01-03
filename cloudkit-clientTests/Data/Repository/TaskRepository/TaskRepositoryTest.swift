//
//  TaskRepositoryTest.swift
//  cloudkit-clientTests
//
//  Created by Thiago Henrique on 31/12/22.
//

import XCTest
@testable import cloudkit_client
import CloudKit

final class TaskRepositoryTest: XCTestCase {
    func test_fetchAllTasks_when_no_values_return_empty_list() {
        let (sut, (taskMock, subtaskMock)) = makeSUT()
        taskMock.fetchAllData = { .success([]) }
        subtaskMock.fetchSubtaskData = { .success(CKRecord(recordType: "SubtaskItem")) }
        
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
        let (sut, (taskSpy, subtaskSpy)) = makeSUT()
        taskSpy.fetchAllData = { .success([]) }
        subtaskSpy.fetchSubtaskData = { .success(CKRecord(recordType: "SubtaskItem")) }
        
        sut.fetchAllTasks { _ in }
        XCTAssertEqual(taskSpy.fetchAllCalled, 1)
        XCTAssertEqual(subtaskSpy.fetchSubtaskCalled, 0)
    }
    
    func test_fetchAllTasks_when_value_should_map_correctly() {
        let (sut, (taskSpy, subtaskSpy)) = makeSUT()
        
        let inputData = CKRecord(recordType: "TaskItem")
        
        inputData.setValuesForKeys([
            "isOpen": true,
            "name": "",
            "subtasks": []
        ])
        
        taskSpy.fetchAllData = { .success([ inputData ]) }
        subtaskSpy.fetchSubtaskData = { .success(CKRecord(recordType: "SubtaskItem")) }

        sut.fetchAllTasks { result in
            switch result {
            case .success(let tasklist):
                XCTAssertEqual(
                    tasklist.filter {
                        $0 == Task(isOpen: true, name: "", subtasks: [])
                }.count, 1)
            case .failure(let error):
                XCTFail("unexpected error raised by fetchAllTask function: \(error.localizedDescription)")
            }
        }
    }
    
    func test_fetchAllTasks_when_value_should_map_all_subtasks_correctly() {
        let (sut, (taskSpy, subtaskSpy)) = makeSUT()
        let inputData = CKRecord(recordType: "TaskItem")
        let subtaskRecord = CKRecord(recordType: "SubtaskItem")
        
        inputData.setValuesForKeys([ "isOpen": true, "name": "" ])
        subtaskRecord.setValuesForKeys([ "done": false, "name": "", "task": CKRecord.Reference(record: inputData, action: .none) ])
        inputData.setValuesForKeys([ "subtasks": [ CKRecord.Reference(record: subtaskRecord, action: .none)] ])
    
        taskSpy.fetchAllData = { .success([ inputData ]) }
        subtaskSpy.fetchSubtaskData = { .success(subtaskRecord) }
        
        let expectedTask = Task(isOpen: true, name: "", subtasks: [])
        let expectedSubtask = Subtask(done: false, name: "", task: expectedTask)
        
        sut.fetchAllTasks { result in
            switch result {
                case .success(let tasklist):
                    XCTAssertEqual(tasklist.filter {
                        $0.subtasks.contains(expectedSubtask)
                    }.count, 1)
                case .failure(let error):
                    XCTFail("unexpected error raised by fetchAllTask function: \(error.localizedDescription)")
            }
        }
    }
    
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
        let (sut, (taskSpy, subtaskSpy)) = makeSUT()
        let networkFailureCode = CKError.Code(rawValue: 4)!
        let error = CKError(networkFailureCode)
        taskSpy.fetchAllData = { .failure( error ) }
        sut.fetchAllTasks { _ in }
        
        XCTAssertEqual(subtaskSpy.fetchSubtaskCalled, 0)
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

}


extension TaskRepositoryTest: Testing {
    typealias SutAndDoubles = (TaskRepository, (TaskDAOMock, SubtaskDAOMock))
    func makeSUT() -> SutAndDoubles {
        let taskDAOSpy = TaskDAOMock()
        let subtaskDAOSpy = SubtaskDAOMock()
        
        let sut = TaskRepository(
            taskDAO: taskDAOSpy,
            subtaskDAO: subtaskDAOSpy,
            errorHandler: CloudKitErrorHandler()
        )
        
        return (sut, (taskDAOSpy, subtaskDAOSpy))
    }
}



