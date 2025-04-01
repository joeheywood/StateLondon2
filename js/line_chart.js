


data.forEach(function(d) {
  d.xd = d3.timeParse("%Y-%m-%d")(d.xd)
});


function get_bbox(svg, nm) {
    let ssvg = svg.node();
    document.body.append(ssvg)
    const mbox = ssvg.querySelector(`[name="${nm}"]`).getBBox()
    ssvg.remove()
    return mbox;
  }


let chart_id = 1

// --- X-axis --- //

let xType = d3.scaleUtc
let marginLeft = 17.32
let marginRight = 12

let xg = svg.append("g").classed("xaxis", true)
let xDomain = d3.extent(data, d => d.xd)
let xvals = [...new Set(data.map(d => d3.timeFormat("%Y-%m-%d")(d.xd)))];

let xRange = [marginLeft, (width - marginRight)],
xScale = xType(xDomain, xRange);


let monthx = (xScale(d3.timeParse("%Y-%m-%d")("2022-01-02")) - xScale(d3.timeParse("%Y-%m-%d")("2022-01-01"))) * 15
let yearx = xScale(d3.timeParse("%Y-%m-%d")("2022-01-01")) - xScale(d3.timeParse("%Y-%m-%d")("2021-07-02"))


let xAxis = d3.axisBottom(xScale)
  .tickValues(data.map(d => d.xd))
  .tickSizeOuter(0)
  .tickSizeInner(5)
  .tickFormat(d => (d3.timeFormat("%m")(d) == "01" ? d3.timeFormat("%b")(d) : d3.timeFormat("%b")(d)))


let num_actual_ticks = xScale.ticks().length;

xg.append("g").attr("class", `gridxm_${chart_id}`)
xg.append("g").attr("class", `gridxy_${chart_id}`)

let ggm = xg.append("g")
  .attr("name", `ggm_${chart_id}`)
  .classed("mths", true)
  .call(xAxis);

let prvtickyear = 1066;
let onlyyears = false

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



ggm.selectAll(".mths>.tick line")
  .style("stroke", "#BCBCBC")

ggm.select(".domain").style("stroke", "#888888")

const mbox = ggm.node().getBBox()
const lastyear = d3.timeFormat("%Y")(xDomain[1])
const lastmonth = d3.timeFormat("%m")(xDomain[1])

let xAxisY;


xAxisY = d3.axisBottom(xScale)
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
.style("stroke-width", 4)


ggyt.selectAll(".tick text")
  .attr("transform", `translate(0, ${mbox.height * -1})`)
  .style("font-family", "Arial")
  .style("font-size", "14pt")
  .style("fill", "#ABABAB")
  .style("fill", "#888888")
  .style("stroke-opacity", "0.4")
  .attr('text-anchor', (d) => {
    let yy = d3.timeFormat("%Y")(d)
    let mm = d3.timeFormat("%m")(d)
    return (yy == lastyear ?  (lastmonth > 2 & lastmonth < 9 ? "end" : "start" )  : "start")
  })

ggyt.select(".domain").remove();

// const ybox = get_bbox(svg, "ggy")
const ybox = ggyt.node().getBBox()



lheight = mbox.height + ybox.height
// lwidth = width

ggm.attr("transform", `translate(0, ${height - lheight})`) // missing out margin top here?
//ggy.attr("transform", `translate(0, ${height - lheight})`)
ggyt.attr("transform", `translate(0, ${height - lheight})`)
ggm.raise()






//// Y-Axis ////
let ticks = Math.floor(height/110)
let tickFormat = ".0f"
yFontsize = "11pt"

let marginTop = 0
let marginBottom = lheight

let yext = d3.extent(data, d => d.y)
let range = yext[1] - yext[0]
let rangepad = range * .25
let ymm = (yext[0] >= 0 && yext[0] - range < 0 ? 0 : yext[0] - rangepad)
yDomain = [ymm, yext[1] + rangepad];
yRange = [(height - marginTop - marginBottom), marginTop]

let yg = svg.append("g")
  .classed(`yaxis_${chart_id}`, true)
  .attr("name", `yaxis_${chart_id}`)

yScale = d3.scaleLinear(yDomain, yRange);
range = yRange
const yAxis = d3.axisLeft(yScale)
let yax = yg
  .call(yAxis
  .ticks(ticks)
  .tickSize(-width)
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
  .attr("x2", (width - marginRight) - 5)

txtlft = 0;

yax.selectAll(".tick text")
.each(function(d) {
  console.log(this.getBBox().width)
    });
// console.log(yax.node().getBBox())


yg.select(".domain").remove();
yg.selectAll(".tick line")
  .style("stroke", "#ababab")
  .style("stroke-opacity", 0.4)

/*
*/


//// Constructor ////
let once = 0
let legitems = 0;

const random_id = Math.floor(Math.random()*100);
const gname = `labelsg_${random_id}`



labelsg = contg.append("g")
  .classed("labels", true)
  .attr("name", gname);


let lbwidth = 25;
let lbheight = 0;
let dats = []

dats = d3.group(data, d => d.b);
let cats = Array.from(dats.keys());

  legitems = cats.length + Object.keys(lgg).length
  totwidth = width

  let allowed_width = (width - marginLeft) / legitems - 10


  let colpal = [];
  let tcolpal = []

  const default_cols = ["#6da7de", "#9e0059", "#dee000", "#d82222", "#5ea15d", "#943fa6", "#63c5b5",
                        "#ff38ba", "#eb861e", "#AAAAAA", "#777777"];

  const default_text_cols = ["#6da7de", "#9e0059", "#9aa000", "#d82222", "#5ea15d",  "#943fa6", "#63c5b5",
                        "#ff38ba", "#eb861e", "#AAAAAA", "#777777"];
  const london_high = "#6da7de";
  const other_high = "#AAAAAA";


  if (forceCols === undefined || forceCols.length == 0) {



    let i = 0;



    cats.forEach((ct) => {

      if(highlight & cats.length > 1) {
        const lreg = /London/g;
        let val = (ct.match(lreg) ? "rgb(109, 167, 222)" : "rgb(204, 204, 204)")
        colpal.push(val)
        tcolpal.push(val)
      } else {

        colpal.push(default_cols[i])
        tcolpal.push(default_text_cols[i]);
        i++;

      }

    })


  } else {


    let i = 0;
    // If there are forced colors, assign to the forced colour if it's there, else use default colours
    cats.forEach((ct) => {
      if(forceCols.hasOwnProperty(ct)) {
        colpal.push(forceCols[ct])
        tcolpal.push(forceCols[ct])
      } else {
        colpal.push(default_cols[i])
        tcolpal.push(default_text_cols[i]);
        i++;

      }

    });


  }




// ##### //







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
.attr("stroke-opacity", 0.65)
.attr('stroke', d => color(d[0]))
.attr("d", d => {
  return d3.line()
  .defined((d, i) => { return !isNaN(d.y)})
  // .curve(d3.curveMonotoneX)
  .x(d => xScale(d.xd))
  .y(d => yScale(d.y))
  (d[1]);
})

/*dashg
.selectAll("path")
.data(dashdats)
// .transition(this.t)
.join("path")
.attr('fill', 'none')
.attr('stroke-width', 8)
//.attr("stroke-opacity", 0.65)
.style("stroke-dasharray", ("5, 5"))
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

if(include_markers.length > 0) {
  .markg
  .attr("stroke-width", 1)
  .selectAll("circle")
  .data(data)
  .join("circle")
  .attr("cx", d => xScale(d.xd))
  .attr("cy", d => yScale(d.y))
  .attr("r", d => (include_markers.includes(d.b)  || include_markers == "all_categories" ? 8 : 0))
  .attr("fill", d => color(d.b))

}

*/
