//
//  Line.swift
//  LineChart
//
//  Created by András Samu on 2019. 08. 30..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct Line: View {          
    private let areaMarkColor: LinearGradient
    @ObservedObject var data: ChartData
    @Binding var frame: CGRect
    @Binding var touchLocation: CGPoint
    @Binding var showIndicator: Bool
    @Binding var minDataValue: Double?
    @Binding var maxDataValue: Double?
    @State private var showFull: Bool = false
    
    // areaMark
    @State var showBackground: Bool = true
    public let color: Color
    private let gradient: Gradient// = GradientColor(start: color, end: color)
    var index:Int = 0
    let padding:CGFloat = 0
    var curvedLines: Bool = true
    var stepWidth: CGFloat {
        if data.points.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(data.points.count-1)
    }
    var stepHeight: CGFloat {
        var min: Double?
        var max: Double?
        let points = self.data.onlyPoints()
        if minDataValue != nil && maxDataValue != nil {
            min = minDataValue!
            max = maxDataValue!
        }else if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
            min = minPoint
            max = maxPoint
        }else {
            return 0
        }
        if let min = min, let max = max, min != max {
            if (min <= 0){
                return (frame.size.height-padding) / CGFloat(max - min)
            }else{
                return (frame.size.height-padding) / CGFloat(max - min)
            }
        }
        return 0
    }
    var path: Path {
        let points = self.data.onlyPoints()
        return curvedLines ? Path.quadCurvedPathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight), globalOffset: minDataValue) : Path.linePathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    var closedPath: Path {
        let points = self.data.onlyPoints()
        return curvedLines ? Path.quadClosedCurvedPathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight), globalOffset: minDataValue) : Path.closedLinePathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    
    public var body: some View {
        ZStack {
            if(self.showFull && self.showBackground){
                self.closedPath
                    .fill(areaMarkColor)
                    .rotationEffect(.degrees(180), anchor: .center)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .transition(.opacity)

            }
            self.path
                .trim(from: 0, to: self.showFull ? 1:0)
                .stroke(LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing) ,style: StrokeStyle(lineWidth: 1, lineJoin: .round))
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .onAppear {
                    self.showFull = true
            }
            .onDisappear {
                self.showFull = false
            }
            if(self.showIndicator) {
                IndicatorPoint()
                    .position(self.getClosestPointOnPath(touchLocation: self.touchLocation))
                    .rotationEffect(.degrees(180), anchor: .center)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
    }
    
    public init(data: ChartData, frame: Binding<CGRect>, touchLocation: Binding<CGPoint>, showIndicator: Binding<Bool>, minDataValue: Binding<Double?>, maxDataValue: Binding<Double?>, showBackground: Bool = true, color: Color, index: Int = 0) {
        self.data = data
        self._frame = frame
        self._touchLocation = touchLocation
        self._showIndicator = showIndicator
        self._minDataValue = minDataValue
        self._maxDataValue = maxDataValue
        self.index = index
        self.showBackground = showBackground
        self.color = color
        
        self.gradient = Gradient(colors: [color,color])
        
        self.areaMarkColor = LinearGradient(
                        gradient: Gradient (
                            colors: [
                                color.opacity(0.5),
                                color.opacity(0.25),
                                color.opacity(0.12),
                                color.opacity(0.05),
                                color.opacity(0),
                            ]
                        ),
                        startPoint: .bottom,
                        endPoint: .top
                    )

//        ChartData(numberValues: [(0.1, 0.12)])
//            gradient: ,
//            startPoint: .top,
//            endPoint: .bottom
//        )
//GradientColor(start: color, end: color)
        
//        self._showFull = showFull
//        self._showBackground = showBackground
//        self._gradient = gradient
//        self._index = index
//        self._curvedLines = curvedLines
    }
    
    func getClosestPointOnPath(touchLocation: CGPoint) -> CGPoint {
        let closest = self.path.point(to: touchLocation.x)
        return closest
    }
    
}

struct Line_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GeometryReader{ geometry in
                Line(
                    data: ChartData(points: [12,-230,10,54]),
                     frame: .constant(geometry.frame(in: .local)),
                     touchLocation: .constant(CGPoint(x: 100, y: 12)),
                     showIndicator: .constant(true),
                     minDataValue: .constant([12,-230,10,54].min()),
                     maxDataValue: .constant([12,-230,10,54].max()),
                     color: Colors.OrangeStart
                )
            }.frame(width: 320, height: 160)
            
            GeometryReader{ geometry in
                Line(data: TestData.dataEmpty, frame: .constant(geometry.frame(in: .local)), touchLocation: .constant(CGPoint(x: 100, y: 12)), showIndicator: .constant(true), minDataValue: .constant([37,72,51,22,0,0,0,0,0].min()), maxDataValue: .constant([37,72,51,22,0,0,0,0,0].max()), color: Colors.color2Accent)
            }.frame(width: 320, height: 160)
            
            GeometryReader{ geometry in
                Line(
                    data: ChartData(numberValues: [
                        (1674753304, 12),
                        (1674753305, -230),
                        (1674753306, 10),
                        (1674753307, 54)
                    ]),
                     frame: .constant(geometry.frame(in: .local)),
                     touchLocation: .constant(CGPoint(x: 100, y: 12)),
                     showIndicator: .constant(true),
                     minDataValue: .constant([12,-230,10,54].min()),
                     maxDataValue: .constant([12,-230,10,54].max()),
                     color: Colors.GradinetUpperBlue1
                )
            }.frame(width: 320, height: 160)


        }
    }
}
