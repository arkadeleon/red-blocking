//
//  CharacterRosterBoardView.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/12.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import SwiftUI

struct CharacterRosterBoardView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let characters: [CharacterSelection]
    let selectedCharacter: CharacterSelection?
    let containerWidth: CGFloat
    let minimumHeight: CGFloat
    let activateCharacter: (CharacterSelection) -> Void

    private let layout = CharacterRosterLayout.streetFighterIIIThirdStrike

    var body: some View {
        VStack(spacing: rowSpacing) {
            ForEach(Array(layout.rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: columnSpacing) {
                    ForEach(Array(row.characters.enumerated()), id: \.offset) { _, rosterCharacter in
                        if let rosterCharacter, let selection = selectionsByTitle[rosterCharacter.name] {
                            if selection.isLocked {
                                CharacterRosterGillSlotView(diameter: tokenDiameter)
                            } else {
                                CharacterRosterCharacterButton(
                                    character: selection,
                                    isSelected: selection.id == selectedCharacter?.id,
                                    diameter: tokenDiameter,
                                    action: {
                                        activateCharacter(selection)
                                    }
                                )
                            }
                        } else {
                            Color.clear
                                .frame(width: tokenDiameter, height: tokenDiameter)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, outerPadding)
        .padding(.vertical, verticalPadding)
        .frame(minHeight: minimumHeight, alignment: .center)
    }

    private var selectionsByTitle: [String: CharacterSelection] {
        Dictionary(uniqueKeysWithValues: characters.map { ($0.title, $0) })
    }

    private var outerPadding: CGFloat {
        horizontalSizeClass == .regular ? 22 : 18
    }

    private var columnSpacing: CGFloat {
        horizontalSizeClass == .regular ? 12 : 10
    }

    private var rowSpacing: CGFloat {
        horizontalSizeClass == .regular ? 11 : 8
    }

    private var verticalPadding: CGFloat {
        horizontalSizeClass == .regular ? 22 : 14
    }

    private var tokenDiameter: CGFloat {
        let availableWidth = max(containerWidth - (outerPadding * 2) - (columnSpacing * 2), 0)
        let idealDiameter = availableWidth / 3
        let maximumDiameter = horizontalSizeClass == .regular ? 94.0 : 108.0

        return min(max(idealDiameter, 70), maximumDiameter)
    }
}

#Preview("Roster Board") {
    let characters = PreviewAppModel.characterSelections()

    return CharacterRosterBoardView(
        characters: characters,
        selectedCharacter: characters.first(where: { $0.title == "Ken" }),
        containerWidth: 390,
        minimumHeight: 520,
        activateCharacter: { _ in }
    )
    .background(Color.rbCoal)
}
