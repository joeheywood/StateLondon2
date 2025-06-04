// !preview r2d3 data=c(0.3, 0.6, 0.8, 0.95, 0.40, 0.20)
//
// r2d3: https://rstudio.github.io/r2d3
//

function legend(data, margins, wl, hl, highlight){

  // allowed width should be the total length to include the circle, text and any padding or spacing

  svg.selectAll(".legend").remove()
  let self = this
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

  self.dats = d3.group(data, d => d.b);
  let cats = Array.from(self.dats.keys());

  let legitems = cats.length + Object.keys(lgg).length
  //self.totwidth = width

  let allowed_width = (wl - margins.left) / legitems - 10

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
  let xRange = [margins.left, (wl - margins.Right)]

  let yRange = [(hl - margins.top - margins.bottom), margins.top]
  let yext = d3.extent(data, d => d.y)
  let range = yext[1] - yext[0]
  let rangepad = range * .25
  let ymm = (yext[0] >= 0 && yext[0] - range < 0 ? 0 : yext[0] - rangepad)
  let yDomain = [ymm, yext[1] + rangepad];
  let fontsize = "12pt"


  let ypos = 9;
  let xpos = margins.left;
  let conb, cont;
  let maxheight = 0

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //

    function draw_legend_entry(ct, sbnm, txt, clr, dasharray) {
        cont = labelsg.append("g").attr("name", `container_${ct}${sbnm}`)

        if(ct == "only") {
          return ""
        }
      let fsint = parseInt(fontsize)


        cont
        .append("line")
        .attr("stroke", clr)
        .attr("stroke-width", 6)
        .style("stroke-dasharray", (dasharray))
        .style("opacity", 0.6)
        .attr("x1", xpos)
        .attr("x2", (ct == "only" ? xpos : (xpos + 15)))
        .attr("y1", ypos)
        .attr("y2", ypos)

       let ttxt = cont.append("text")
        .attr("name", `txt_${ct}${sbnm}`)
        .text(txt)
        .attr("x", xpos + 20)
        .attr("y", ypos + 5)
        //.style("fill", self.color(ct))
        .style("fill", "#888888")
        .style("font-size", fontsize)
        .style("font-family", "Arial")

        wrap_text(ttxt, allowed_width, fsint, `txt_${ct}${sbnm}`, svg) // wrap to 200?

        // conb = get_bbox(svg, `container_${ct}${sbnm}`)
        conb = ttxt.node().getBBox()
        xpos += conb.width + 25
        cont.attr("transform", `translate(0, ${margins.top})`)
        maxheight = (maxheight < conb.height ? conb.height : maxheight)
      }




    cats.forEach((ct) => {
      let ctxt = ct
      if(lgg !== undefined && ct in lgg) {
        ctxt = lgg[ct]
      }

      if(lgg !== undefined && `solid_${ct}` in lgg) {
        draw_legend_entry(ct, "", lgg[`solid_${ct}`], color(ct), "1, 0")
      } else {
        draw_legend_entry(ct, "", ctxt, color(ct), "1, 0")
      }

      /// If dashed entry in lgg object - add to legend. ///
      if(lgg !== undefined && `dots_${ct}` in lgg) {
        draw_legend_entry(ct, "_dots", lgg[`dots_${ct}`], color(ct), "2, 2")



      }




    })

  /*

    xpos += 5
    if(lgg !== undefined) {

      if(`solid_general` in lgg) {
        draw_legend_entry("general", "_solid", lgg[`solid_general`], "#AAAAAA", "1, 0")

      }

      if(`dots_general` in lgg) {
        draw_legend_entry("general", "_dots", lgg[`dots_general`], "#AAAAAA", "2, 2")

        }

    }



    self.lbheight = get_bbox(svg, gname).height + 40 // adding a bit of padding, otherwise it's a bit too close

  }
    */
    this.lheight = maxheight + 16

  this.color = color
  this.tcolor = tcolor
}


// ARGS:
//  - txt (text object to be tested/change)
//  - maxwidth (max width in pixels)
//  - fsz (font size)
//  - txtnm (name of text object)
//  - svg
// function wrap_text(txt, maxwidth, fsz = 14, txtnm = "", svg = null) {
function wrap_text(txt, maxwidth, fsz , txtnm ,svg, alignment ) {
    if(alignment !== null) {
      alignment = "middle"
    }

    //let ww = t._groups[0][0].getBBox().width;
    //let hh = t._groups[0][0].getBBox().height;
    let word;
    let words = txt.text().split(/\s+/).reverse()
    let xx = txt.text()


    let line = [],
      lineHeight = 1.1, // ems
      y = txt.attr("y"),
      x = txt.attr("x"),
      lineno = 0,
      tspan = txt.text(null)
        .append("tspan")
        .attr("name", `TXT_${xx}`)
        .attr("alignment", alignment)
        .attr("x", x)
        .style("font-size", `${fsz}pt`)
        .attr("y", y)

    // nxtline
    while(word = words.pop()) {
      line.push(word);
      tspan.text(line.join(" "));
      // let bx = get_bbox(svg, `TXT_${xx}`)
      let bx = tspan.node().getBBox()
      let hh = bx.height / (lineno + 1);

      if (bx.width > maxwidth) {
        lineno += 1;
        line.pop();
        tspan.text(line.join(" "));
        line = [word];
        let addy = parseInt(y) + (hh*lineno)
        tspan = txt.append("tspan")
          .attr("x", x)
          .attr("y", addy)
          .style("font-size", `${fsz}pt`)
          .text(word);
        }
      }
      lineno = 0;
}
