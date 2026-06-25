// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import SwiftUI
import Charts
import CblUI

struct ChartScreen: View {
    @State private var salesModel = SalesData()

    var body: some View {
        CblScreen(title: "Charts", image: "harbor1") {
            Chart {
                ForEach(salesModel.sales) { product in
                    ForEach(product.sales) { sale in
                        BarMark(
                            x: .value("Year", sale.year),
                            y: .value("Sales",sale.amount)
                        )
                        .foregroundStyle(by: .value("Type", product.name))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .position(by: .value("Product", product.name),
                                  axis: .horizontal, span: 30)
                        LineMark(
                            x: .value("Year", sale.year),
                            y: .value("Sales",sale.amount+100)
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
                        .foregroundStyle(by: .value("Type", product.name))
                        
                        PointMark(
                            x: .value("Year", sale.year),
                            y: .value("Sales",sale.amount+100)
                        )
                        .foregroundStyle(by: .value("Type", product.name))
                    }
                }
                RuleMark(y: .value("Limit", 4600))
                    .lineStyle(StrokeStyle(lineWidth: 3, dash: [5, 10]))
                    .foregroundStyle(Color.black)
                RuleMark(y: .value("Limit", 3500))
                    .lineStyle(StrokeStyle(lineWidth: 3, dash: [5, 10]))
                    .foregroundStyle(Color.black)
                
            }
            .chartForegroundStyleScale([
                "Cars" : .blue,
                "Ships": .orange
            ])
            .chartLegend(position: .bottom)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 8)
            .chartScrollPosition(initialX:2001)
            .chartYVisibleDomain(length: 1000)
            .chartYScale(domain: 3300...4700)
            .padding(10)
        }
    }
}

#Preview {
    ChartScreen()
}
