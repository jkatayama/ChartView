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
//    public var title: String
//    public var legend: String?
//    public var style: ChartStyle
//    public var darkModeStyle: ChartStyle
    
    public var formSize:CGSize
//    public var dropShadow: Bool
//    public var valueSpecifier:String
    
    @State private var touchLocation:CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    @Binding var currentValue: Double?
    
//    {
//        didSet{
//            if (oldValue != self.currentValue && showIndicatorDot) {
//                HapticFeedback.playSelection()
//            }
//
//        }
//    }
    var frame: CGSize
//    private var rateValue: Int?
    
    public init(data: [(Date, Double)],
//                title: String,
//                legend: String? = nil,
                chartColor: Color,
                bgColor: Color = .white,
//                style: ChartStyle = Styles.lineChartStyleOne,
                form: CGSize? = ChartForm.extraLarge,
//                rateValue: Int?,
//                dropShadow: Bool? = true,
//                valueSpecifier: String? = "%.1f",
                currentValue: Binding<Double?>,
                selectedValue: Binding<(Date, Double)?>,
                onValueSelected: @escaping (((Date, Double)?) -> ())
    ) {
        self._selectedValue = selectedValue
        self.onValueSelected = onValueSelected
        self.data = ChartData(numberValues: data.map { ($0.0.timeIntervalSince1970, $0.1) })
//        self.title = title
//        self.legend = legend
//        self.style = style
//        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.formSize = form!
        frame = CGSize(width: self.formSize.width, height: self.formSize.height)
//        self.dropShadow = dropShadow!
//        self.valueSpecifier = valueSpecifier!
//        self.rateValue = rateValue
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
    //                .shadow(color: self.style.dropShadowColor, radius: self.dropShadow ? 8 : 0)
                VStack(alignment: .leading){
    //                if(!self.showIndicatorDot){
    //                    VStack(alignment: .leading, spacing: 8){
    //                        Text(self.title)
    //                            .font(.title)
    //                            .bold()
    //                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
    //                        if (self.legend != nil){
    //                            Text(self.legend!)
    //                                .font(.callout)
    //                                .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor :self.style.legendTextColor)
    //                        }
    //                        HStack {
    //
    //                            if let rateValue = self.rateValue
    //                            {
    //                                if (rateValue ?? 0 >= 0){
    //                                    Image(systemName: "arrow.up")
    //                                }else{
    //                                    Image(systemName: "arrow.down")
    //                                }
    //                                Text("\(rateValue)%")
    //                            }
    //                        }
    //                    }
    //                    .transition(.opacity)
    //                    .animation(.easeIn(duration: 0.1))
    //                    .padding([.leading, .top])
    //                }else{
    //                    HStack{
    //                        Spacer()
    //                        Text("\(self.currentValue ?? 0, specifier: self.valueSpecifier)")
    //                            .font(.system(size: 41, weight: .bold, design: .default))
    //                            .offset(x: 0, y: 30)
    //                        Spacer()
    //                    }
    //                    .transition(.scale)
    //                }
    //                Spacer()
                    GeometryReader{ geometry in
                        Line(data: self.data,
                             frame: .constant(geometry.frame(in: .local)),
                             touchLocation: self.$touchLocation,
                             showIndicator: self.$showIndicatorDot,
                             minDataValue: .constant(self.data.points.map { $0.1 }.min()),
                             maxDataValue: .constant(self.data.points.map { $0.1 }.max()),
                             color: chartColor
                        )
                    }
                    .frame(width: geo.frame(in: .local).width, height: geo.frame(in: .local).height)
    //                .clipShape(RoundedRectangle(cornerRadius: 20))
                    .offset(x: 0, y: 0)
                }.frame(width: geo.frame(in: .local).width, height: geo.frame(in: .local).height)
            }
            .gesture(DragGesture()
            .onChanged({ value in
                self.touchLocation = value.location
                self.showIndicatorDot = true
                self.getClosestDataPoint(toPoint: value.location, width:geo.frame(in: .local).width, height: geo.frame(in: .local).height)
                self.onValueSelected((Date(), 0))
            })
                .onEnded({ value in
                    self.showIndicatorDot = false
                    self.onValueSelected(nil)
                })
            )

        }
    }
    
    @discardableResult func getClosestDataPoint(toPoint: CGPoint, width:CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.max()! + points.min()!)
        
        let index:Int = Int(round((toPoint.x)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentValue = points[index]
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
