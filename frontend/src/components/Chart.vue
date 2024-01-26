<template>
  <section class="chart">
    <canvas class="chart-canvas" />
  </section>
</template>

<script>
import Chart from 'chart.js/auto';

const DEFAULT_DONUT = {
  type: 'doughnut',
  data: {},
  options: {
    responsive: true,
    cutout: '70%',
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        backgroundColor: '#fff',
        borderColor: '#ddd',
        borderWidth: 1,
        titleColor: '#666',
        bodyColor: '#666',
        bodyFont: {
          size: 15,
        },
        bodySpacing: 10,
        padding: 10,
      },
    },
  },
};

const DEFAULT_LINE = {
  type: 'line',
  data: {},
  options: {
    responsive: true,
    lineTension: 0.5,
    maintainAspectRatio: false,
    interaction: {
      intersect: false,
      axis: 'index',
    },
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        backgroundColor: '#fff',
        borderColor: '#ddd',
        borderWidth: 1,
        bodyColor: '#666',
        displayColors: true,
        bodyFont: {
          size: 15,
        },
        bodySpacing: 10,
        padding: 10,
      },
    },
    scales: {
      x: {
        grid: {
          display: false,
        },
      },
      y: {
        grid: {
          display: false,
        },
        ticks: {
          precision: 0,
        },
      },
    },
  },
};

const DEFAULT_BAR = {
  type: 'bar',
  data: {},
  options: {
    responsive: true,
    indexAxis: 'y',
    barThickness: 40,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        backgroundColor: '#fff',
        borderColor: '#ddd',
        borderWidth: 1,
        titleColor: '#666',
        bodyColor: '#666',
        bodyFont: {
          size: 15,
        },
        bodySpacing: 10,
        padding: 10,
      },
    },
    scales: {
      x: {
        grid: {
          display: false,
        },
      },
      y: {
        grid: {
          display: false,
        },
      },
    },
  },
};

const getOrCreateLegendList = (chart, id) => {
  const legendContainer = document.getElementById(id);
  let listContainer = legendContainer.querySelector('ul');

  if (!listContainer) {
    listContainer = document.createElement('ul');
    listContainer.style.display = 'flex';
    listContainer.style.flexDirection = 'row';
    listContainer.style.margin = 0;
    listContainer.style.padding = 0;

    legendContainer.appendChild(listContainer);
  }

  return listContainer;
};

const htmlLegendPlugin = {
  id: 'htmlLegend',
  afterUpdate(chart, args, options) {
    const ul = getOrCreateLegendList(chart, options.containerID);

    // Remove old legend items
    while (ul.firstChild) {
      ul.firstChild.remove();
    }

    // Reuse the built-in legendItems generator
    const items = chart.options.plugins.legend.labels.generateLabels(chart);

    items.forEach((item) => {
      const li = document.createElement('li');
      li.style.alignItems = 'center';
      li.style.cursor = 'pointer';
      li.style.display = 'flex';
      li.style.flexDirection = 'row';
      li.style.marginLeft = '10px';

      li.onclick = () => {
        const { type } = chart.config;
        if (type === 'pie' || type === 'doughnut') {
          // Pie and doughnut charts only have a single dataset and visibility is per item
          chart.toggleDataVisibility(item.index);
        } else {
          chart.setDatasetVisibility(item.datasetIndex, !chart.isDatasetVisible(item.datasetIndex));
        }
        chart.update();
      };

      // Color box
      const boxSpan = document.createElement('span');
      boxSpan.style.background = item.fillStyle;
      boxSpan.style.borderColor = item.strokeStyle;
      boxSpan.style.borderWidth = `${item.lineWidth}px`;
      boxSpan.style.display = 'inline-block';
      boxSpan.style.flexShrink = 0;
      boxSpan.style.height = '20px';
      boxSpan.style.marginRight = '10px';
      boxSpan.style.width = '20px';

      // Text
      const textContainer = document.createElement('p');
      textContainer.style.color = item.fontColor;
      textContainer.style.margin = 0;
      textContainer.style.padding = 0;
      textContainer.style.textDecoration = item.hidden ? 'line-through' : '';
      const text = document.createTextNode(`${item.text} (${chart.data.datasets[0].data[item.index]})`);
      textContainer.appendChild(text);

      li.appendChild(boxSpan);
      li.appendChild(textContainer);
      ul.appendChild(li);
    });
  },
};

const DEFAULT_PIE = {
  type: 'pie',
  data: {},
  options: {
    responsive: true,
    plugins: {
      htmlLegend: {
        containerID: 'legend-container',
      },
      legend: {
        display: false,
        position: 'right',
        align: 'left',
      },
    },
  },
  plugins: [htmlLegendPlugin],
};

export default {
  name: 'Chart',

  props: {
    data: { type: Object, default: () => { } },
    type: { type: String, default: 'line' },
    onClick: { type: Function, default: () => { } },
    legendContainer: { type: String, default: 'legend-container' },
  },

  data() {
    return {
      chart: null,
    };
  },

  watch: {
    data(newData) {
      if (newData) {
        this.chart.data = newData;
        this.chart.update('none');
      }
    },
  },

  mounted() {
    const ctx = this.$el.querySelector('.chart-canvas');

    let def = {};
    switch (this.$props.type) {
      case 'donut':
        def = DEFAULT_DONUT;
        break;
      case 'bar':
        def = DEFAULT_BAR;
        break;
      case 'pie':
        def = DEFAULT_PIE;
        def.options.plugins.htmlLegend.containerID = this.$props.legendContainer;
        break;
      default:
        def = DEFAULT_LINE;
        break;
    }

    const conf = { ...def, data: this.$props.data };
    if (this.$props.onClick) {
      conf.options.onClick = this.$props.onClick;
    }
    this.chart = new Chart(ctx, conf);
  },

};
</script>
