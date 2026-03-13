//
//  MoveBrowserModel.swift
//  RedBlocking
//
//  Created by Leon Li on 2026/3/11.
//  Copyright © 2026 Leon & Vane. All rights reserved.
//

import Observation

@MainActor
@Observable
final class MoveBrowserModel {
    let node: MoveNode
    let page: MoveBrowserPage
    let errorMessage: String?

    private let navigation: AppNavigationModel

    init(
        node: MoveNode,
        errorMessage: String? = nil,
        navigation: AppNavigationModel,
        browserProjector: MoveBrowserProjector = MoveBrowserProjector()
    ) {
        self.node = node
        page = browserProjector.project(node)
        self.errorMessage = errorMessage
        self.navigation = navigation
    }

    func open(_ row: MoveBrowserRow) {
        switch row.action {
        case let .openNode(node):
            navigation.pushNode(node)
        case let .openMotionPlayer(link):
            navigation.pushMotionPlayer(link)
        case .none:
            break
        }
    }
}
