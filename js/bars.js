// !preview r2d3 data=c(0.3, 0.6, 0.8, 0.95, 0.40, 0.20)
//
// r2d3: https://rstudio.github.io/r2d3
//

/*function bars (data, svg, {
  xvar = "xd",
  //width,
  //height,
  highlight = false,
  cheight,
  marginTop = 10,
  marginBottom = 20,
  marginLeft = 0,
  marginRight = 0,
  xScale,
  yScale,
  color,
  stackgroup = "stack",
  datacols,
  silent_x = false,
  cust_opac = 0.6,
  strokewidth = 2,
  tt
} = {}, contg) {*/
function bars (data, color, xScale, yScale, opts) {
  svg.selectAll(".barg").remove()
  let self = this

  //// Constructor /////
  let dats, res, xSubgroup;
  let barg = svg.append("g")
    .classed("barg", true)
    .attr("name", "barg");

  if(opts.stackgroup == "stack") {
    let cols = Object.keys(data[0])
    let a = cols.shift()
    self.stackedData = d3.stack()
      .keys(cols)(data);
  } else {
    self.bargroups = d3.group(data, d => d["xd"])
    self.subgroups = Array.from(self.bargroups.keys());
    dats = d3.group(data, d => d.b);
    res = Array.from(dats.keys());

    xSubgroup = d3.scaleBand()
      .domain(res)
      .range([0, xScale.bandwidth()])
      .padding([0.15]);

  }


  if(opts.stackgroup == "stack") {

      barg.selectAll(".barg")
        .data(self.stackedData)
        .join("g")
        .attr("fill", d => color(d.key))
        .attr("stroke", "#FFFFFF")
        .attr("stroke-width", 2)
        .classed("stackgroups", true)

        .selectAll("rect")
        // enter a second time = loop subgroup per subgroup to add all rectangles
        .data(d => d)
        .join("rect")
        .attr("x", (d) => {
          return xScale(d.data["xd"])

        })
        .attr("y", (d) => {  return yScale(d[1])})
        //.attr("class", d => `stack_${d.data.dtid}`)

        .style("opacity", 0.8)
        //.attr("fill", d => color(d.key))
        .attr("height", (d) => {
          return yScale(d[0]) - yScale(d[1])
        })
        .attr("width", xScale.bandwidth())
        //.attr("width", 7)
        .lower()
        .on("mouseover", function(e, d) {
          tt.m_over(d, xScale(d.data[xvar]))

        })
        .on("mouseout", function(e, d) {
          tt.m_out()

        })
      .on("mousemove", function(d) {
        svg.selectAll(".barg").lower()
      })

      //.attr("width", 40)

    } else {
      svg.selectAll(".bargroup").remove();
      // a bit of a hack. Used a foreach for each of the groups
      self.subgroups.forEach((x) => {
        var gg = svg.append("g")
          .attr("transform", d => `translate(${xScale(x)}, 0)`)
          .attr("class", "bargroup");

        gg.selectAll("rect")
          .data(this.bargroups.get(x))
          .enter()
          .append("rect")
          .style("opacity", 0.8)
          .attr("x", (d) => {

            return xSubgroup(d.b)
          })
          .attr("width", xSubgroup.bandwidth())
          .attr("y", function(d) {
            console.log(`y: ${d.y} | yscl0: ${yScale(0)} | yscly: ${yScale(d.y)}`)

            return (d.y >= 0 ? yScale(d.y) : yScale(0));
          })
          .attr("height", function(d) {
            let retval;
            //if(d.y > 0)

            return Math.abs(yScale(0) - yScale(d.y));
          })
          .attr("fill", (d) => {
            //return that.color(d.b)
            let col = d.b
            if(res.length == 1) {
              if(highlight) {
                col = (/London/.test(d.xd) ? "o" : "x")
              } else {
                col = "o"
              }

            }
            return color(col)
          })
          .on("mouseover", function() {

          })
          .on("mouseout", function() {

          })
          .on("mousemove", function(e, d) {

          });

      })
     }

}
