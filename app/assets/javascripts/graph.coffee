$ ->
  Highcharts.setOptions
    global:
      useUTC: false
  $(".graph").each ->
    graph = $(this)
    chart = new Highcharts.Chart
      chart: 
        renderTo: this
        zoomType: "xy"
      credits:
        enabled: false
      title:
        text: null
      legend:
        borderWidth: 0
        layout: "vertical"
      xAxis:
        type: 'datetime'
        title:
          text: null
      yAxis:
        allowDecimals: false
        min: 0
        gridLineColor: "#eeeeee"
        title:
          text: null
      series: graph.data("series")