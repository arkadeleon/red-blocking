//
//  MoveBrowserProjector.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/13.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Foundation

struct MoveBrowserProjector {
    func project(_ node: MoveNode) -> MoveBrowserPage {
        switch node {
        case let .profile(profile):
            return project(profile: profile)
        case let .entry(entry):
            return projectPage(for: entry)
        }
    }

    func project(profile: CharacterProfile) -> MoveBrowserPage {
        MoveBrowserPage(
            id: "profile:\(profile.id)",
            navigationTitle: profile.displayName,
            sections: [projectIntroduction(profile.introduction, profileID: profile.id)]
                + profile.moveGroups.map(projectGroup)
        )
    }

    private func projectIntroduction(
        _ introduction: CharacterIntroduction,
        profileID: String
    ) -> MoveBrowserSection {
        MoveBrowserSection(
            id: "profile:\(profileID):introduction",
            title: introduction.displayTitle,
            rows: [
                .supplementary(
                    id: "profile:\(profileID):introduction:body",
                    title: introduction.body
                )
            ]
        )
    }

    private func projectGroup(_ group: MoveGroup) -> MoveBrowserSection {
        MoveBrowserSection(
            id: "group:\(group.id.rawValue)",
            title: group.displayTitle,
            rows: group.entries.map(projectEntryRow)
        )
    }

    private func projectEntryRow(_ entry: MoveEntry) -> MoveBrowserRow {
        .next(
            id: entry.id,
            title: entry.displayName,
            node: .entry(entry)
        )
    }

    private func projectPage(for entry: MoveEntry) -> MoveBrowserPage {
        let pageID = "page:\(entry.id)"

        if let children = entry.children {
            return MoveBrowserPage(
                id: pageID,
                navigationTitle: entry.displayName,
                sections: [
                    MoveBrowserSection(
                        id: "\(pageID):children",
                        title: nil,
                        rows: children.map(projectEntryRow)
                    )
                ]
            )
        }

        if let variants = entry.variants {
            var variantNames = variants.map(\.displayName)
            var variantSections: [[MoveBrowserSection]] = variants.map { variant in
                projectSections(
                    for: variant.detail,
                    pageID: "\(pageID):variant:\(variant.id)",
                    navigationTitle: entry.displayName
                )
            }

            if let noteGroups = entry.noteGroups, !noteGroups.isEmpty {
                variantNames.append("補足")
                variantSections.append(
                    noteGroups.map { noteGroup in
                        projectNoteGroupSection(
                            noteGroup,
                            pageID: "\(pageID):note_groups",
                            navigationTitle: entry.displayName
                        )
                    }
                )
            }

            return MoveBrowserPage(
                id: pageID,
                navigationTitle: entry.displayName,
                sections: [],
                variantNames: variantNames,
                variantSections: variantSections
            )
        }

        guard let detail = entry.detail else {
            preconditionFailure("MoveEntry \(entry.id) must contain either children, variants, or detail.")
        }

        return MoveBrowserPage(
            id: pageID,
            navigationTitle: entry.displayName,
            sections: projectSections(
                for: detail,
                pageID: pageID,
                navigationTitle: entry.displayName
            )
        )
    }

    private func projectSections(
        for detail: MoveDetail,
        pageID: String,
        navigationTitle: String
    ) -> [MoveBrowserSection] {
        var sections: [MoveBrowserSection] = []
        var primaryRows = projectPrimaryRows(detail, pageID: pageID)
        let mediaSection = detail.mediaEntries.isEmpty ? nil : projectMediaSection(detail.mediaEntries, pageID: pageID)

        if let meterGain = detail.meterGain {
            let values = meterGain.asLabeledValues
            if !values.isEmpty {
                sections.append(
                    projectLabeledValueSection(
                        title: "ゲージ増加量",
                        values: values,
                        pageID: pageID,
                        sectionID: "meter_gain"
                    )
                )
            }
        }

        if let frameAdvantage = detail.frameAdvantage {
            let values = frameAdvantage.asLabeledValues
            if !values.isEmpty {
                sections.append(
                    projectLabeledValueSection(
                        title: "ヒット&ガード硬直時間差",
                        values: values,
                        pageID: pageID,
                        sectionID: "frame_advantage"
                    )
                )
            }
        }

        let statSections = detail.stats.map { projectStatSections($0, pageID: pageID) } ?? []
        if let firstStatSection = statSections.first, firstStatSection.title == nil {
            primaryRows.append(contentsOf: firstStatSection.rows)
            sections.append(contentsOf: statSections.dropFirst())
        } else {
            sections.append(contentsOf: statSections)
        }

        if !primaryRows.isEmpty {
            sections.insert(
                MoveBrowserSection(
                    id: "\(pageID):primary",
                    title: nil,
                    rows: primaryRows
                ),
                at: 0
            )
        }

        if let mediaSection {
            let insertionIndex = min(1, sections.count)
            sections.insert(mediaSection, at: insertionIndex)
        }

        sections.append(
            contentsOf: detail.noteGroups.map { noteGroup in
                projectNoteGroupSection(
                    noteGroup,
                    pageID: pageID,
                    navigationTitle: navigationTitle
                )
            }
        )

        return sections
    }

    private func projectPrimaryRows(_ detail: MoveDetail, pageID: String) -> [MoveBrowserRow] {
        var rows = [
            MoveBrowserRow.detail(
                id: "\(pageID):field:display_name",
                title: "技名",
                value: detail.displayName
            )
        ]

        let optionalFields: [(id: String, title: String, value: String?)] = [
            ("command", "コマンド", detail.command),
            ("super_cancel", "SC", detail.superCancel),
            ("guard", "ガード", detail.guard),
            ("blocking", "BL", detail.blocking),
            ("startup", "発生", detail.startup),
            ("active", "持続", detail.active),
            ("recovery", "硬直", detail.recovery),
            ("damage", "攻撃力", detail.damage),
            ("chip_damage", "ケズリ", detail.chipDamage),
            ("stun", "スタン値", detail.stun),
            ("stun_reduction", "削減値", detail.stunReduction)
        ]

        rows.append(
            contentsOf: optionalFields.compactMap { field in
                guard let value = field.value else {
                    return nil
                }

                return .detail(
                    id: "\(pageID):field:\(field.id)",
                    title: field.title,
                    value: value
                )
            }
        )

        return rows
    }

    private func projectLabeledValueSection(
        title: String,
        values: [MoveLabeledValue],
        pageID: String,
        sectionID: String
    ) -> MoveBrowserSection {
        MoveBrowserSection(
            id: "\(pageID):\(sectionID)",
            title: title,
            rows: values.map { labeledValue in
                .detail(
                    id: "\(pageID):\(sectionID):\(labeledValue.id)",
                    title: labeledValue.label,
                    value: labeledValue.value
                )
            }
        )
    }

    private func projectStatSections(
        _ stats: LabeledValueMap,
        pageID: String
    ) -> [MoveBrowserSection] {
        var fragments: [StatSectionFragment] = []

        for (label, value) in stats.pairs {
            let rowID = "\(pageID):stats:\(label)"
            let row: MoveBrowserRow
            let title: String?

            if let splitLabel = splitStatLabel(label) {
                row = .detail(
                    id: rowID,
                    title: splitLabel.rowTitle,
                    value: value
                )
                title = splitLabel.sectionTitle
            } else {
                row = .detail(
                    id: rowID,
                    title: label,
                    value: value
                )
                title = nil
            }

            if let lastIndex = fragments.indices.last, fragments[lastIndex].title == title {
                fragments[lastIndex].rows.append(row)
            } else {
                fragments.append(
                    StatSectionFragment(
                        title: title,
                        rows: [row]
                    )
                )
            }
        }

        return fragments.enumerated().map { index, fragment in
            MoveBrowserSection(
                id: "\(pageID):stats_section:\(index)",
                title: fragment.title,
                rows: fragment.rows
            )
        }
    }

    private func projectNoteGroupSection(
        _ noteGroup: MoveNoteGroup,
        pageID: String,
        navigationTitle: String
    ) -> MoveBrowserSection {
        let sectionTitle = noteGroup.displayTitle == navigationTitle ? nil : noteGroup.displayTitle

        return MoveBrowserSection(
            id: "\(pageID):note_group:\(noteGroup.id)",
            title: sectionTitle,
            rows: noteGroup.entries.enumerated().map { index, entry in
                .supplementary(
                    id: "\(pageID):note_group:\(noteGroup.id):\(index)",
                    title: entry
                )
            }
        )
    }

    private func projectMediaSection(_ mediaEntries: [MoveMedia], pageID: String) -> MoveBrowserSection {
        MoveBrowserSection(
            id: "\(pageID):media",
            title: "Motion Preview",
            rows: mediaEntries.enumerated().map { index, media in
                .motionPlayer(
                    id: "\(pageID):media:\(index):\(media.kind.rawValue)",
                    title: media.displayLabel,
                    subtitle: media.displayLabel == media.skillName ? nil : media.skillName,
                    characterCode: media.characterCode,
                    skillCode: media.skillCode
                )
            }
        )
    }

    private func splitStatLabel(_ label: String) -> (sectionTitle: String, rowTitle: String)? {
        guard let separator = label.lastIndex(of: " ") else {
            return nil
        }

        let sectionTitle = String(label[..<separator]).trimmingCharacters(in: .whitespacesAndNewlines)
        let rowTitle = String(label[label.index(after: separator)...]).trimmingCharacters(in: .whitespacesAndNewlines)

        guard sectionTitle.isEmpty == false, rowTitle.isEmpty == false else {
            return nil
        }

        return (sectionTitle, rowTitle)
    }
}

private extension MoveBrowserProjector {
    struct StatSectionFragment {
        let title: String?
        var rows: [MoveBrowserRow]
    }
}

private extension MeterGain {
    var asLabeledValues: [MoveLabeledValue] {
        var result: [MoveLabeledValue] = []
        if let v = whiff        { result.append(.init(id: "whiff",        label: "空振り",    value: v)) }
        if let v = `guard`      { result.append(.init(id: "guard",        label: "ガード",    value: v)) }
        if let v = hit          { result.append(.init(id: "hit",          label: "ヒット",    value: v)) }
        if let v = bl           { result.append(.init(id: "bl",           label: "BL",        value: v)) }
        if let v = throwSuccess { result.append(.init(id: "throwSuccess", label: "投げ成功時", value: v)) }
        if let v = onWhiff      { result.append(.init(id: "onWhiff",      label: "空振り時",  value: v)) }
        return result
    }
}

private extension FrameAdvantage {
    var asLabeledValues: [MoveLabeledValue] {
        var result: [MoveLabeledValue] = []
        if let v = `guard`      { result.append(.init(id: "guard",        label: "ガード",  value: v)) }
        if let v = hit          { result.append(.init(id: "hit",          label: "ヒット",  value: v)) }
        if let v = standingHit  { result.append(.init(id: "standingHit",  label: "立ヒット", value: v)) }
        if let v = crouchingHit { result.append(.init(id: "crouchingHit", label: "屈ヒット", value: v)) }
        return result
    }
}
