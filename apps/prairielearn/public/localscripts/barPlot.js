function barplot(selector, xdata, ydata, options) {
  options = options || {};
  _.defaults(options, {
    width: 600,
    height: 600,
    topMargin: 10,
    rightMargin: 20,
    bottomMargin: 55,
    leftMargin: 70,
    barWidth: 20,
  });

  var width = options.width - options.leftMargin - options.rightMargin;
  var height = options.height - options.topMargin - options.bottomMargin;

  var x = d3.scaleBand().domain(xdata).range([0, width]).padding(0.1);

  var y = d3
    .scaleLinear()
    .domain([0, d3.max(ydata)])
    .nice()
    .range([height, 0]);

  var xAxis = d3.axisBottom(x);
  var yAxis = d3.axisLeft(y);

  var svg = d3
    .select(selector)
    .append('svg')
    .attr('width', width + options.leftMargin + options.rightMargin)
    .attr('height', height + options.topMargin + options.bottomMargin)
    .attr('class', 'center-block statsPlot')
    .append('g')
    .attr('transform', 'translate(' + options.leftMargin + ',' + options.topMargin + ')');

  // X Axis
  svg
    .append('g')
    .attr('class', 'x axis')
    .attr('transform', 'translate(0,' + height + ')')
    .call(xAxis);

  // X Axis Label
  svg
    .append('text')
    .attr('class', 'x label')
    .attr('text-anchor', 'middle')
    .attr('x', width / 2)
    .attr('y', height + options.bottomMargin - 10)
    .text(options.xlabel);

  // Y Axis
  svg.append('g').attr('class', 'y axis').call(yAxis);

  // Y Axis Label
  svg
    .append('text')
    .attr('class', 'y label')
    .attr('text-anchor', 'middle')
    .attr('x', -height / 2)
    .attr('y', -options.leftMargin + 20)
    .attr('transform', 'rotate(-90)')
    .text(options.ylabel);

  svg
    .selectAll('.bar')
    .data(ydata)
    .enter()
    .append('rect')
    .attr('class', 'bar')
    .attr('x', function (_, i) {
      return x(xdata[i]);
    })
    .attr('width', x.bandwidth())
    .attr('y', function (d) {
      return y(d);
    })
    .attr('height', function (d) {
      return height - y(d);
    });
}
