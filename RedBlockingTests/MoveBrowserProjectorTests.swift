//
//  MoveBrowserProjectorTests.swift
//  RedBlockingTests
//
//  Created by Leon Li on 2026/3/16.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Testing
import Foundation
@testable import RedBlocking

struct MoveBrowserProjectorTests {

    // MARK: - Helpers

    private func loadPage(yaml: String) throws -> MoveBrowserPage {
        let root = try TempResourceRoot()
        defer { root.cleanup() }
        try root.write(yaml: yaml, named: "test.yml")
        return try root.makeRepository().loadBrowserPage(resourceName: "test.yml")
    }

    /// Navigates from `page` through rows matching each name in `path` and returns the final projected page.
    private func navigate(
        from page: MoveBrowserPage,
        through rowTitles: [String]
    ) throws -> MoveBrowserPage {
        var current = page
        let projector = MoveBrowserProjector()
        for title in rowTitles {
            let row = try #require(
                current.sections.flatMap(\.rows).first(where: { $0.title == title }),
                "Row '\(title)' not found in page '\(current.navigationTitle)'"
            )
            let node = try #require(row.action.node, "Row '\(title)' has no node action")
            current = projector.project(node)
        }
        return current
    }

    // MARK: - Introduction section

    @Test("Introduction is projected as first section with supplementary body row")
    func introductionProjectsToFirstSection() throws {
        let page = try loadPage(yaml: Fixtures.profileWithOneAirEntry)
        let introSection = try #require(page.sections.first, "Expected at least one section")
        #expect(introSection.title == "【テスト】")
        #expect(introSection.rows.count == 1)
        let row = try #require(introSection.rows.first)
        #expect(row.kind == .supplementary)
        #expect(row.title == "イントロ本文")
    }

    // MARK: - Group sections

    @Test("Move groups are projected as sections following the introduction")
    func moveGroupsFollowIntroductionAsSections() throws {
        let page = try loadPage(yaml: Fixtures.profileWithOneAirEntry)
        // sections[0] = introduction, sections[1] = air_normals, sections[2..6] = remaining groups
        #expect(page.sections.count == 8) // 1 intro + 7 groups
        let airSection = page.sections[1]
        #expect(airSection.title == "【空中通常技】")
        #expect(airSection.rows.count == 1)
        #expect(airSection.rows[0].kind == .next)
        #expect(airSection.rows[0].title == "ジャンプ技")
    }

    // MARK: - Entry with children

    @Test("Entry with children projects to intermediate navigation page")
    func entryWithChildrenProjectsToNavigationPage() throws {
        let rootPage = try loadPage(yaml: Fixtures.profileWithNestedEntry)
        let childPage = try navigate(from: rootPage, through: ["親技"])
        #expect(childPage.navigationTitle == "親技")
        #expect(childPage.sections.count == 1)
        let section = try #require(childPage.sections.first)
        #expect(section.title == nil)
        #expect(section.rows.count == 1)
        #expect(section.rows[0].kind == .next)
        #expect(section.rows[0].title == "子技")
    }

    // MARK: - Entry with detail

    @Test("Entry with detail projects to detail page with primary section")
    func entryWithDetailProjectsToDetailPage() throws {
        let rootPage = try loadPage(yaml: Fixtures.profileWithDetailEntry)
        let detailPage = try navigate(from: rootPage, through: ["ジャンプ技"])
        #expect(detailPage.navigationTitle == "ジャンプ技")
        let primarySection = try #require(detailPage.sections.first)
        #expect(primarySection.title == nil)
        let rowTitles = primarySection.rows.map(\.title)
        #expect(rowTitles.contains("技名"))
        #expect(rowTitles.contains("発生"))
        #expect(rowTitles.contains("攻撃力"))
        for row in primarySection.rows {
            #expect(row.kind == .detail)
        }
    }

    // MARK: - Media section

    @Test("Entry with media projects to motionPlayer row in final section")
    func entryWithMediaProjectsToMotionPlayerRow() throws {
        let rootPage = try loadPage(yaml: Fixtures.profileWithMediaEntry)
        let detailPage = try navigate(from: rootPage, through: ["SA I"])
        let mediaSection = try #require(detailPage.sections.last)
        let mediaRow = try #require(mediaSection.rows.first)
        #expect(mediaRow.kind == .motionPlayer)
        let link = try #require(mediaRow.action.motionPlayerLink)
        #expect(link.characterCode == "TST")
        #expect(link.skillCode == "sa1")
    }

    // MARK: - Note group section title

    @Test("NoteGroup with title matching navigationTitle produces nil section title")
    func noteGroupMatchingNavigationTitleProducesNilSectionTitle() throws {
        let rootPage = try loadPage(yaml: Fixtures.profileWithMatchingNoteGroup)
        let detailPage = try navigate(from: rootPage, through: ["SA I"])
        let noteSection = try #require(
            detailPage.sections.first(where: { $0.rows.first?.kind == .supplementary })
        )
        #expect(noteSection.title == nil)
    }

    @Test("NoteGroup with title different from navigationTitle preserves section title")
    func noteGroupDifferentFromNavigationTitlePreservesSectionTitle() throws {
        let rootPage = try loadPage(yaml: Fixtures.profileWithDifferentNoteGroup)
        let detailPage = try navigate(from: rootPage, through: ["SA I"])
        let noteSection = try #require(
            detailPage.sections.first(where: { $0.rows.first?.kind == .supplementary })
        )
        #expect(noteSection.title == "EX版")
    }

    // MARK: - Entry with variants

    @Test("Entry with variants projects to page with variantNames and variantSections")
    func entryWithVariantsProjectsToVariantPage() throws {
        let rootPage = try loadPage(yaml: Fixtures.profileWithVariantEntry)
        let variantPage = try navigate(from: rootPage, through: ["ジャンプ小パンチ"])
        #expect(variantPage.navigationTitle == "ジャンプ小パンチ")
        #expect(variantPage.sections.isEmpty)
        #expect(variantPage.variantNames == ["垂直", "斜め"])
        #expect(variantPage.variantSections.count == 2)
        let firstSections = variantPage.variantSections[0]
        let primarySection = try #require(firstSections.first)
        let techNameRow = try #require(primarySection.rows.first(where: { $0.title == "技名" }))
        #expect(techNameRow.kind == .detail)
    }

    // MARK: - Stats label splitting

    @Test("Stats label with space is split into section title and row title")
    func statsLabelWithSpaceIsSplit() throws {
        let rootPage = try loadPage(yaml: Fixtures.profileWithSplitStats)
        let detailPage = try navigate(from: rootPage, through: ["技"])
        let splitSection = try #require(
            detailPage.sections.first(where: { $0.title == "通常" })
        )
        let splitRow = try #require(splitSection.rows.first)
        #expect(splitRow.title == "ヒット")
        #expect(splitRow.kind == .detail)
    }

    @Test("Stats label without space stays in primary section with original title")
    func statsLabelWithoutSpaceStaysInPrimarySection() throws {
        let rootPage = try loadPage(yaml: Fixtures.profileWithUnsplitStats)
        let detailPage = try navigate(from: rootPage, through: ["技"])
        let primarySection = try #require(detailPage.sections.first)
        #expect(primarySection.title == nil)
        let statsRow = try #require(primarySection.rows.first(where: { $0.title == "スタン" }))
        #expect(statsRow.kind == .detail)
    }
}

// MARK: - YAML Fixtures

private enum Fixtures {

    // A profile with one entry in air_normals and no detail (uses children).
    static let profileWithOneAirEntry = """
    character:
      id: test
      displayName: Test
    introduction:
      displayTitle: "【テスト】"
      body: "イントロ本文"
    moveGroups:
      - id: air_normals
        displayTitle: "【空中通常技】"
        entries:
          - id: entry_001
            displayName: "ジャンプ技"
            detail:
              displayName: "ジャンプ技"
      - id: ground_normals
        displayTitle: "【地上通常技】"
        entries: []
      - id: normal_throws
        displayTitle: "【通常投げ】"
        entries: []
      - id: lever_input_moves
        displayTitle: "【レバー入れ技】"
        entries: []
      - id: common_moves
        displayTitle: "【コマンド通常技】"
        entries: []
      - id: special_moves
        displayTitle: "【必殺技】"
        entries: []
      - id: super_arts
        displayTitle: "【スーパーアーツ】"
        entries: []
    """

    // A profile where the air entry has one child.
    static let profileWithNestedEntry = """
    character:
      id: test
      displayName: Test
    introduction:
      displayTitle: "Title"
      body: "Body"
    moveGroups:
      - id: air_normals
        displayTitle: "Air"
        entries:
          - id: entry_001
            displayName: "親技"
            children:
              - id: child_001
                displayName: "子技"
                detail:
                  displayName: "子技"
      - id: ground_normals
        displayTitle: "Ground"
        entries: []
      - id: normal_throws
        displayTitle: "Throws"
        entries: []
      - id: lever_input_moves
        displayTitle: "【レバー入れ技】"
        entries: []
      - id: common_moves
        displayTitle: "Command"
        entries: []
      - id: special_moves
        displayTitle: "Special"
        entries: []
      - id: super_arts
        displayTitle: "Super"
        entries: []
    """

    // A profile where the air entry has a detail with startup and damage.
    static let profileWithDetailEntry = """
    character:
      id: test
      displayName: Test
    introduction:
      displayTitle: "Title"
      body: "Body"
    moveGroups:
      - id: air_normals
        displayTitle: "Air"
        entries:
          - id: entry_001
            displayName: "ジャンプ技"
            detail:
              displayName: "ジャンプ技"
              startup: "5"
              damage: "100"
      - id: ground_normals
        displayTitle: "Ground"
        entries: []
      - id: normal_throws
        displayTitle: "Throws"
        entries: []
      - id: lever_input_moves
        displayTitle: "【レバー入れ技】"
        entries: []
      - id: common_moves
        displayTitle: "Command"
        entries: []
      - id: special_moves
        displayTitle: "Special"
        entries: []
      - id: super_arts
        displayTitle: "Super"
        entries: []
    """

    // A profile with a super_arts entry that has a media field.
    static let profileWithMediaEntry = """
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
      - id: common_moves
        displayTitle: "Command"
        entries: []
      - id: special_moves
        displayTitle: "Special"
        entries: []
      - id: super_arts
        displayTitle: "Super"
        entries:
          - id: sa_001
            displayName: "SA I"
            detail:
              displayName: "SA I"
              media:
                kind: motion_player
                displayLabel: "SA I"
                skillName: "SA I"
                characterCode: "TST"
                skillCode: "sa1"
    """

    // A noteGroup whose displayTitle matches the entry displayName ("SA I").
    static let profileWithMatchingNoteGroup = """
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
      - id: common_moves
        displayTitle: "Command"
        entries: []
      - id: special_moves
        displayTitle: "Special"
        entries: []
      - id: super_arts
        displayTitle: "Super"
        entries:
          - id: sa_001
            displayName: "SA I"
            detail:
              displayName: "SA I"
              noteGroups:
                - id: note_1
                  displayTitle: "SA I"
                  entries:
                    - "Note text"
    """

    // A noteGroup whose displayTitle differs from the entry displayName ("SA I" vs "EX版").
    static let profileWithDifferentNoteGroup = """
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
      - id: common_moves
        displayTitle: "Command"
        entries: []
      - id: special_moves
        displayTitle: "Special"
        entries: []
      - id: super_arts
        displayTitle: "Super"
        entries:
          - id: sa_001
            displayName: "SA I"
            detail:
              displayName: "SA I"
              noteGroups:
                - id: note_1
                  displayTitle: "EX版"
                  entries:
                    - "Note text"
    """

    // A profile where the air entry has two variants (垂直 / 斜め).
    static let profileWithVariantEntry = """
    character:
      id: test
      displayName: Test
    introduction:
      displayTitle: "Title"
      body: "Body"
    moveGroups:
      - id: air_normals
        displayTitle: "Air"
        entries:
          - id: entry_001
            displayName: "ジャンプ小パンチ"
            variants:
              - id: var_001
                displayName: "垂直"
                detail:
                  displayName: "肘落とし"
                  startup: "4"
                  damage: "60"
              - id: var_002
                displayName: "斜め"
                detail:
                  displayName: "肘落とし"
                  startup: "4"
                  damage: "50"
      - id: ground_normals
        displayTitle: "Ground"
        entries: []
      - id: normal_throws
        displayTitle: "Throws"
        entries: []
      - id: lever_input_moves
        displayTitle: "【レバー入れ技】"
        entries: []
      - id: common_moves
        displayTitle: "Command"
        entries: []
      - id: special_moves
        displayTitle: "Special"
        entries: []
      - id: super_arts
        displayTitle: "Super"
        entries: []
    """

    // Stats entry with a space-separated label "通常 ヒット".
    static let profileWithSplitStats = """
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
      - id: common_moves
        displayTitle: "Command"
        entries: []
      - id: special_moves
        displayTitle: "Special"
        entries: []
      - id: super_arts
        displayTitle: "Super"
        entries:
          - id: entry_001
            displayName: "技"
            detail:
              displayName: "技"
              stats:
                "通常 ヒット": "+3"
    """

    // Stats entry with a label without a space — should not be split.
    static let profileWithUnsplitStats = """
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
      - id: common_moves
        displayTitle: "Command"
        entries: []
      - id: special_moves
        displayTitle: "Special"
        entries: []
      - id: super_arts
        displayTitle: "Super"
        entries:
          - id: entry_001
            displayName: "技"
            detail:
              displayName: "技"
              stats:
                スタン: "200"
    """
}
