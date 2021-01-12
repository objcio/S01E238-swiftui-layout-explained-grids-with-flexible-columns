//
//  SwiftUILayoutiOSTests.swift
//  SwiftUILayoutiOSTests
//
//  Created by Chris Eidhof on 10.11.20.
//

import XCTest
import SwiftUI
@testable import SwiftUILayoutiOS

enum Frame {
    case flexible
    case fixed(CGFloat)
    case min(CGFloat)
    case max(CGFloat)
    case minMax(min: CGFloat, max: CGFloat)
}

extension Frame {
    static func random() -> Frame {
        func randomWidth() -> CGFloat {
            CGFloat.random(in: 0..<100).rounded()
        }
        switch Int.random(in: 0..<5) {
        case 0:
            return .flexible
        case 1:
            return .fixed(randomWidth())
        case 2:
            return .min(randomWidth())
        case 3:
            return .max(randomWidth())
        case 4:
            let max = randomWidth()
            return .minMax(min: CGFloat.random(in: 0...max).rounded(), max: max)
        default: fatalError()
        }
    }
    
    var view: AnyView_ {
        let r = Rectangle_()
        switch self {
        case .flexible:
            return AnyView_(r)
        case .fixed(let w):
            return AnyView_(r.frame(width: w))
        case .min(let w):
            return AnyView_(r.frame(minWidth: w))
        case .max(let w):
            return AnyView_(r.frame(maxWidth: w))
        case .minMax(min: let min, max: let max):
            return AnyView_(r.frame(minWidth: min, maxWidth: max))
        }
    }
}

struct WidthKey: PreferenceKey {
    static var defaultValue: [CGFloat] =  []
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

class SwiftUILayoutiOSTests: XCTestCase {
    func testExample() throws {
        for _ in 0..<1000 {
            let frames = (0...Int.random(in: 0..<10)).map { _ in
                Frame.random()
            }
            let subviews = frames.map { $0.view }
            let swiftUIViews = subviews.map { $0.swiftUI }
            let proposedWidth = CGFloat.random(in: 0..<500).rounded()
            let stack = HStack_(children: subviews)
            stack.layout(proposed: ProposedSize(width: proposedWidth, height: 100))
            var swiftUISizes: [CGFloat]! = nil
            let swiftUI = HStack(spacing: 0) {
                ForEach(swiftUIViews.indices) { ix in
                    swiftUIViews[ix].overlay(GeometryReader { proxy in
                        Color.clear.preference(key: WidthKey.self, value: [proxy.size.width])
                    })
                }
            }
            .frame(width: proposedWidth, height: 100)
            .onPreferenceChange(WidthKey.self) {
                swiftUISizes = $0
            }
            let controller = UIHostingController(rootView: swiftUI)
            controller.view.snapshotView(afterScreenUpdates: true)
            XCTAssertEqual(swiftUISizes, stack.sizes.map { $0.width }, "\(frames) - proposedWidth: \(proposedWidth)")
        }
    }
}
