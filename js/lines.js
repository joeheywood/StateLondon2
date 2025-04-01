// !preview r2d3 data=c(0.3, 0.6, 0.8, 0.95, 0.40, 0.20)
//
// r2d3: https://rstudio.github.io/r2d3
//

function lines(data, color, xScale, yScale) {
  svg.selectAll(".linesg").remove()

  linesg = svg.append("g")
    .classed("linesg", true)
    .attr("name", "linesg");

  dashg = svg.append("g")
    .classed("dashg", true)
    .attr("name", "dashg");

  markg = svg.append("g")
    .classed("markg", true)
    .attr("name", "markg");

  let solid = [];
  let dashed = [];

  data.forEach((d) => {
    if(d.text === "dotted") {
      dashed.push(d);
    } else if(d.text == "solid_join" ) {
      solid.push(d);
      dashed.push(d);
    } else {
      solid.push(d);
    }
  })

  const dats = d3.group(solid, d => d.b);
  const dashdats = d3.group(dashed, d => d.b)


  let linesize = 4

  linesg
    .selectAll("path")
    .data(dats)
    // .transition(this.t)
    .join("path")
    .attr('fill', 'none')
    .attr('stroke-width', linesize)
    .attr("stroke-opacity", 0.95)
    .attr('stroke', d => color(d[0]))
    .attr("d", d => {
      return d3.line()
      .defined((d, i) => { return !isNaN(d.y)})
      // .curve(d3.curveMonotoneX)
      .x(d => xScale(d.xd))
      .y(d => yScale(d.y))
      (d[1]);
    })

}
