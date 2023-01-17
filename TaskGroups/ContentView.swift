//
//  ContentView.swift
//  TaskGroups
//
//  Created by Antoine van der Lee on 12/01/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .task {
//            let names = try! await taskGroupExampleThree()
//            print("Received: \(names)")
            await taskGroupExampleThree()
        }
        .padding()
    }

    func taskGroupExampleOne() async -> [String] {
        await withTaskGroup(of: String.self, returning: [String].self) { taskGroup in
            (0..<3).forEach { index in
                taskGroup.addTask {
                    return await asyncOperation(name: "Name \(index)")
                }
            }

            var names = [String]()
            for await result in taskGroup {
                names.append(result)
            }

            return names
        }
    }

    func taskGroupExampleTwo() async -> [String] {
        await withTaskGroup(of: String.self, returning: [String].self) { taskGroup in
            (0..<3).forEach { index in
                taskGroup.addTask {
                    return await asyncOperation(name: "Name \(index)")
                }
            }

            return await taskGroup.reduce(into: [String]()) { partialResult, name in
                partialResult.append(name)
            }
        }
    }

    func taskGroupExampleThree() async {
        let names = await withTaskGroup {
            Task {
                await asyncOperation(name: "Antoine")
            }
            Task {
                await asyncOperation(name: "Maaike")
            }
            Task {
                await asyncOperation(name: "Sep")
            }
        }
        print("Received: \(names)") // Received: ["Antoine", "Maaike", "Sep"]
    }

//    func taskGroupExampleFour() async throws -> [String] {
//        withTaskGroupAutoclosure {
//            { asyncOperation(name: "Antoine") }()
//        }.value
//    }

    func asyncOperation(name: String) async -> String {
        await Task {
            print("Operation: \(name)")
            return name
        }.value
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImageDownloader {
    func download() async throws {
//        let images = try await withThrowingTaskGroup(of: UIImage.self, returning: [UIImage].self) { taskGroup in
//            let photoURLs = try await listPhotoURLs(inGallery: "Amsterdam Holiday")
//            for photoURL in photoURLs {
//                taskGroup.addTask { try await downloadPhoto(url: photoURL) }
//            }
//
//            return try await taskGroup.reduce(into: [UIImage]()) { partialResult, name in
//                partialResult.append(name)
//            }
//        }
//
//        let failingImages = try await withThrowingTaskGroup(of: UIImage.self, returning: [UIImage].self) { taskGroup in
//            let photoURLs = try await listPhotoURLs(inGallery: "Amsterdam Holiday")
//            for photoURL in photoURLs {
//                taskGroup.addTask { try await downloadPhoto(url: photoURL) }
//            }
//
//            var images = [UIImage]()
//            while let downloadImage = try await taskGroup.next() {
//                images.append(downloadImage)
//            }
//            return images
//        }

        let photoURLs = try await listPhotoURLs(inGallery: "Amsterdam Holiday")
        let images = try await withThrowingTaskGroup {
            for photoURL in photoURLs {
                Task { try await downloadPhoto(url: photoURL) }
            }
        }
    }
}

func listPhotoURLs(inGallery gallery: String) async throws -> [URL] {
    []
}
func downloadPhoto(url: URL) async throws -> UIImage {
    UIImage()
}
