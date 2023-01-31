//
//  LineCard.swift
//  LineChart
//
//  Created by András Samu on 2019. 08. 31..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct LineChartView: View {
    // selected value when dragged
    var onValueSelected: (((Date, Double)?) -> ())
    @Binding var selectedValue: (Date, Double)?
    private let chartColor: Color
    private let bgColor: Color

    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var data:ChartData 
    
//    public var formSize:CGSize
    @State private var touchLocation:CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    private let isDragGestureEnabled: Bool
    @Binding var currentValue: Double?
//    var frame: CGSize

    
    public init(data: [(Date, Double)],
                isDragGestureEnabled: Bool,
                chartColor: Color,
                bgColor: Color = .white,
                form: CGSize? = ChartForm.extraLarge,
                currentValue: Binding<Double?>,
                selectedValue: Binding<(Date, Double)?>,
                onValueSelected: @escaping (((Date, Double)?) -> ())
    ) {
        self._selectedValue = selectedValue
        self.onValueSelected = onValueSelected
        self.data = ChartData(numberValues: data.map { ($0.0.timeIntervalSince1970, $0.1) })
        self.isDragGestureEnabled = isDragGestureEnabled
//        self.formSize = form!
//        frame = CGSize(width: self.formSize.width, height: self.formSize.height)
        self._currentValue = currentValue
        self.chartColor = chartColor
        self.bgColor = bgColor

    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center){
                RoundedRectangle(cornerRadius: 0)
                    .fill(self.bgColor)
                    .frame(width: geo.frame(in: .local).width, height: geo.frame(in: .local).height, alignment: .center)
                VStack(alignment: .leading){
                    GeometryReader{ geometry in
                        Line(data: self.data,
                             frame: .constant(geometry.frame(in: .local)),
                             touchLocation: self.$touchLocation,
                             showIndicator: self.$showIndicatorDot,
                             minDataValue: .constant(self.data.points.map { $0.1 }.min()),
                             maxDataValue: .constant(self.data.points.map { $0.1 }.max()),
                             color: chartColor, pointMarkColor: .purple
                        )
                    }
                    .frame(width: geo.frame(in: .local).width, height: geo.frame(in: .local).height)
                    .offset(x: 0, y: 0)
                }.frame(width: geo.frame(in: .local).width, height: geo.frame(in: .local).height)
            }
            .if(isDragGestureEnabled) { view in
                    view.gesture(DragGesture()
                    .onChanged({ value in
                        self.touchLocation = value.location
                        self.showIndicatorDot = true
                        self.getClosestDataPoint(toPoint: value.location, width:geo.frame(in: .local).width, height: geo.frame(in: .local).height)
                    })
                        .onEnded({ value in
                            self.showIndicatorDot = false
                            self.onValueSelected(nil)
                        })
                    )
            }
        }
    }
    
    @discardableResult func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(round((toPoint.x)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentValue = points[index]
            if let dateDouble = Double(data.points[index].0) {
                let selectedData = Date(timeIntervalSince1970: dateDouble)
                self.selectedValue = (selectedData, data.points[index].1)
                self.onValueSelected((selectedData, data.points[index].1))
                
            }
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index])*stepHeight)
        }
        return .zero
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GeometryReader { geo in
                LineChartView(
                    data: [
                        (Date(),8),
                        (Date(timeInterval: 60*60*24*7, since: Date()),282),
                        (Date(timeInterval: 60*60*24*14, since: Date()),502),
                        (Date(timeInterval: 60*60*24*21, since: Date()),12),
                        (Date(timeInterval: 60*60*24*28, since: Date()),37),
                        (Date(timeInterval: 60*60*24*35, since: Date()),7),
                        (Date(timeInterval: 60*60*24*42, since: Date()),285.019),
                        (Date(timeInterval: 60*60*24*49, since: Date()),4)
                    ],
                    isDragGestureEnabled: true,
                    chartColor: Color.blue,
                    currentValue: .constant(0),
                    selectedValue: .constant(nil),
                    onValueSelected: { _ in

                })
                    .environment(\.colorScheme, .light)
            }

            }
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
