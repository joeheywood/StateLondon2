// !preview r2d3 data=dat, dependencies=c("js/yaxis.js", "js/labels.js", "js/lines_dt.js", "js/lines.js", "js/xaxis_char.js"), options=list(yfmt = ".0%")
//
//

let dd1;

let high = false;

r2d3.onRender(function(data, svg, width, height, options){

  //width = 1000
  // height = 500
  if(data.length == 0) {
    return false
  }

  high = false //options.high

  let yax = new yaxis(data, 0, 0, 0, 0, width, height, options.yfmt, options)
  let ll = new legend_labels(data, 0, 0, 0, 0, width, height, high, yax.yScale)
  let xx = new x_axis_lines_char(data, {top: 0, right: ll.lbwidth, bottom: 0, left:yax.lbwidth}, width, height, {bar:false})

  yax = new yaxis(data, 0, ll.lbwidth, xx.height, 0, width, height, options.yfmt, options)
  // ll = new legend_labels(data, 0, ll.lbwidth, xx.height, 0, width, height, high, yax.yScale)
  ll = new legend_labels(data, 0, ll.lbwidth, xx.height, 0, width, height, high, yax.yScale, xx.xScale)

  let lns = new lines(data, ll.color, xx.xScale, yax.yScale)
  dd1 = data
})

r2d3.onResize(function(width, height){
  svg.selectAll("*").remove()
  let yax = new yaxis(dd1, 0, 0, 0, 0, width, height, options.yfmt, options)
  let ll = new legend_labels(dd1, 0, 0, 0, 0, width, height, high, yax.yScale)
  let xx = new x_axis_lines_char(data, {top: 0, right: ll.lbwidth, bottom: 0, left:yax.lbwidth}, width, height, {})
  // let xx = new run_xaxis_dt(dd1, 0, ll.lbwidth, 0, yax.lbwidth, false, width, height)
  yax = new yaxis(dd1, 0, ll.lbwidth, xx.height, 0, width, height, options.yfmt, options)
  // ll = new legend_labels(dd1, 0, ll.lbwidth, xx.height, 0, width, height, high, yax.yScale)
  ll = new legend_labels(dd1, 0, ll.lbwidth, xx.height, 0, width, height, high, yax.yScale, xx.xScale)

  let lns = new lines(dd1, ll.color, xx.xScale, yax.yScale)
})
