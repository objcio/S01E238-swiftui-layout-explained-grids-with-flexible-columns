//
//  Text.swift
//  SwiftUILayout
//
//  Created by Chris Eidhof on 27.10.20.
//

import SwiftUI

struct Text_: View_, BuiltinView {
    let text: String
    init(_ text: String) {
        self.text = text
    }
    
    let font = Font_.systemFont(ofSize: 16)
    var attributes: [NSAttributedString.Key: Any] {
        [
            .font: font,
            .foregroundColor: Color_.white
        ]
    }

    var framesetter: CTFramesetter {
        let str = NSAttributedString(string: text, attributes: attributes)
        return CTFramesetterCreateWithAttributedString(str)
    }
    
    var layoutPriority: Double { 0 }

    func customAlignment(for alignment: HorizontalAlignment_, in size: CGSize) -> CGFloat? {
        return nil
    }

    func render(context: RenderingContext, size: CGSize) {
        let path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(), path, nil)
        context.saveGState()
        #if os(iOS)
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        #endif
        CTFrameDraw(frame, context)
        context.restoreGState()
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        return CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(), nil, proposed.orMax, nil)
    }
    
    var swiftUI: some View {
        Text(text).font(Font(font))
    }
}
