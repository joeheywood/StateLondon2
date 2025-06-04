// !preview r2d3 data=dat, dependencies=c("js/yaxis.js", "js/labels.js", "js/lines_qtr.js", "js/lines.js")
//
// r2d3: https://rstudio.github.io/r2d3
//


function x_axis_lines_char(data, margins, xdw, xdh, opts) {
  //// Constructor ////
  // console.log(`X CHAR `)
  let chart_id = 1
  let showXgrid = true;
  let self  = this;
  svg.selectAll(".xaxis").remove()
  self.xg = svg.append("g").classed("xaxis", true)
  self.xg.selectAll("*").remove()
  let xAxis, xAxis_l, cbox, ggc, ggc_lower;


  let xDomain = data.map(d => d.xd) // d3.extent(data, d => d.xd)
  let xRange = [margins.left, (xdw - margins.right)]

  //let xScale = d3.scaleUtc(xDomain, xRange);
  if(opts.bar) {
    self.xScale =  d3.scaleBand(xDomain, xRange).padding(0.1);
  } else {
    self.xScale =  d3.scalePoint(xDomain, xRange).padding(0.1);
  }


  this.xScale = self.xScale
  xAxis = d3.axisBottom(self.xScale)
  .tickSizeOuter(0)
  .tickSizeInner(5)


  ggc = self.xg.append("g")
  .attr("name", "ggc")
  .classed("charx", true)
  .call(xAxis);

  var xax = self.xg.selectAll(".xaxis")
  .attr("transform", "translate(0," + this.chartheight + ")")
  .attr("class", "xaxis")
  .call(xAxis);

  self.xg.append("g").attr("class", `gridxc_${chart_id}`)


  ggc.selectAll(".tick text")
  .attr("transform", `translate(0, 10)`)
  .style("font-family", "Arial")
  .style("font-size", "12pt")
  //.style("fill", "#888888")
  .style("fill", "#515a5e")

  ggc.select(".domain")
  .style("stroke", "#ABABAB")

  ggc.selectAll(".charx>.tick line")
  .style("stroke", "#ABABAB")



  //cbox = get_bbox(svg, "ggc")
  cbox = ggc.node().getBBox()
  self.lheight = cbox.height
  self.height = cbox.height
  //self.lheight = 30
  ggc.attr("transform", `translate(0, ${xdh - self.lheight})`)

  if(showXgrid) {

      let gridc = self.xg.selectAll(`.gridxc_${chart_id}`)
        .call(d3.axisBottom(self.xScale)
          .ticks(width / 80) // not numticks?
          .tickSize(height - self.lheight - margins.top)
          .tickFormat("")
        )
        .attr("transform", `translate(0, ${margins.top})`)

      self.xg.selectAll(`.gridxc_${chart_id} line`)
        .style("stroke", "#BCBCBC")
        .style("stroke-opacity", "0.4")
        .style("stroke-width", d => (d == 0 ? 3 : 1))
        .style("shape-rendering", "crispEdges")

      self.xg.select(`.gridxc_${chart_id} .domain`).remove();

    }
    return self
}
// let x = new  x_axis_lines_char(data, {top: 0, right: 0, bottom: 0, left:0}, 1000, 500, {})
