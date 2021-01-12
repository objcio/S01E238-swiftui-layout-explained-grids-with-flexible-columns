//
//  Grid.swift
//  SwiftUILayout
//
//  Created by Chris Eidhof on 05.01.21.
//

import SwiftUI

struct VGrid: BuiltinView, View_ {
    var columns: [GridItem.Size]
    var content: [AnyView_]
    
    func size(proposed: ProposedSize) -> CGSize {
        let columnWidths = layoutColumns(proposed.orDefault.width)
        let width = columnWidths.reduce(0,+)
        var remainingViews = content
        var height: CGFloat = 0
        while !remainingViews.isEmpty {
            let lineViews = remainingViews.prefix(columns.count)
            remainingViews.removeFirst(lineViews.count)
            var lineHeight: CGFloat = 0
            for (column, view) in zip(columnWidths, lineViews) {
                lineHeight = max(lineHeight, view.size(proposed: ProposedSize(width: column, height: nil)).height)
            }
            height += lineHeight
        }
        return CGSize(width: max(proposed.orDefault.width, width), height: height)
    }
    
    func render(context: RenderingContext, size: CGSize) {
        let columnWidths = layoutColumns(size.width)
        var remainingViews = content
        var offsetY: CGFloat = 0
        while !remainingViews.isEmpty {
            var offsetX: CGFloat = 0
            let lineViews = remainingViews.prefix(columnWidths.count)
            remainingViews.removeFirst(lineViews.count)
            var lineHeight: CGFloat = 0
            for (column, view) in zip(columnWidths, lineViews) {
                lineHeight = max(lineHeight, view.size(proposed: ProposedSize(width: column, height: nil)).height)
            }
            for (column, view) in zip(columnWidths, lineViews) {
                let childSize = view.size(proposed: ProposedSize(width: column, height: lineHeight))
                context.saveGState()
                context.translateBy(x: offsetX, y: offsetY)
                view.render(context: context, size: childSize)
                context.restoreGState()
                offsetX += childSize.width
            }
            offsetY += lineHeight
        }
    }
    
    func layoutColumns(_ width: CGFloat) -> [CGFloat] {
        var remainingIndices = columns.indices.sorted { ix1, ix2 in
            if case .fixed = columns[ix1] { return true }
            if case .fixed = columns[ix2] { return false }
            return ix1 < ix2
        }
        var result: [CGFloat] = Array(repeating: 0, count: columns.count)
        var remainingWidth = width
        while !remainingIndices.isEmpty {
            let proposed = remainingWidth / CGFloat(remainingIndices.count)
            let idx = remainingIndices.removeFirst()
            let columnWidth: CGFloat
            switch columns[idx] {
            case let .fixed(width): columnWidth = width
            case let .flexible(minimum, maximum): columnWidth = min(max(minimum, proposed), maximum)
            case let .adaptive(minimum, maximum): fatalError()
            @unknown default: fatalError()
            }
            result[idx] = columnWidth
            remainingWidth -= columnWidth
        }
        return result
    }
    

    
    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        return nil
    }
    
    var layoutPriority: Double { 0 }
    
    var swiftUI: some View {
        let items = columns.map { GridItem($0, spacing: 0, alignment: .leading)}
        return LazyVGrid(columns: items, alignment: .leading, spacing: 0, pinnedViews: []) {
            ForEach(content.indices, id: \.self) { idx in
                content[idx].swiftUI
            }
        }
    }
}
