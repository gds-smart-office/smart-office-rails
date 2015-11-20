module MessageHelper
  def chart(start, finish)
    messages_per_day = messages_per_day(start, finish)
    dates = dates(start, finish)

    LazyHighCharts::HighChart.new("graph") do |f|
      f.xAxis(categories: dates, tickmarkPlacement: "on", title: { enabled: false })
      f.yAxis [ {title: {text: "Messages"} } ]
      f.plotOptions(area: { stacking: "normal", lineColor: "#666666", lineWidth: 1,
                            marker: { lineWidth: 1, lineColor: "#666666" } })
      f.legend(enabled: false)
      f.chart({ defaultSeriesType: "column" })
      f.series(name: "Overall", data: messages_per_day)
    end
  end

  def dates(start, finish)
    dates = []
    start.upto(finish) do |date|
      dates.push(date.to_formatted_s(:short))
    end
    dates
  end

  def messages_per_day(start, finish)
    messages = Message.where(created_at: start..(finish+1)).order(:created_at)
    messages_per_day = []
    start.upto(finish) do |date|
      count = messages.select { |message| message.created_at.to_date == date }.size
      messages_per_day.push(count)
    end
    messages_per_day
  end  
end