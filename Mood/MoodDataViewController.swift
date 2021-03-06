//
//  MoodDataViewController.swift
//  Mood
//
//  Created by Hys on 2017/7/27.
//  Copyright © 2017年 Hys. All rights reserved.
//

import UIKit
import Charts

class MoodDataViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var lineChartLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    var records = [Record]()
    //趋势图是否显示全部数据(随设置变动)
    var showAllData = false
    
    //MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.scrollView.refreshControl = UIRefreshControl()
        self.scrollView.refreshControl!.attributedTitle = NSAttributedString(string: "下拉刷新")
        self.scrollView.refreshControl!.addTarget(self, action: .refresh, for: .valueChanged)
        
        refresh()
    }
    
    //MARK: Methods
    
    func refresh() {
        //获取所有记录数据
        records = Record.getAllRecords()
        
        //更新设置
        if let setting = Setting.getSetting() {
            showAllData = setting.2
        }
        
        //画趋势图
        setupLineChart()
        //画分布图
        setupPieChart()
        
        //结束刷新
        self.scrollView.refreshControl!.endRefreshing()
    }
    
    func setupLineChart() {
        var dataEntries = [ChartDataEntry]()
        var dates = [String]()
        
        lineChartLabel.text = showAllData ? "历史心情趋势图" : "最近7天心情趋势图"
        
        //根据设置决定num
        let num = showAllData ? records.count : (records.count > 7 ? 7 : records.count)

        for index in 0..<num {
            let record = records[records.count - num + index]
            let dataEntry = ChartDataEntry(x: Double(index), y: Double(record.moodScore))
            
            dataEntries.append(dataEntry)
            
            let formatter = DateFormatter()
            
            formatter.dateFormat = "MM-dd"
            dates.append(formatter.string(from: record.createdAt!))
        }
        
        let dataSet = LineChartDataSet(values: dataEntries, label: nil)
        
        //不显示圆圈
        dataSet.drawCirclesEnabled = false
        //不显示值
        dataSet.drawValuesEnabled = false
        //曲线设置为贝塞尔曲线
        dataSet.mode = .cubicBezier
        //允许填充色
        dataSet.drawFilledEnabled = true
        
        let color1 = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 0.2)
        let color2 = UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 0.8)
        
        //设置填充色
        dataSet.fillColor = (color1)
        //设置线条颜色
        dataSet.setColor(color2)
        
        let data = LineChartData(dataSet: dataSet)
        
        lineChartView.data = data
        
        //不可拖动
        lineChartView.dragEnabled = false
        //不可按X轴缩放
        lineChartView.scaleXEnabled = false
        //不可按Y轴缩放
        lineChartView.scaleYEnabled = false
        //没有description
        lineChartView.chartDescription = nil
        //设置padding使得X轴的数据能显示完全
        lineChartView.minOffset = 30
        //不显示图例
        lineChartView.legend.enabled = false
        //更改X轴的显示数据为对应的日期
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
        //X轴在下方
        lineChartView.xAxis.labelPosition = .bottom
        //X轴的网格不显示
        lineChartView.xAxis.drawGridLinesEnabled = false
        //Y轴网格不显示
        lineChartView.leftAxis.drawGridLinesEnabled = false
        //右边的Y轴不显示
        lineChartView.rightAxis.enabled = false
        //左边的Y轴不显示
        lineChartView.leftAxis.enabled = false
        //设置间隔
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = 1
    }
    
    func setupPieChart() {
        var dataEntries = [PieChartDataEntry]()
        var days = [0,0,0,0,0,0]
        let names = ["想哭","悲伤","难过","一般","愉快","开心"]
        let red: [CGFloat] = [26/255.0,231/255.0,230/255.0,241/255.0,46,52/255.0]
        let green: [CGFloat] = [188/255.0,76/255.0,126/255.0,196/255.0,204/255.0,152/255.0]
        let blue: [CGFloat] = [156/255.0,60/255.0,34/255.0,15/255.0,113/255.0,219/255.0]

        for record in records {
            days[record.moodScore] += 1
        }
        
        for index in 0..<days.count {
            let dataEntry = PieChartDataEntry()
            
            dataEntry.y = Double(days[days.count - index - 1])
            dataEntry.label = names[days.count - index - 1]
            dataEntries.append(dataEntry)
        }
        
        let dataSet = PieChartDataSet(values: dataEntries, label: "")
        var colors = [UIColor]()
        
        for index in 0..<red.count {
            let color = UIColor(red: red[index], green: green[index], blue: blue[index], alpha: 0.8)
            
            colors.append(color)
        }
        
        //设置颜色
        dataSet.colors = colors
        //显示数值
        dataSet.drawValuesEnabled = true
        //内部显示
        dataSet.yValuePosition = .insideSlice
        //选中后扇形区域不放大（这样可以使得图形更大）
        dataSet.selectionShift = 0
        
        //自定义数据格式
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        
        let myFormatter = MyFormatter(formatter: formatter)
        
        dataSet.valueFormatter = myFormatter
        
        let data = PieChartData(dataSet: dataSet)
        
        pieChartView.data = data
        
        //不显示label
        pieChartView.drawEntryLabelsEnabled = false
        //使用百分比
        pieChartView.usePercentValuesEnabled = true
        //允许空心
        pieChartView.drawHoleEnabled = true
        //设置空心圆半径百分比
        pieChartView.holeRadiusPercent = 0.5
        //设置空心圆颜色
        pieChartView.holeColor = UIColor.clear
        //设置空心外圆半径百分比
        pieChartView.transparentCircleRadiusPercent = 0.52
        //设置空心外圆颜色
        pieChartView.transparentCircleColor = UIColor(red: 210/255, green: 145/255, blue: 165/255, alpha: 0.3)
        //关闭图表描述
        pieChartView.chartDescription!.enabled = false
        //图例居中显示
        pieChartView.legend.horizontalAlignment = .center
        //图例最大百分比
        pieChartView.legend.maxSizePercent = 1
        //不知道
        pieChartView.legend.formToTextSpace = 5
        //图例字体
        pieChartView.legend.font = UIFont.systemFont(ofSize: 10)
        //设置图例样式为圆形
        pieChartView.legend.form = .circle
        //设置图例大小
        pieChartView.legend.formSize = 12
        //关闭旋转
        pieChartView.rotationEnabled = false
    }
}

private extension Selector {
    static let refresh = #selector(MoodDataViewController.refresh)
}
