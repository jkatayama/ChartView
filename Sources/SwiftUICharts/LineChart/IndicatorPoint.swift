//
//  IndicatorPoint.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 03..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

struct IndicatorPoint: View {
    let color: Color
    
    var body: some View {
        ZStack{
            Circle()
                .fill(color)
        }
        .frame(width: 8, height: 8)
    }
}

struct IndicatorPoint_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorPoint(color: .blue)
    }
}
