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
    let page: MoveBrowserPage
    let errorMessage: String?

    private let navigation: AppNavigationModel

    init(
        page: MoveBrowserPage,
        errorMessage: String? = nil,
        navigation: AppNavigationModel
    ) {
        self.page = page
        self.errorMessage = errorMessage
        self.navigation = navigation
    }

    func open(_ row: MoveBrowserRow) {
        switch row.action {
        case let .openPage(page):
            navigation.pushPage(page)
        case let .openMotionPlayer(link):
            navigation.pushMotionPlayer(link)
        case .none:
            break
        }
    }
}
