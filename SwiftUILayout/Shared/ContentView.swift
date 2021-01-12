//
//  ContentView.swift
//  NotSwiftUI
//
//  Created by Chris Eidhof on 05.10.20.
//

import SwiftUI
#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

func render<V: View_>(view: V, size: CGSize) -> Data {
    return CGContext.image(size: size) { context in
        view
            .frame(width: size.width, height: size.height)
            ._render(context: context, size: size)
    }
}

extension View_ {
    var measured: some View_ {
        overlay(GeometryReader_ { size in
            Text_("\(Int(size.width))")
        })
    }
}

enum MyLeading: AlignmentID, SwiftUI.AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        0
    }
    
    static func defaultValue(in context: CGSize) -> CGFloat {
        0
    }
}

extension HorizontalAlignment_ {
    static let myLeading = HorizontalAlignment_(alignmentID: MyLeading.self, swiftUI: HorizontalAlignment(MyLeading.self))
}

struct ContentView: View {
    let size = CGSize(width: 600, height: 400)

    
    // [SwiftUILayoutiOSTests.Frame.flexible, SwiftUILayoutiOSTests.Frame.min(74.0), SwiftUILayoutiOSTests.Frame.max(23.0)]
    var sample: some View_ {
        VGrid(columns: [.fixed(100), .flexible(minimum: 100, maximum: 200), .flexible(minimum: 10, maximum: 50)], content: [
            AnyView_(
                Rectangle_()
                    .foregroundColor(Color_.red)
                    .measured
            ),
            AnyView_(
                Rectangle_()
                    .foregroundColor(Color_.green)
                    .frame(minHeight: 50)
                    .measured
            ),
            AnyView_(
                Rectangle_()
                    .foregroundColor(Color_.yellow)
                    .measured
            ),
        ])
        .border(Color_.blue)
        .frame(width: width, height: 200)
        .border(Color_.red)
    }

    @State var opacity: Double = 0.5
    @State var width: CGFloat  = 300

    var body: some View {
        VStack {
            ZStack {
                Image(native: Image_(data: render(view: sample, size: size))!)
                    .resizable()
                    .frame(width: size.width, height: size.height)
                    .opacity(1-opacity)
                sample.swiftUI.frame(width: size.width, height: size.height)
                    .opacity(opacity)
            }
            Slider(value: $opacity, in: 0...1)
                .padding()
            HStack {
                Text("Width \(width.rounded())")
                Slider(value: $width, in: 0...600)
            }.padding()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 1080/2)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
