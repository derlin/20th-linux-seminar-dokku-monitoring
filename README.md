# 20th Fribourg Linux Seminar - Lucy Linder's Talk Code

This repository contains the code and data used during my presentation 
*Deploying a real service to Dokku and monitoring it with Prometheus/Grafana* at the **20th Fribourg Linux Seminar**
on March, 2021.

You can find **the slides** here: **https://bit.ly/fribourg-linux-seminar-dokku-plus-monitoring**

## Dokku installation

The script `install.sh` installs the BBData API (with its two databases), and setup prometheus and grafana.

Prerequisites/Procedure:

0. Ensure you have ssh access to your dokku host, with a proper ssh key (no login prompt),
1. Ensure you set the proper `DOKKU_HOST`, `DOKKU_SSH` and `DOKKU_HOME_DIR` variables to match your dokku server,
2. Run the install script using `./install.sh 2>&1 | tee install.log`,
3. Done.

## What is deployed

After the script ran, you should have access to bbdata-api on the port 80 of your dokku host.
To access the other resources, find out the internal IP and subnet of your dokku host, 
and use *sshuttle* to create a bridge.
For example:
```bash
sshuttle --dns -r ubuntu@dokku-demo.gdgfribourg.ch:22 172.18.0.0/16
```

Then, you should be able to access:
* bbdata-api metrics on port `8111`, e.g. 172.18.0.1:8111
* prometheus on port `9090`, e.g. 172.18.0.1:9090
* grafana on port `3000`, e.g. 172.18.0.1:3000

## Datafaker

In order to test the Grafana dashboard, you need data. 
The python app `datafaker/datafaker.py` will generate read and write requests at a given interval.

To use it:
```bash
cd datafaker
# create virtualenv
python3 -m venv venv
source venv/bin/activate
pip install requests

# launch the script, with ~1 request/second
./datafaker.py -u <BB_API_BASE_URL> --interval 1.0
```

## Grafana

A summary of my demo with Grafana can be found in `grafana-demo.md`.

In `graf`, you'll find two dashboards:

* `cassandra-dashboard.json` comes from [Grafana Labs](https://grafana.com/grafana/dashboards/5408), 
   but contains some additional bugfixes (correct datasource);
* `bbdata-dashboard.json` is a custom-made dashboard specifically for BBData;

The [Spring Boot 2.1 Statistics](https://grafana.com/grafana/dashboards/10280) dashboard is also a very good dashboard
to import: `https://grafana.com/grafana/dashboards/10280`.