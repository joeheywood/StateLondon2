// !preview r2d3 data=c(0.3, 0.6, 0.8, 0.95, 0.40, 0.20)
//
// r2d3: https://rstudio.github.io/r2d3
//

function get_labels(y) {

}


function legend_labels(data, marginTop, marginRight, marginBottom, marginLeft, wl, hl) {
  // --- Constructor --- //
  svg.selectAll(".labels").remove()
  /*let marginLeft = 0;
  let marginRight = 81;
  let marginTop = 0;
  let marginBottom = 0*/
  let highlight = true;
  let lgg = {} // a way of renaming legend items?
  let marksize = 5
  forceCols = []

  const random_id = Math.floor(Math.random()*100);
  const gname = `labelsg_${random_id}`

  let labelsg = svg.append("g")
    .classed("labels", true)
    .attr("name", gname);


  lbwidth = 25;
  lbheight = 0;

  let dats = d3.group(data, d => d.b);
  let cats = Array.from(dats.keys());

  let legitems = cats.length + Object.keys(lgg).length
  //self.totwidth = width

  let allowed_width = (wl - marginLeft) / legitems - 10

  // --- Set out colour palettes --- //


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

  let color = d3.scaleOrdinal()
      .domain(cats)
      .range(colpal);

  let tcolor = d3.scaleOrdinal()
      .domain(cats)
      .range(tcolpal);

  let cnodes = [];
  let ix = 0;
  let xx = 0;
  let wdth = 0;
  let xDomain = d3.extent(data, d => d.xd)
  let xRange = [marginLeft, (wl - marginRight)]
  let xScale = d3.scaleUtc(xDomain, xRange);
  let yRange = [(hl - marginTop - marginBottom), marginTop]
  let yext = d3.extent(data, d => d.y)
  let range = yext[1] - yext[0]
  let rangepad = range * .25
  let ymm = (yext[0] >= 0 && yext[0] - range < 0 ? 0 : yext[0] - rangepad)
  let yDomain = [ymm, yext[1] + rangepad];
  let fontsize = "12pt"


  let yScale = d3.scaleLinear(yDomain, yRange);
  // const yAxis = d3.axisLeft(yScale)

  cats.forEach((ct) => {
    let cdat = dats.get(ct)
    let maxy = cdat[d3.maxIndex(cdat, d => d.xd)]

    // This messy little section gets called several times and fixes itself after
    // several calls. So the first if block below is to avoid errors on the first one
    // while the xScale isn't ready yet.
    if (xScale === undefined ) {
      if(lbwdithc === undefined) {
        xx = 0
      } else {
        xx = wl - lbwidth
      }
    } else {
      xx = xScale(maxy.xd)
    }

   let cont = labelsg.append("g")
    .attr("name", `container_${ct}`)

    cont
      .append("circle")
      .attr("fill", color(ct))
      .attr("stroke", d => color(ct))
      .attr("r", marksize)
      .attr("cx", xx)
      .attr("cy", yScale(maxy.y))
      .raise()

     cont
     .append("text")
     .attr("name", `txt_${ct}`)
     .text(`${ct} ??`)
     .attr("x", 125) // why is this 125?
     .attr("y", yScale(maxy.y) + 5)
     .classed("collide", true)
     .style("fill", "#BBBBBB")
     .style("font-size", fontsize)
     .style("font-family", "Arial")

    cnodes.push(
      {
        "index": ix++,
        "x": 10,
        "y": yScale(maxy.y) + 10,
        "vx": 0,
        "vy": 0,
        "text" : ct
      }
    )

    let cbb = cont.node().getBBox()

  })


  var simulation = d3.forceSimulation(cnodes)
    .force('charge', d3.forceManyBody().strength(-1.1))
    .on('tick', ticked);

  let initx = 0;

  function ticked() {

  	labelsg.selectAll(".collide")
  		.data(cnodes)
  		.join('text')
      .text(d => {
        return (d.text === "only" ? "" : d.text)
      })
      .classed("collide", true)
      .attr('x', d => xx + 10)
  		.attr('y', d => d.y)
      .style("fill", d => tcolor(d.text))
      .style("font-size", fontsize)
      .style("font-family", "Arial");
  }


  let maxw = 0;

  labelsg.selectAll(".collide")
  .each(function() {
    let cw = this.getBBox().width
    maxw = (maxw >= cw ? maxw : cw)
  })


  this.lbwidth = maxw;
  this.xx = xx
  this.color = color
  this.tcolor = tcolor
}


