//
//  TallStackLayout.swift
//  Amethyst
//
//  Created by Casey Getz on 10/26/19.
//  Copyright © 2019 Ian Ynda-Hummel. All rights reserved.
//

import Silica

class TallStackLayout<Window: WindowType>: Layout<Window>, PanedLayout {
    override static var layoutName: String { return "Tall Stack" }
    override static var layoutKey: String { return "tall-stack" }

    override var layoutDescription: String { return "" }

    private(set) var mainPaneCount: Int = 1
    private(set) var mainPaneRatio: CGFloat = 0.5

    func recommendMainPaneRawRatio(rawRatio: CGFloat) {
        mainPaneRatio = rawRatio
    }

    func increaseMainPaneCount() {
        mainPaneCount += 1
    }

    func decreaseMainPaneCount() {
        mainPaneCount = max(1, mainPaneCount - 1)
    }

    override func frameAssignments(_ windowSet: WindowSet<Window>, on screen: Screen) -> [FrameAssignment<Window>]? {
        let windows = windowSet.windows

        guard !windows.isEmpty else {
            return []
        }

        let mainPaneCount = min(windows.count, self.mainPaneCount)
        let secondaryPaneCount = windows.count - mainPaneCount
        let hasSecondaryPane = secondaryPaneCount > 0

        let screenFrame = screen.adjustedFrame()

        let mainPaneWindowHeight = screenFrame.size.height
        let secondaryPaneWindowHeight = hasSecondaryPane ? round(screenFrame.size.height / CGFloat(secondaryPaneCount)) : 0.0

        let mainPaneWindowWidth = round(screenFrame.size.width * (hasSecondaryPane ? CGFloat(mainPaneRatio) : 1.0))
        let secondaryPaneWindowWidth = screenFrame.size.width - mainPaneWindowWidth

        return windows.reduce([]) { acc, window -> [FrameAssignment<Window>] in
            var assignments = acc
            var windowFrame = CGRect.zero
            let isMain = acc.count < mainPaneCount
            var scaleFactor: CGFloat

            if isMain {
                scaleFactor = screenFrame.size.width / mainPaneWindowWidth
                windowFrame.origin.x = screenFrame.origin.x
                windowFrame.origin.y = screenFrame.origin.y
                windowFrame.size.width = mainPaneWindowWidth
                windowFrame.size.height = mainPaneWindowHeight
            } else {
                scaleFactor = screenFrame.size.width / secondaryPaneWindowWidth
                windowFrame.origin.x = screenFrame.origin.x + mainPaneWindowWidth
                windowFrame.origin.y = screenFrame.origin.y + (secondaryPaneWindowHeight * CGFloat(acc.count - mainPaneCount))
                windowFrame.size.width = secondaryPaneWindowWidth
                windowFrame.size.height = secondaryPaneWindowHeight
            }

            let resizeRules = ResizeRules(isMain: isMain, unconstrainedDimension: .horizontal, scaleFactor: scaleFactor)
            let frameAssignment = FrameAssignment<Window>(
                frame: windowFrame,
                window: window,
                screenFrame: screenFrame,
                resizeRules: resizeRules
            )

            assignments.append(frameAssignment)

            return assignments
        }
    }
}