// !preview r2d3 data=dat, dependencies=c("js/yaxis.js", "js/labels.js", "js/lines_qtr.js", "js/lines.js")
//
// r2d3: https://rstudio.github.io/r2d3
//

function run_xaxis_dt(data, marginTop, marginRight, marginBottom, marginLeft, add_silent, xx, yx) {
  let nolabels = false;
  let showXgrid = true
  let numticks =  Math.floor(width / 170)
  svg.selectAll(".xaxis").remove()
  const chart_id = Math.floor(Math.random()*1000); // do we still need this?

  let yearx = 0;
  let ss = new Set(data.map(d => d3.timeFormat("%Y-%m-%d")(d.xd)))

  let xvals = [...new Set(data.map(d => d3.timeFormat("%Y-%m-%d")(d.xd)))];
  let numvals = xvals.length


  // marginLeft = marginLeft
  let xDomain = d3.extent(data, d => d.xd)
  let xRange = [marginLeft, (xx - marginRight)]
  let xg = svg.append("g").classed("xaxis", true)



  let xScale = d3.scaleUtc(xDomain, xRange);

  monthx = (xScale(d3.timeParse("%Y-%m-%d")("2022-01-02")) - xScale(d3.timeParse("%Y-%m-%d")("2022-01-01"))) * 15
  yearx = xScale(d3.timeParse("%Y-%m-%d")("2022-01-01")) - xScale(d3.timeParse("%Y-%m-%d")("2021-07-02"))
  let xAxis;



    xAxis = d3.axisBottom(xScale)
    .tickValues(data.map(d => d.xd))
    .tickSizeOuter(0)
    .tickSizeInner(5)
    .tickFormat(d => (d3.timeFormat("%m")(d) == "01" ? d3.timeFormat("%b")(d) : d3.timeFormat("%b")(d)))




    num_actual_ticks = xScale.ticks().length;

    xg.append("g").attr("class", `gridxm_${chart_id}`)
    xg.append("g").attr("class", `gridxy_${chart_id}`)

    let ggm = xg.append("g")
      .attr("name", `ggm_${chart_id}`)
      .classed("mths", true)
      .call(xAxis);

    let prvtickyear = 1066;
    let onlyyears = true;

    ggm.selectAll(".tick text")
      .attr("name", (d) => {

        let yr = +d3.timeFormat("%Y")(d)
        let mth = +d3.timeFormat("%m")(d)

        if(mth > 1 | yr <= prvtickyear) {
          onlyyears = false
        }
        prvtickyear = yr;
        return "a"
      })

    if(onlyyears) numticks = 5


    if(monthx < 12) {
      onlyyears = true
    }

    let ticktext = ggm.selectAll(".tick text")
      .style("font-family", "Arial")
      .style("font-size", "10pt")
      .style("fill", "#888888")
      .text(d => (onlyyears == true ? d3.timeFormat("%Y")(d) : d3.timeFormat("%b")(d)))
      .attr("transform", d => (onlyyears ? `translate(${yearx}, 0)` : `translate(0,0)`))


    ggm.selectAll(".mths>.tick line")
      .style("stroke", "#BCBCBC")

    ggm.select(".domain").style("stroke", "#555555")

    // const mbox = get_bbox(svg, `ggm_${chart_id}`)
    const mbox = ggm.node().getBBox()

    const lastyear = d3.timeFormat("%Y")(xDomain[1])
    const lastmonth = d3.timeFormat("%m")(xDomain[1])

    let xAxisY;

    if(nolabels) {

      xAxisY = d3.axisBottom(self.xScale).tickValues([])

    } else {
      xAxisY = d3.axisBottom(self.xScale)
        .ticks( d3.timeMonth.every(1), "%Y")
        .tickSize(mbox.height * 2)
        .tickFormat((d) => {
        let yy = d3.timeFormat("%Y")(d)
        let mm = d3.timeFormat("%m")(d)
        let labpos = (yy == lastyear ?
                        (lastmonth > 2 & lastmonth < 6 ? `0${lastmonth}` : "06" ) :
                        "06")
        return (mm == labpos ? d3.timeFormat("%Y")(d) : "")
      })

    }



    const xAxisYtick = d3.axisBottom(xScale)
      .ticks(d3.timeMonth.every(1), "%m")
      .tickSizeOuter(0)
      //.tickSizeInner(d => d3.timeFormat("%m")(d) == 1 ? (mbox.height * 2) : 0)
      .tickSizeInner( (mbox.height * 2))
      .tickFormat((d) => {

        let yrstring = d3.timeFormat("%Y")(d)
        let mm = d3.timeFormat("%m")(d)
        let yy = d3.timeFormat("%y")(d)
        let last = yy == lastyear && mm == lastmonth && mm > 2

        let retval = (onlyyears ? "" : (mm == "06" || (last == true && mm < "06") ? yrstring : ""))

        return retval
      })

    let ggyt = xg.append("g")
      .attr("name", "ggy")
      .classed("yrstick", true)
      .call(xAxisYtick);

    ggyt.selectAll(".tick line")
      .style("stroke", "#BCBCBC")
      .style("opacity", (d) => {
        return (d3.timeFormat("%m")(d) == "01" ? 0.7 : 0)
      })
      .attr("transform", `translate(${-monthx}, 0)`)
      .style("stroke-width", (onlyyears ? 2 : 4))


    ggyt.selectAll(".tick text")
      .attr("transform", `translate(0, ${mbox.height * -1})`)
      .style("font-family", "Arial")
      .style("font-size", "12pt")
      .style("fill", "#ABABAB")
      // .style("fill", textCol)
      .style("stroke-opacity", "0.4")
      .attr('text-anchor', (d) => {
        let yy = d3.timeFormat("%Y")(d)
        let mm = d3.timeFormat("%m")(d)
        return (yy == lastyear ?  (lastmonth > 2 & lastmonth < 9 ? "end" : "start" )  : "start")
      })

    ggyt.select(".domain").remove();

    // const ybox = get_bbox(svg, "ggy")
    const ybox = ggyt.node().getBBox()



    let lheight = (onlyyears ? mbox.height : mbox.height + ybox.height)
    let lwidth = width

    ggm.attr("transform", `translate(0, ${height - lheight})`) // missing out margin top here?
    ggyt.attr("transform", `translate(0, ${height - lheight})`)
    ggm.raise()


    if(showXgrid) {

      let gridm = xg.selectAll(`.gridxm_${chart_id}`)
        .call(d3.axisBottom(xScale)
          .ticks(numticks)
          //.ticks(5)
          .tickSize(height - lheight - marginTop)
          .tickFormat("")
      )
      .attr("transform", `translate(0, ${marginTop})`)

      xg.select(`.gridxm_${chart_id} .domain`).remove();

      xg.selectAll(`.gridxm_${chart_id} line`)
        .style("stroke", "#BCBCBC")
        .style("stroke-opacity", "0.4")
        .style("stroke-width", (d) => {
          let mm = d3.timeFormat("%m")(d)
          let thck = (onlyyears ? 2 : 4)
          return 0.5
        })
        .style("shape-rendering", "crispEdges")

      //if(!onlyyears) {
      let gridy = xg.selectAll(`.gridxy_${chart_id}`)
        .call(d3.axisBottom(xScale)
          .ticks(d3.timeYear.every(1), "%Y")
          .tickSize(height - lheight - marginTop)
          .tickFormat("")
        )
      .attr("transform", `translate(0, ${marginTop})`)

      xg.select(`.gridxy_${chart_id} .domain`).remove();

      let mvgrid = (onlyyears ? 0 : -monthx)

      xg.selectAll(`.gridxy_${chart_id} line`)
        .style("stroke", "#BCBCBC")
        .style("stroke-opacity", "0.4")
        .style("stroke-width", d => (onlyyears ? 2 : 4))
        .style("shape-rendering", "crispEdges")
        .attr("transform", `translate(${mvgrid}, 0)`)

      //}


    }
    if(onlyyears) {
      ggm.remove()
      //ggy.remove()
      ggyt.remove()
      let xAxis
      if(nolabels) {
        xAxis = d3.axisBottom(xScale)
          .tickValues([])
          .tickSizeOuter(0)
        .tickSizeInner(5)

      } else {
        xAxis = d3.axisBottom(xScale)
        .ticks(numticks)
        //.ticks(5)
        .tickSizeOuter(0)
        .tickSizeInner(5)
        //.tickFormat(d => (d3.timeFormat("%Y")(d)))

      }


      let ggjy = xg.append("g")
        .attr("name", "ggjy")
        .classed("justyears", true)
        .call(xAxis);
      ggjy.attr("transform", `translate(0, ${height - mbox.height})`)

      ggjy.selectAll(".tick line")
        .style("stroke", "#BCBCBC")

      ggjy.selectAll(".tick text")
      .style("font-family", "Arial")
      .style("font-size", "10pt")
      .style("fill", "#ABABAB")
      .style("fill", "#555555")
      .style("stroke-opacity", "0.4")

      ggjy.select(".domain").style("stroke", "#888888")

    }

    this.height = lheight
    this.xScale = xScale
}


/*

/
  data.forEach(function(d){
    let parseTime = d3.timeParse("%Y-%m-%d");
    d.xd = parseTime(d.xd)
  })

run_xaxis_dt(data, 0, 0, 0, 0, false, width, height)

*/
