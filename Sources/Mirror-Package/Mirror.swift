import ArgumentParser
import Foundation
import SystemPackage

@main
struct Mirror: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Utility for creating a local mirror of a Swift project's package dependencies.",
        version: "1.0.0"
    )

    @Option(name: [.long, .short], help: "Directory which will hold the local mirrors")
    var mirrorPath: String

    @Option(name: [.long, .short], help: "Path to the git executable")
    var gitPath: String = "/usr/bin/git"

    @Option(name: [.long, .short], help: "Path to the swift executable")
    var swiftPath: String = "/usr/bin/swift"

    @Flag(name: [.long, .short], help: "Update all local mirrors in the mirror directory")
    var update: Bool = false

    func run() throws {
        if update {
            try updateMirrors()
        } else {
            try configureMirrorsForProject()
        }
    }

    func updateMirrors() throws {
        let currentDir = FileManager.default.currentDirectoryPath
        for fileName in try FileManager.default.contentsOfDirectory(atPath: mirrorPath) {
            var subDir = FilePath(mirrorPath)
            subDir.append(fileName)
            FileManager.default.changeCurrentDirectoryPath(subDir.string)
            do {
                let task = Process()
                task.executableURL = URL(fileURLWithPath: gitPath)
                task.arguments = ["pull", "--rebase"]
                try task.run()
                task.waitUntilExit()
            } catch {
                print("Error updating mirror \(fileName)")
            }
        }
        // restore current directory
        FileManager.default.changeCurrentDirectoryPath(currentDir)
    }

    func configureMirrorsForProject() throws {
        // look for Package.resolved in the current directory
        var path = FilePath(FileManager.default.currentDirectoryPath)
        path.append("Package.resolved")
        let package = try String(contentsOfFile: path.string)
        var dependencyURLs = [String]()
        for line in readLines(package) {
            if line.contains("repositoryURL") {
                print("Found a dependency: \(line)")
                do {
                    let source = try extractURL(line)
                    if !source.isEmpty {
                        dependencyURLs.append(source)
                    }
                } catch {
                    print("Error extracting repo URL: \(error.localizedDescription)")
                }
            }
        }
        // Now, we want to go to the mirror root and do a git clone of each dependency
        // unless, of course, it's already been cloned.
        let projectDir = FileManager.default.currentDirectoryPath
        FileManager.default.changeCurrentDirectoryPath(mirrorPath)
        var mirrors: [String: String] = [:]
        for dependencyURL in dependencyURLs {
            do {
                var directory = FilePath(mirrorPath)
                let subDir = try clone(source: dependencyURL)
                directory.append(subDir)
                mirrors[dependencyURL] = directory.string
            } catch {
                print("Error cloning dependency '\(dependencyURL)': \(error.localizedDescription)")
                throw ExitCode.failure
            }
        }

        // Finally, now that we've got all the dependencies cloned into our mirror directory,
        // we need to go back to the project directory and tell SPM that we're mirroring.
        FileManager.default.changeCurrentDirectoryPath(projectDir)
        for dependencyURL in dependencyURLs {
            if let mirror = mirrors[dependencyURL] {
                do {
                    try registerMirror(source: dependencyURL, mirror: mirror)
                } catch {
                    print("Error registering mirror for \(dependencyURL)")
                }
            }
        }
    }

    func readLines(_ input: String) -> [String] {
        var lines = [String]()
        for line in input.split(separator: "\n").filter({!$0.isEmpty}) {
            lines.append("\(line)")
        }
        return lines
    }

    func extractURL(_ from: String) throws -> String {
        let range = NSRange(
            from.startIndex..<from.endIndex,
            in: from
        )
        let sourcePattern = #".*"repositoryURL": "(.*)",.*"#
        let regex = try NSRegularExpression(
            pattern: sourcePattern,
            options: []
        )
        let matches = regex.matches(in: from,
                                    options: [],
                                    range: range)
        guard let match = matches.first else {
            print("No matching URL found")
            return ""
        }

        for rangeIndex in 0..<match.numberOfRanges {
            let matchRange = match.range(at: rangeIndex)
            // Ignore if we are matching the entire line
            if matchRange == range { continue }
            // Extract the substring matching the capture group
            if let substringRange = Range(matchRange, in: from) {
                let capture = String(from[substringRange])
                return capture
            }
        }
        // if we're here, we haven't found a URL
        return ""
    }

    func registerMirror(source: String, mirror: String) throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: swiftPath)
        task.arguments = ["package", "config", "set-mirror",
                          "--original-url", source,
                          "--mirror-url", mirror]
        try task.run()
        task.waitUntilExit()
    }

    func clone(source: String) throws -> String {
        guard let subDir = source.split(separator: "/").last else {
            print("weird source repo URL: \(source)")
            return ""
        }
        var returnSubDir = String(subDir)
        if subDir.hasSuffix(".git") {
            returnSubDir = String(subDir.dropLast(4))
        }

        // If the subdirectory doesn't exist already, then we clone the dependency
        var directory = FilePath(FileManager.default.currentDirectoryPath)
        directory.append(returnSubDir)
        if FileManager.default.fileExists(atPath: directory.string) {
            print("Already mirroring \(source)")
            return returnSubDir
        }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: gitPath)
        task.arguments = ["clone", source]
        try task.run()
        task.waitUntilExit()

        return returnSubDir
    }
}
