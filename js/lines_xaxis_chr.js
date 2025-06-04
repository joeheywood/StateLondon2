// !preview r2d3 data=dat, dependencies=c("js/yaxis.js", "js/labels.js", "js/lines_qtr.js", "js/lines.js")
//
// r2d3: https://rstudio.github.io/r2d3
//

function run_xaxis_chr(data, marginTop, marginRight, marginBottom, marginLeft, add_silent, xdw, xdh) {
  let nolabels = false
  let showXgrid = true
  // let numticks =  Math.floor(width / 170)
  let numticks =  5
  svg.selectAll(".xaxis").remove()
  const chart_id = Math.floor(Math.random()*1000); // do we still need this?

  let yearx = 0;
  let lheight = 0

  let ss = new Set(data.map(d => d3.timeFormat("%Y-%m-%d")(d.xd)))
  let slb = new Set(data.map(d => d.timeperiod_label))

  // set for all labels here?

  // some kind of lookup object between the two?
  let onlyyears = true


  let xvals = [...new Set(data.map(d => d3.timeFormat("%Y-%m-%d")(d.xd)))];
  let numvals = xvals.length


  let xDomain = d3.extent(data, d => d.xd)
  let xRange = [marginLeft, (xdw - marginRight)]
  let xg = svg.append("g").classed("xaxis", true)

  let xScale = d3.scaleUtc(xDomain, xRange);

  monthx = (xScale(d3.timeParse("%Y-%m-%d")("2022-01-02")) - xScale(d3.timeParse("%Y-%m-%d")("2022-01-01"))) * 15
  yearx = xScale(d3.timeParse("%Y-%m-%d")("2022-01-01")) - xScale(d3.timeParse("%Y-%m-%d")("2021-07-02"))
  // let xAxis;

  const lastyear = d3.timeFormat("%Y")(xDomain[1])
  const lastmonth = d3.timeFormat("%m")(xDomain[1])

    let xAxisY;

    if(nolabels) {

      xAxisY = d3.axisBottom(xScale).tickValues([])

    } else {
      xAxisY = d3.axisBottom(xScale)
        .ticks( d3.timeMonth.every(1), "%Y")
        //.tickSize(mbox.height * 2)
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
      .tickFormat((d) => {
        let yrstring = d3.timeFormat("%Y")(d)
        let mm = d3.timeFormat("%m")(d)
        let yy = d3.timeFormat("%y")(d)
        let last = yy == lastyear && mm == lastmonth && mm > 2

        let retval = (onlyyears ? "" : (mm == "06" || (last == true && mm < "06") ? yrstring : ""))

        return retval
      })


    if(showXgrid) {

      let gridm = xg.selectAll(`.gridxm_${chart_id}`)
        .call(d3.axisBottom(xScale)
          .ticks(numticks)
          //.ticks(5)
          .tickSize(xdh - lheight - marginTop)
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

      let gridy = xg.selectAll(`.gridxy_${chart_id}`)
        .call(d3.axisBottom(xScale)
          .ticks(d3.timeYear.every(1), "%Y")
          .tickSize(xdh - lheight - marginTop)
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
    } // end if show grid ??

    let xAxis

    if(nolabels) {
      xAxis = d3.axisBottom(xScale)
        .tickValues([])
        .tickSizeOuter(0)
      .tickSizeInner(5)
    } else {
      xAxis = d3.axisBottom(xScale)
      .ticks(numticks)
      .tickSizeOuter(0)
      .tickSizeInner(5)
    }


    let ggjy = xg.append("g")
      .attr("name", "ggjy")
      .classed("justyears", true)
      .call(xAxis);
    // ggjy.attr("transform", `translate(0, ${xdh - mbox.height})`)

    ggjy.selectAll(".tick line")
      .style("stroke", "#BCBCBC")

    ggjy.selectAll(".tick text")
    .style("font-family", "Arial")
    .style("font-size", "10pt")
    .style("fill", "#ABABAB")
    .style("fill", "#555555")
    .style("stroke-opacity", "0.4")

    ggjy.select(".domain").style("stroke", "#888888")

  this.height = lheight
  this.xScale = xScale
}



/*  data.forEach(function(d){
    console.log(`${d.timeperiod_label}`)
    let parseTime = d3.timeParse("%Y-%m-%d");
    d.xd = parseTime(d.xd)
  })

// let rr = new run_xaxis_chr(data, 0, 0, 0, 0, false, width, height)

*/
