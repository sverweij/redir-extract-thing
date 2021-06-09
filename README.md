# redir-extract-thing

## What's this do?

It extracts redirects from an apache config & slaps them in a csv. Written
as a one-off - so it might not entirely fit your needs (also see notes below).

## Usage

```sh
node src/httpd-to-csv.js < your-conf.conf > your-flattened-redirects.csv
```

## Notes

- Written in ~2 hours to reliably and reproduceably extract redirects from a
pretty ginormous but specific redirect configuration. This means that
the parser cuts some corners so it parses _that_ config well. It also means the
parser at this time is probably not suitable for generic configs of the
same nature.

- It's also pretty free of automated tests a.t.m. so use at your own risk.
