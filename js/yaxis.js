// !preview r2d3 data=c(0.3, 0.6, 0.8, 0.95, 0.40, 0.20)
//
// r2d3: https://rstudio.github.io/r2d3
//

function yaxis(data, marginTop, marginRight, marginBottom, marginLeft, wy, hy ) {
  svg.selectAll(".yaxis_1").remove()
  let chart_id = 1

  //// Y-Axis ////
  let ticks = Math.floor(hy/110)
  let tickFormat = ".0f"
  yFontsize = "11pt"



  let yext = d3.extent(data, d => d.y)
  let range = yext[1] - yext[0]
  let rangepad = range * .25
  let ymm = (yext[0] >= 0 && yext[0] - range < 0 ? 0 : yext[0] - rangepad)
  yDomain = [ymm, yext[1] + rangepad];
  yRange = [(hy - marginTop - marginBottom), marginTop]

  let yg = svg.append("g")
    .classed(`yaxis_${chart_id}`, true)
    .attr("name", `yaxis_${chart_id}`)

  yScale = d3.scaleLinear(yDomain, yRange);
  // range = yRange ??
  const yAxis = d3.axisLeft(yScale)
  let yax = yg
    .call(yAxis
    .ticks(ticks)
    .tickSize(-wy)
    .tickFormat(d3.format(tickFormat)));

  yax.selectAll(".tick text")
    .text(d => d3.format(tickFormat)(d))
    .style("font-family", "Arial")
    .style("font-size", yFontsize)
    .style("text-anchor", "start")
    .style("fill", "#665c54")

  yax.selectAll(".tick text")
    .attr('x', '5')
    .attr('dy', '-4');

  yax.selectAll(".tick line")
    .attr("x2", (wy - marginRight) - 5)

  txtlft = 0;

  yg.select(".domain").remove();
  yg.selectAll(".tick line")
    .style("stroke", "#ababab")
    .style("stroke-opacity", 0.4)

  let lbw = 0;
  yg.selectAll(".tick text").each(function(){
    let ygw = this.getBBox().width
    lbw = (lbw >= ygw ? lbw : ygw)
  })

  this.lbwidth = lbw
  this.yScale = yScale
}

