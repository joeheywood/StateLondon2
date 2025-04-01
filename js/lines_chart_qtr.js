// !preview r2d3 data=dat, dependencies=c("js/yaxis.js", "js/labels.js", "js/lines_qtr.js", "js/lines.js")
//
// r2d3: https://rstudio.github.io/r2d3
//
data.forEach(function(d){
  let parseTime = d3.timeParse("%Y-%m-%d");
  d.xd = parseTime(d.xd)
})


let yax = new yaxis(data, 0, 0, 0, 0)
let ll = new legend_labels(data, 0, 0, 0, 0)
console.log(`Y: ${yax.lbwidth} | ll: ${ll.lbwidth}`)
let xx = new run_xaxis_qtr2(data, 0, 84, 0, yax.lbwidth, false)
yax = new yaxis(data, 0, 65, xx.height, 0)
ll = new legend_labels(data, 0, 84, xx.height, 0)

let lns = new lines(data, ll.color, xx.xScale, yax.yScale)
