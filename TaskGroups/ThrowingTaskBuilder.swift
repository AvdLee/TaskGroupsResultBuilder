//
//  ThrowingTaskBuilder.swift
//  TaskGroups
//
//  Created by Antoine van der Lee on 12/01/2023.
//

import Foundation

@resultBuilder
struct ThrowingTaskBuilder {

    static func buildExpression<Success: Sendable>(_ task: Task<Success, Error>) -> [Task<Success, Error>] {
        [task]
    }

    static func buildBlock<Success: Sendable>(_ tasks: [Task<Success, Error>]...) -> [Task<Success, Error>] {
        tasks.flatMap { $0 }
    }

    static func buildOptional<Success: Sendable>(_ tasks: [Task<Success, Error>]?) -> [Task<Success, Error>] {
        tasks ?? []
    }

    static func buildEither<Success: Sendable>(first tasks: [Task<Success, Error>]) -> [Task<Success, Error>] {
        tasks
    }

    static func buildEither<Success: Sendable>(second tasks: [Task<Success, Error>]) -> [Task<Success, Error>] {
        tasks
    }

    static func buildArray<Success: Sendable>(_ tasks: [[Task<Success, Error>]]) -> [Task<Success, Error>] {
        tasks.flatMap { $0 }
    }

    // When building the final result (a single `Task`, accumulate all of the sub-`Task`s into a
    // single `Task`.

    static func buildFinalResult<Success: Sendable>(_ tasks: [Task<Success, Error>]) -> Task<[Success], Error> {
        return Task {
            do {
                return try await withThrowingTaskGroup(of: Success.self, returning: [Success].self) { taskGroup in
                    tasks.forEach { task in
                        taskGroup.addTask {
                            try await withTaskCancellationHandler {
                                try await task.value
                            } onCancel: {
                                task.cancel()
                            }
                        }
                    }

                    return try await taskGroup.reduce(into: [Success]()) { partialResult, name in
                        partialResult.append(name)
                    }
                }
            } catch {
                throw error
            }
        }
    }
}

func withThrowingTaskGroup<Success: Sendable>(@ThrowingTaskBuilder builder: () -> Task<[Success], Error>) async throws -> [Success] {
    let task = builder()
    return try await withTaskCancellationHandler {
        try await task.value
    } onCancel: {
        task.cancel()
    }
}

//func withThrowingTaskGroup<Success: Sendable>(@TaskBuilder builder: () -> Task<[Success], Error>) -> Task<[Success], Error> {
//    return builder()
//}
