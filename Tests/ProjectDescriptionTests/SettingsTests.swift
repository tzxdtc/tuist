import Foundation
import TuistSupportTesting
import XCTest

@testable import ProjectDescription

final class SettingsTests: XCTestCase {
    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()

    func test_codable_release_debug() throws {
        // Given
        let debug = Configuration(settings: ["debug": .string("debug")],
                                  xcconfig: "/path/debug.xcconfig")
        let release = Configuration(settings: ["release": .string("release")],
                                    xcconfig: "/path/release")
        let subject = Settings(base: ["base": .string("base")],
                               debug: debug,
                               release: release)

        // When
        let data = try encoder.encode(subject)

        // Then
        let decoded = try decoder.decode(Settings.self, from: data)
        XCTAssertEqual(decoded, subject)
        XCTAssertEqual(decoded.configurations.map(\.name), [
            "Debug",
            "Release",
        ])
    }

    func test_codable_multi_configs() throws {
        // Given
        let configurations: [CustomConfiguration] = [
            .debug(name: "Debug"),
            .debug(name: "CustomDebug", settings: ["CUSTOM_FLAG": .string("Debug")], xcconfig: "debug.xcconfig"),
            .release(name: "Release"),
            .release(name: "CustomRelease", settings: ["CUSTOM_FLAG": .string("Release")], xcconfig: "release.xcconfig"),
        ]
        let subject = Settings(base: ["base": .string("base")],
                               configurations: configurations)

        // When
        let data = try encoder.encode(subject)

        // Then
        let decoded = try decoder.decode(Settings.self, from: data)
        XCTAssertEqual(decoded, subject)
        XCTAssertEqual(decoded.configurations.map(\.name), [
            "Debug",
            "CustomDebug",
            "Release",
            "CustomRelease",
        ])
    }

    func test_settingsDictionary_chainingMultipleValues() {
        /// Given / When
        let settings = SettingsDictionary()
            .codeSignIdentityAppleDevelopment()
            .currentProjectVersion("999")
            .automaticCodeSigning(devTeam: "123ABC")
            .appleGenericVersioningSystem()
            .versionInfo("NLR", prefix: "A_Prefix", suffix: "A_Suffix")
            .swiftVersion("5.2.1")
            .otherSwiftFlags("first", "second", "third")
            .bitcodeEnabled(true)

        /// Then
        XCTAssertEqual(settings, [
            "CODE_SIGN_IDENTITY": "Apple Development",
            "CURRENT_PROJECT_VERSION": "999",
            "CODE_SIGN_STYLE": "Automatic",
            "DEVELOPMENT_TEAM": "123ABC",
            "VERSIONING_SYSTEM": "apple-generic",
            "VERSION_INFO_STRING": "NLR",
            "VERSION_INFO_PREFIX": "A_Prefix",
            "VERSION_INFO_SUFFIX": "A_Suffix",
            "SWIFT_VERSION": "5.2.1",
            "OTHER_SWIFT_FLAGS": "first second third",
            "ENABLE_BITCODE": "YES",
        ])
    }

    func test_settingsDictionary_codeSignManual() {
        /// Given/When
        let settings = SettingsDictionary()
            .manualCodeSigning(identity: "Apple Distribution", provisioningProfileSpecifier: "ABC")

        /// Then
        XCTAssertEqual(settings, [
            "CODE_SIGN_STYLE": "Manual",
            "CODE_SIGN_IDENTITY": "Apple Distribution",
            "PROVISIONING_PROFILE_SPECIFIER": "ABC",
        ])
    }

    func test_settingsDictionary_SwiftCompilationMode() {
        /// Given/When
        let settings1 = SettingsDictionary()
            .swiftCompilationMode(.singlefile)

        /// Then
        XCTAssertEqual(settings1, [
            "SWIFT_COMPILATION_MODE": "singlefile",
        ])

        /// Given/When
        let settings2 = SettingsDictionary()
            .swiftCompilationMode(.wholemodule)

        /// Then
        XCTAssertEqual(settings2, [
            "SWIFT_COMPILATION_MODE": "wholemodule",
        ])
    }

    func test_settingsDictionary_SwiftOptimizationLevel() {
        /// Given/When
        let settings1 = SettingsDictionary()
            .swiftOptimizationLevel(.o)

        /// Then
        XCTAssertEqual(settings1, [
            "SWIFT_OPTIMIZATION_LEVEL": "-O",
        ])

        /// Given/When
        let settings2 = SettingsDictionary()
            .swiftOptimizationLevel(.oNone)

        /// Then
        XCTAssertEqual(settings2, [
            "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
        ])

        /// Given/When
        let settings3 = SettingsDictionary()
            .swiftOptimizationLevel(.oSize)

        /// Then
        XCTAssertEqual(settings3, [
            "SWIFT_OPTIMIZATION_LEVEL": "-Osize",
        ])
    }
}
