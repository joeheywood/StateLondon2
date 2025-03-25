// !preview r2d3 data=c(0.3, 0.6, 0.8, 0.95, 0.40, 0.20)
//
// r2d3: https://rstudio.github.io/r2d3
//

/*var barHeight = Math.ceil(height / data.length);

svg.selectAll('rect')
  .data(data)
  .enter().append('rect')
    .attr('width', function(d) { return d * width; })
    .attr('height', barHeight)
    .attr('y', function(d, i) { return i * barHeight; })
    .attr('fill', 'steelblue');
*/


// self.xScale = xType(xDomain, xRange).nice();

function get_bbox(svg, nm) {
    let ssvg = svg.node();
    document.body.append(ssvg)
    const mbox = ssvg.querySelector(`[name="${nm}"]`).getBBox()
    ssvg.remove()
    return mbox;
  }


let chart_id = 1
let xType = d3.scaleUtc
let marginLeft = 12
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

/*let prvtickyear = 1066;
// let onlyyears = true;

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


let ticktext = ggm.selectAll(".tick text")
  .style("font-family", "Arial")
  .style("font-size", "11pt")
  .style("fill", "#888888")
  .text(d => d3.timeFormat("%Y")(d))


ggm.selectAll(".mths>.tick line")
  .style("stroke", "#BCBCBC")

ggm.select(".domain").style("stroke", "#888888")

const mbox = get_bbox(svg, `ggm_${chart_id}`)

const lastyear = d3.timeFormat("%Y")(xDomain[1])
const lastmonth = d3.timeFormat("%m")(xDomain[1])

let xAxisY;


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
const ybox = get_bbox(svg, "ggy")



lheight = mbox.height + ybox.height
lwidth = width

ggm.attr("transform", `translate(0, ${height - lheight})`) // missing out margin top here?
//ggy.attr("transform", `translate(0, ${height - lheight})`)
ggyt.attr("transform", `translate(0, ${height - lheight})`)
ggm.raise()


*/
