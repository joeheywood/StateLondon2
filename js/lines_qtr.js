// !preview r2d3 data=dat, dependencies=c("js/yaxis.js", "js/labels.js", "js/lines_qtr.js", "js/lines.js")
//
// r2d3: https://rstudio.github.io/r2d3
//




function run_xaxis_qtr2(data, marginTop, marginRight, marginBottom, marginLeft, add_silent, xx, yx) {
  svg.selectAll(".xaxis").remove()
  let nolabels = false
  let xDomain = d3.extent(data, d => d.xd)
  let xRange = [marginLeft, (xx - marginRight)]
  const random_id = Math.floor(Math.random()*1000); // do we still need this?
  const gname = `labelsg_${random_id}`
  let xg = svg.append("g").classed("xaxis", true).attr("name", gname)
  let lheight = 0



  //// Draw ////
  let ggql, ggq, tVal, lVal, qheight = 0;

  xg.selectAll("*").remove()

  let xScale = d3.scaleUtc(xDomain, xRange);


  let t1Y = +d3.timeFormat("%Y")(xDomain[0])
  let wdth = xScale(d3.timeParse("%Y-%m-%d")(`${t1Y}-04-01`)) - xScale(d3.timeParse("%Y-%m-%d")(`${t1Y}-01-01`))

  xg.append("g").attr("class", "gridxq")
  if(wdth > 30) {
    const tickVals = ["01-01", "04-01", "07-01", "09-30"]
    const labelVals = ["02-15", "05-17", "08-16", "11-16"]
    tVal = []
    lVal = []

    for(let y = +d3.timeFormat("%Y")(xDomain[0]); +y <= d3.timeFormat("%Y")(xDomain[1]); y++ ) {
      for(let i = 0; i < labelVals.length; i++) {
        let tckdate = d3.timeParse("%Y-%m-%d")(`${y}-${tickVals[i]}`);
        let labdate = d3.timeParse("%Y-%m-%d")(`${y}-${labelVals[i]}`);

        if(labdate >= xDomain[0] && tckdate <= xDomain[1]) {
          if(tckdate < xDomain[0]) xDomain[0] = tckdate
          if(labdate > xDomain[1]) xDomain[1] = labdate
          tVal.push(tckdate);
          lVal.push(labdate)
        }
      }
    }

    let xAxisQt;

    xAxisQt = d3.axisBottom(xScale)
      .tickValues(tVal)
      .tickSizeOuter(0)
      .tickSizeInner(10)
      .tickFormat("")




    ggq = xg.append("g")
      .attr("name", "ggq")
      .classed("qtrs", true)
      .call(xAxisQt);

    ggq.selectAll(".tick line")
      .attr("y2", (d, i) => {
        let md = +d3.timeFormat("%m-%d")(d)
        return (md == "01-01" ? 18 : 8)
      })
      .style("stroke", "#BCBCBC")


    let xAxisQl

    if(nolabels) {

      xAxisQl = d3.axisBottom(xScale).tickValues([])
    } else {
      xAxisQl = d3.axisBottom(xScale)
        .tickValues(lVal)
        .tickSize(0)
        .tickFormat((d) => {

          let mm = (+d3.timeFormat("%m")(d)+1)/3
          return `Q${mm}`
        })


    }

    ggql = xg.append("g")
      .attr("name", `ggql_${random_id}`)
      .classed("qtrsl", true)
      .call(xAxisQl);



    ggql.selectAll(".tick text")
      .style("font-family", "Arial")
      .style("font-size", "11pt")
      .style("fill", "#ABABAB")

    ggq.selectAll(".qtrs>.tick line")
      .style("stroke", "#BCBCBC")

    ggq.select(".domain").style("stroke", "#888888")
    ggql.select(".domain").remove();
    //const qbox = get_bbox(svg, `ggql_${random_id}`)
    const qbox = ggql.node().getBBox()
    qheight = qbox.height
  }

  const lastyear = d3.timeFormat("%Y")(xDomain[1])
  const lastmonth = d3.timeFormat("%m")(xDomain[1])

  let xAxisY, xAxisY2, xAxisY3;


  xAxisY = d3.axisBottom(xScale)
    .ticks(d3.timeMonth.every(1), "%Y")
    .tickSize(qheight * 2)
    .tickFormat((d) => {

      let yy = d3.timeFormat("%Y")(d)
      let mm = d3.timeFormat("%m")(d)
      let labpos = (yy == lastyear ?
                    (lastmonth > 2 & lastmonth < 6 ? `0${lastmonth}` : "06" ) :
                    "06")
      return (mm == labpos ? d3.timeFormat("%Y")(d) : "")
    })

  let t1 = data[0].xd
  let tlast = data[data.length-1].xd
  let m1 = +d3.timeFormat("%m")(t1)
  let mlast =  +d3.timeFormat("%m")(tlast)
  let y1 = d3.timeFormat("%Y")(t1)
  let ylast = d3.timeFormat("%Y")(tlast)

  xAxisY2 = d3.axisBottom(xScale)
    .ticks(d3.timeYear.every(1), "%Y")
    .tickSizeInner(qheight * 2)
    .tickSizeOuter(0)
    .tickFormat((d) => {

      let yrstring = d3.timeFormat("%Y")(d)
      let mm = d3.timeFormat("%m")(d)

      return (yrstring == ylast && mlast < 4 ? "" : yrstring)
    })




let ggy3
  if(m1 < 10) {
    let xt1 = d3.timeParse("%Y-%m-%d")(`${y1}-${(m1 <= 7 ? "07" : m1)}-02`)
    xAxisY3 = d3.axisBottom(xScale)
      .tickValues([xt1])
      .tickFormat(d => d3.timeFormat("%Y")(d))
      .tickSize(qheight * 2)

    ggy3 = xg.append("g")
      .attr("name", `ggxyrs3_${random_id}`)
      .classed("yrs", true)
      .call(xAxisY3);

    ggy3.selectAll(".tick line")
      .style("opacity", 0)
    ggy3.selectAll(".tick text")
      .attr("transform", (d) => {
        return `translate(0, ${qheight * -1})`
      })
      .style("font-family", "Arial")
      .style("font-size", (wdth < 30 ? "11pt" : "14pt"))
      .style("fill", "#ABABAB")
      .style("stroke-opacity", "0.4")
      .attr('text-anchor', "middle")
    ggy3.select(".domain").remove();
  }


  let w6m = xScale(d3.timeParse("%Y-%m-%d")(`${t1Y}-07-02`)) - xScale(d3.timeParse("%Y-%m-%d")(`${t1Y}-01-01`))

  let ggy2 = xg.append("g")
    .attr("name", `ggxyrs2_${random_id}`)
    .classed("yrs", true)
    .call(xAxisY2)


  ggy2.selectAll(".tick text")
    .attr("transform", (d) => {
      let pos1 = xScale(d)
      let rmax = xScale.range()[1]
      let mv = ((pos1 + w6m) < rmax ? w6m : rmax - pos1)
      return `translate(${mv }, ${qheight * -1})`
  })
  .style("font-family", "Arial")
  .style("font-size", (wdth < 30 ? "11pt" : "14pt"))
  .style("fill", "#ABABAB")
  .style("stroke-opacity", (d) => {
    return "0.4"
  })

  .attr('text-anchor', (d) => {
    let pos1 = xScale(d)
    let rmax = xScale.range()[1]
    return ((pos1 + w6m) < rmax ? "middle": "end")
  })

  ggy2.selectAll(".tick line")
    .style("stroke", "#BCBCBC")
    .style("stroke-width", d =>  (wdth > 30 ? 4 : 1) )


  //ggy2.select(".domain").remove();

  // const ybox = get_bbox(svg, `ggxyrs2_${random_id}`)
  const ybox = ggy2.node().getBBox()

  // const xaxbox = get_bbox(svg, gname)
  lheight = qheight + ybox.height


  //ggy.attr("transform", `translate(0, ${height - lheight})`)
  ggy2.attr("transform", `translate(0, ${yx - lheight})`)
  if(m1 < 10) {  ggy3.attr("transform", `translate(0, ${yx - lheight})`) }

  if(wdth > 30) {

    ggql.attr("transform", `translate(0, ${yx - lheight})`)
    ggq.attr("transform", `translate(0, ${yx - lheight})`)


    let gridq = xg.selectAll(".gridxq")
      .call(d3.axisBottom(xScale)
            .tickValues(tVal)
            .tickSizeInner(yx - lheight - marginTop)
            .tickSizeOuter(0)
            .tickFormat("")
           )
      .attr("transform", `translate(0, ${marginTop})`);
  } else {
    let gridq = xg.selectAll(".gridxq")
      .call(d3.axisBottom(xScale)
            .ticks(d3.timeYear.every(1), "%Y")
            .tickSizeInner(yx - lheight - marginTop)
            .tickSizeOuter(0)
            .tickFormat("")
           )
      .attr("transform", `translate(0, ${marginTop})`);

  }


  xg.select(".gridxq .domain").remove();

  xg.selectAll(".gridxq line")
    .style("stroke", "#BCBCBC")
    .style("stroke-opacity", "0.4")
    .style("stroke-width", (d) => {
      let mm = d3.timeFormat("%m")(d)
      let ww;
      if(wdth < 30){
        return 2;
      } else {
        return (mm == 1 && wdth > 30 ? 4 : 0.5)
      }

    })
    .style("shape-rendering", "crispEdges")

    //return(this)
    this.height = lheight
    this.xScale = xScale


}


//let xx = new run_xaxis_qtr2(data, 0, 0, 0, 0, false)
/*
r2d3.onRender(function(data, svg, width, height, options){
  if(data.length == 0) {
    return false
  }
  data.forEach(function(d){
    let parseTime = d3.timeParse("%Y-%m-%d");
    d.xd = parseTime(d.xd)
  })
  let xx = new run_xaxis_qtr2(data, 0, 84, 0, 85, false)



})

*/
