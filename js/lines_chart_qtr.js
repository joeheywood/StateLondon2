// !preview r2d3 data=dat, dependencies=c("js/yaxis.js", "js/labels.js", "js/lines_qtr.js", "js/lines.js")
//
// r2d3: https://rstudio.github.io/r2d3
//


/*
let yax = new yaxis(data, 0, 0, 0, 0)
let ll = new legend_labels(data, 0, 0, 0, 0)
let xx = new run_xaxis_qtr2(data, 0, 84, 0, yax.lbwidth, false)
yax = new yaxis(data, 0, 65, xx.height, 0)
ll = new legend_labels(data, 0, 84, xx.height, 0)

let lns = new lines(data, ll.color, xx.xScale, yax.yScale)

*/

let dd1;



r2d3.onRender(function(data, svg, width, height, options){
  // console.log(`w: ${width} | h: ${height} | dl: ${data.length}`)
  if(data.length == 0) {
    return false
  }
  data.forEach(function(d){
    let parseTime = d3.timeParse("%Y-%m-%d");
    d.xd = parseTime(d.xd)
  })
  let yax = new yaxis(data, 0, 0, 0, 0, width, height)
  let ll = new legend_labels(data, 0, 0, 0, 0, width, height)
  let xx = new run_xaxis_qtr2(data, 0, 84, 0, yax.lbwidth, false, width, height)
  yax = new yaxis(data, 0, 65, xx.height, 0, width, height)
  ll = new legend_labels(data, 0, 84, xx.height, 0, width, height)

  let lns = new lines(data, ll.color, xx.xScale, yax.yScale)
  dd1 = data



})

r2d3.onResize(function(width, height){
  svg.selectAll("*").remove()
  let yax = new yaxis(dd1, 0, 0, 0, 0, width, height)
  let ll = new legend_labels(dd1, 0, 0, 0, 0, width, height)
  let xx = new run_xaxis_qtr2(dd1, 0, 84, 0, yax.lbwidth, false, width, height)
  yax = new yaxis(dd1, 0, 65, xx.height, 0, width, height)
  ll = new legend_labels(dd1, 0, 84, xx.height, 0, width, height)

  let lns = new lines(dd1, ll.color, xx.xScale, yax.yScale)
})

