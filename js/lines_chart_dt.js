// !preview r2d3 data=dat, dependencies=c("js/yaxis.js", "js/labels.js", "js/lines_dt.js", "js/lines.js")
//
//

let dd1;

let high = true;

r2d3.onRender(function(data, svg, width, height, options){
  // console.log(`w: ${width} | h: ${height} | dl: ${data.length}`)
  width = 1000
  height = 500
  if(data.length == 0) {
    return false
  }
  data.forEach(function(d){
    let parseTime = d3.timeParse("%Y-%m-%d");
    d.xd = parseTime(d.xd)
    if(d.y == null) d.y = NaN
  })
  high = options.high
  // console.log(`w: ${width} | h: ${height} | dl: ${data.length}`)
  let yax = new yaxis(data, 0, 0, 0, 0, width, height, options.yfmt, options)
  let ll = new legend_labels(data, 0, 0, 0, 0, width, height, high)
  let xx = new run_xaxis_dt(data, 0, ll.lbwidth, 0, yax.lbwidth, false, width, height)

  // console.log(`ll: ${ll.lbwidth} - yy: ${yax.lbwidth} - xx: ${xx.height}`)
  yax = new yaxis(data, 0, ll.lbwidth, xx.height, 0, width, height, options.yfmt, options)
  ll = new legend_labels(data, 0, ll.lbwidth, xx.height, 0, width, height, high)

  let lns = new lines(data, ll.color, xx.xScale, yax.yScale)
  dd1 = data
})

r2d3.onResize(function(width, height){
  svg.selectAll("*").remove()
  let yax = new yaxis(dd1, 0, 0, 0, 0, width, height, options.yfmt, options)
  let ll = new legend_labels(dd1, 0, 0, 0, 0, width, height, high)
  let xx = new run_xaxis_dt(dd1, 0, ll.lbwidth, 0, yax.lbwidth, false, width, height)
  yax = new yaxis(dd1, 0, ll.lbwidth, xx.height, 0, width, height, options.yfmt, options)
  ll = new legend_labels(dd1, 0, ll.lbwidth, xx.height, 0, width, height, high)

  let lns = new lines(dd1, ll.color, xx.xScale, yax.yScale)
})
