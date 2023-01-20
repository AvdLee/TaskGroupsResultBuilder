//
//  TaskResultBuilder.swift
//  TaskGroups
//
//  Created by Antoine van der Lee on 12/01/2023.
//

import Foundation

@resultBuilder
struct TaskBuilder {

    static func buildExpression<Success: Sendable>(_ task: Task<Success, Never>) -> [Task<Success, Never>] {
        [task]
    }

    static func buildBlock<Success: Sendable>(_ tasks: [Task<Success, Never>]...) -> [Task<Success, Never>] {
        tasks.flatMap { $0 }
    }

//    static func buildOptional<Success: Sendable, Failure: Error>(_ tasks: [Task<Success, Failure>]?) -> [Task<Success, Failure>] {
//        tasks ?? []
//    }
//
//    static func buildEither<Success: Sendable, Failure: Error>(first tasks: [Task<Success, Failure>]) -> [Task<Success, Failure>] {
//        tasks
//    }
//
//    static func buildEither<Success: Sendable, Failure: Error>(second tasks: [Task<Success, Failure>]) -> [Task<Success, Failure>] {
//        tasks
//    }
//
//    static func buildArray<Success: Sendable, Failure: Error>(_ tasks: [[Task<Success, Failure>]]) -> [Task<Success, Failure>] {
//        tasks.flatMap { $0 }
//    }

    // When building the final result (a single `Task`, accumulate all of the sub-`Task`s into a
    // single `Task`.

    static func buildFinalResult<Success: Sendable>(_ tasks: [Task<Success, Never>]) -> Task<[Success], Never> {
        Task {
            await withTaskGroup(of: Success.self, returning: [Success].self) { taskGroup in
                tasks.forEach { task in
                    taskGroup.addTask {
                        await withTaskCancellationHandler {
                            await task.value
                        } onCancel: {
                            task.cancel()
                        }
                    }
                }

                return await taskGroup.reduce(into: [Success]()) { partialResult, name in
                    partialResult.append(name)
                }
            }
        }
    }
}

func withTaskGroup<Success: Sendable>(@TaskBuilder builder: () -> Task<[Success], Never>) async -> [Success] {
    let task = builder()
    return await withTaskCancellationHandler {
        await task.value
    } onCancel: {
        task.cancel()
    }
}
