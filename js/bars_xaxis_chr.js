// !preview r2d3 data=dat, dependencies=c("js/yaxis.js", "js/legend.js", "js/lines_dt.js", "js/bars.js", "js/xaxis_char.js"), options=list(yfmt = ".0%", stackgroup = "group", high = FALSE)
//
//

let dd1;

let high = true;

function long_to_wide(data) {
  // From here: https://observablehq.com/@caocscar/data-wrangling-in-javascript

  return Array.from(
    d3.rollup(data, v => d3.sum(v, d => d.y), d => d.xd, d => d.b), ([key,value]) => {
      let row = {};
      row['xd'] = key;
      const categories = new Set(data.map(d => d.b));
      categories.forEach(d => { row[d] = value.has(d) ? value.get(d) : 0 });
      return row;
    })

}




r2d3.onRender(function(data, svg, width, height, options){

  console.log(`w: ${width} h: ${height}`)

  if(data.length == 0) {
    return false
  }
  let wd

  if(options.stackgroup == "stack") {
    let allmax = 0
    wd = long_to_wide(data)
    let row_id = 1
    wd.forEach((d) => {
      //d.dtid = row_id;
      let temp = JSON.parse(JSON.stringify(d)) ;

      let ctgs = Object.keys(temp)
      let a = ctgs.shift() // this removes the xd vrb that we don't need
      //let b = ctgs.pop()
      // a should be xd and b should dtid
      //console.log(`a: ${a} | b: ${b}`)
      self.datacols = ctgs
      let rowmax = 0;
      self.datacols.forEach((ctg) => {
        //console.log(`xd: ${temp.xd} ctg: ${ctg} val: ${+temp[ctg]}`)

        temp[ctg] = +temp[ctg]
        rowmax += temp[ctg]
      })
      allmax = (allmax > rowmax ? allmax : rowmax)
      row_id++;
    })

    options.yforce = [0, (allmax*1.1)]
    // console.log(allmax)

  } else {
    wd = data
  }


  high = options.high

  let yax = new yaxis(data, 0, 0, 0, 0, width, height, options.yfmt, options)
  let ll = new legend(data, {top: 0, right: 0, bottom: 0, left:yax.lbwidth}, width, height, high, yax.yScale)
  let xx = new x_axis_lines_char(data, {top: ll.lheight, right: 0, bottom: 0, left:yax.lbwidth}, width, height, {bar:true})

  yax = new yaxis(data, ll.lheight, 0, 0, 0, width, height, options.yfmt, options)

  let brs = new bars(wd, ll.color, xx.xScale, yax.yScale, options)
  dd1 = wd
})

r2d3.onResize(function(width, height){
  console.log(`w: ${width} h: ${height}`)
  svg.selectAll("*").remove()
  let yax = new yaxis(dd1, 0, 0, 0, 0, width, height, options.yfmt, options)
  let ll = new legend(dd1, {top: 0, right: 0, bottom: 0, left:0}, width, height, high, yax.yScale)
  let xx = new x_axis_lines_char(dd1, {top: ll.lheight, right: 0, bottom: 0, left:yax.lbwidth}, width, height, {bar:true})

  yax = new yaxis(dd1, ll.lheight, 0, 0, 0, width, height, options.yfmt, options)

  let brs = new bars(dd1, ll.color, xx.xScale, yax.yScale, options)
})
