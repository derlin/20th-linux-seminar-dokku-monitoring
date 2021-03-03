# Grafana Demo notes

## Setup

Login to grafana for the first time, and change your username/password (default: `admin/admin`).

## Import dashboards

To import dashboards, click on "+" > *Import*.

1. Import *Spring Boot 2.1 Statistics* using the grafana-labs URL https://grafana.com/grafana/dashboards/10280
   You may have to edit the dashboard's global variables: on the dashboard, click on the gear icon on the top-right,
   go to *Variables* and edit the query used for *instance* to `label_values(up{instance=~".*bbapi.*"}, instance)`
2. Import Cassandra dashboard using the file in `graf/cassandra-dashboard.json`


## Demo time

Create a new dashboard by clicking on "+" > *Dashboard*.

**Gauge**

Let's say we want to know the cpu usage at the current time. Create a new panel and:
- set the query to `system_cpu_usage`
- set the query type to *instant*
- change the visualisation to *Gauge*
- in the *Field* tab, set the unit to *Percent 0-1* and edit the thresholds
- add a title

**Graph**

Let's say we are interested in the number of HTTP requests.

In a new panel, let's first see what the raw metric gives us:
- set the query to `http_server_requests_seconds_count`

We see we have two dimensions, and that the counter is always increasing.

To better visualize what is going on, let's first graph the number of HTTP requests per second, and use the `sum`
to aggregate all dimensions:
- set the query to `sum(rate(http_server_requests_seconds_count[1m]))`

We see the lines are a bit bumpy. This is because by default grafana computes the step size, and it is less
than our range query (15s vs 1m). Let's change that:
- set the *min step* to `1m`

Having seconds is a bit confusing, let's compute by minute instead:
- multiply the query by 60s: `sum(rate(http_server_requests_seconds_count[1m]) * 60)`
- (optional) set the unit to *counts/minute (cpm)*

This *rate * 60* is actually the same as using the function `increase`, so let's do that:
- set the query to `sum(increase(http_server_requests_seconds_count[1m]))`

Now, it is nice, but we have read and write requests. Let's have one trace for each:
- add `by (method)` to the end of the query: `sum(increase(http_server_requests_seconds_count[1m])) by (method)`
- set the label to `{{method}}`

Finally, let's add some information to the graph:
- in legend, toggle *as table*, *to the right* and all the stats: *min*, *max*, *current*, etc.

**Stat panel**

Let's show which jobs are up.

Add a new panel and:
- set the query to `up`
- set the legend to `{{job}}`
- on *Display*, set text mode to *name*, color mode to *background*, graph mode to *none*, orientation to *horizontal*, 
  alignment mode to *center*
- on the field tab, change the threshold to have 0=red and 1=green
- set the title to *node status*