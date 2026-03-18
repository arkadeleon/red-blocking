//
//  MoveEntryValidationTests.swift
//  RedBlockingTests
//
//  Created by Leon Li on 2026/3/16.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Testing
import Foundation
@testable import RedBlocking

struct MoveEntryValidationTests {

    // MARK: - MoveEntry structural constraints

    @Test("MoveEntry with both children and detail fails decoding")
    func entryWithBothChildrenAndDetailFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.entryWithBothChildrenAndDetail)
    }

    @Test("MoveEntry with neither children nor detail fails decoding")
    func entryWithNeitherChildrenNorDetailFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.entryWithNeitherChildrenNorDetail)
    }

    @Test("MoveEntry with empty children array fails decoding")
    func entryWithEmptyChildrenFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.entryWithEmptyChildren)
    }

    @Test("MoveEntry with both variants and detail fails decoding")
    func entryWithBothVariantsAndDetailFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.entryWithBothVariantsAndDetail)
    }

    @Test("MoveEntry with both variants and children fails decoding")
    func entryWithBothVariantsAndChildrenFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.entryWithBothVariantsAndChildren)
    }

    @Test("MoveEntry with empty variants array fails decoding")
    func entryWithEmptyVariantsFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.entryWithEmptyVariants)
    }

    @Test("MoveEntry with variants decodes correctly")
    func entryWithVariantsDecodesCorrectly() throws {
        let root = try TempResourceRoot()
        defer { root.cleanup() }
        try root.write(yaml: ValidYAML.entryWithVariants, named: "valid.yml")
        let profile = try root.makeRepository().loadProfile(resourceName: "valid.yml")
        // validProfile puts entries in super_arts (the last group)
        let entry = try #require(profile.moveGroups.last?.entries.first)
        let variants = try #require(entry.variants)
        #expect(variants.count == 2)
        #expect(variants[0].displayName == "垂直")
        #expect(variants[1].displayName == "斜め")
    }

    // MARK: - MoveDetail constraints

    @Test("MoveDetail with empty displayName fails decoding")
    func detailWithEmptyDisplayNameFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.detailWithEmptyDisplayName)
    }

    @Test("MoveDetail with whitespace-only displayName fails decoding")
    func detailWithWhitespaceDisplayNameFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.detailWithWhitespaceDisplayName)
    }

    // MARK: - CharacterProfile group constraints

    @Test("CharacterProfile with move groups in wrong order fails decoding")
    func profileWithWrongGroupOrderFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.profileWithWrongGroupOrder)
    }

    @Test("CharacterProfile with missing move groups fails decoding")
    func profileWithMissingGroupFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.profileWithMissingGroups)
    }

    // MARK: - CharacterIntroduction constraints

    @Test("CharacterIntroduction with empty body fails decoding")
    func introductionWithEmptyBodyFails() throws {
        try assertDecodingFails(yaml: InvalidYAML.introductionWithEmptyBody)
    }

    // MARK: - Helper

    private func assertDecodingFails(yaml: String, sourceLocation: SourceLocation = #_sourceLocation) throws {
        let root = try TempResourceRoot()
        defer { root.cleanup() }
        try root.write(yaml: yaml, named: "invalid.yml")

        do {
            _ = try root.makeRepository().loadProfile(resourceName: "invalid.yml")
            Issue.record("Expected MoveRepositoryError to be thrown", sourceLocation: sourceLocation)
        } catch is MoveRepositoryError {
            // Expected: the repository wraps all decode failures in MoveRepositoryError.
        } catch {
            Issue.record("Wrong error type thrown: \(error)", sourceLocation: sourceLocation)
        }
    }
}

// MARK: - Invalid YAML fixtures

private enum InvalidYAML {

    // Entry declares both `children` and `detail` — MoveEntry.init rejects this.
    static let entryWithBothChildrenAndDetail = validProfile(withSuperArtsEntries: """
          - id: item_bad
            displayName: "Conflict"
            children:
              - id: child_001
                displayName: "Child"
                detail:
                  displayName: "Child"
            detail:
              displayName: "Conflict"
    """)

    // Entry declares both `variants` and `detail` — MoveEntry.init rejects this.
    static let entryWithBothVariantsAndDetail = validProfile(withSuperArtsEntries: """
          - id: item_bad
            displayName: "Conflict"
            variants:
              - id: var_001
                displayName: "Var"
                detail:
                  displayName: "Var"
            detail:
              displayName: "Conflict"
    """)

    // Entry declares both `variants` and `children` — MoveEntry.init rejects this.
    static let entryWithBothVariantsAndChildren = validProfile(withSuperArtsEntries: """
          - id: item_bad
            displayName: "Conflict"
            variants:
              - id: var_001
                displayName: "Var"
                detail:
                  displayName: "Var"
            children:
              - id: child_001
                displayName: "Child"
                detail:
                  displayName: "Child"
    """)

    // Entry declares `variants: []` — MoveEntry.init rejects an empty variants array.
    static let entryWithEmptyVariants = validProfile(withSuperArtsEntries: """
          - id: item_bad
            displayName: "Empty variants"
            variants: []
    """)

    // Entry declares neither `children` nor `detail` — MoveEntry.init rejects this.
    static let entryWithNeitherChildrenNorDetail = validProfile(withSuperArtsEntries: """
          - id: item_bad
            displayName: "Empty"
    """)

    // Entry declares `children: []` — MoveEntry.init rejects an empty children array.
    static let entryWithEmptyChildren = validProfile(withSuperArtsEntries: """
          - id: item_bad
            displayName: "Empty children"
            children: []
    """)

    // Detail has an empty displayName string.
    static let detailWithEmptyDisplayName = validProfile(withSuperArtsEntries: """
          - id: item_bad
            displayName: "Bad detail"
            detail:
              displayName: ""
    """)

    // Detail has a whitespace-only displayName string.
    static let detailWithWhitespaceDisplayName = validProfile(withSuperArtsEntries: """
          - id: item_bad
            displayName: "Bad detail"
            detail:
              displayName: "   "
    """)

    // Groups present but in wrong order (ground before air).
    static let profileWithWrongGroupOrder = """
    character:
      id: test
      displayName: Test
    introduction:
      displayTitle: "Title"
      body: "Body"
    moveGroups:
      - id: ground_normals
        displayTitle: "Ground"
        entries: []
      - id: air_normals
        displayTitle: "Air"
        entries: []
      - id: normal_throws
        displayTitle: "Throws"
        entries: []
      - id: lever_input_moves
        displayTitle: "【レバー入れ技】"
        entries: []
      - id: command_normals
        displayTitle: "Command"
        entries: []
      - id: special_moves
        displayTitle: "Special"
        entries: []
      - id: super_arts
        displayTitle: "Super"
        entries: []
    """

    // Only one group present instead of five.
    static let profileWithMissingGroups = """
    character:
      id: test
      displayName: Test
    introduction:
      displayTitle: "Title"
      body: "Body"
    moveGroups:
      - id: air_normals
        displayTitle: "Air"
        entries: []
    """

    // Introduction body is an empty string.
    static let introductionWithEmptyBody = """
    character:
      id: test
      displayName: Test
    introduction:
      displayTitle: "Title"
      body: ""
    moveGroups:
      - id: air_normals
        displayTitle: "Air"
        entries: []
      - id: ground_normals
        displayTitle: "Ground"
        entries: []
      - id: normal_throws
        displayTitle: "Throws"
        entries: []
      - id: lever_input_moves
        displayTitle: "【レバー入れ技】"
        entries: []
      - id: command_normals
        displayTitle: "Command"
        entries: []
      - id: special_moves
        displayTitle: "Special"
        entries: []
      - id: super_arts
        displayTitle: "Super"
        entries: []
    """

    // MARK: - Helper

    /// Returns a complete valid profile YAML with the given entries block inserted into super_arts.
    /// `entries` must be a pre-indented YAML fragment (6 spaces for the list items).
    static func validProfile(withSuperArtsEntries entries: String) -> String {
        """
        character:
          id: test
          displayName: Test
        introduction:
          displayTitle: "Title"
          body: "Body"
        moveGroups:
          - id: air_normals
            displayTitle: "Air"
            entries: []
          - id: ground_normals
            displayTitle: "Ground"
            entries: []
          - id: normal_throws
            displayTitle: "Throws"
            entries: []
          - id: lever_input_moves
            displayTitle: "【レバー入れ技】"
            entries: []
          - id: command_normals
            displayTitle: "Command"
            entries: []
          - id: special_moves
            displayTitle: "Special"
            entries: []
          - id: super_arts
            displayTitle: "Super"
            entries:
        \(entries)
        """
    }
}

// MARK: - Valid YAML fixtures

private enum ValidYAML {

    // Entry with two variants — should decode successfully.
    static let entryWithVariants = InvalidYAML.validProfile(withSuperArtsEntries: """
          - id: item_ok
            displayName: "ジャンプ小パンチ"
            variants:
              - id: var_001
                displayName: "垂直"
                detail:
                  displayName: "肘落とし"
              - id: var_002
                displayName: "斜め"
                detail:
                  displayName: "肘落とし"
    """)
}
