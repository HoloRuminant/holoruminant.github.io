#!/usr/bin/env ruby
# Checks that every URL and DOI in the data files still responds.
# Usage: ruby scripts/check_links.rb
# Exits non-zero if any link is broken. Some publishers block automated
# requests (HTTP 401, 403 or 429); those are reported as warnings only.
require "yaml"
require "date"
require "net/http"
require "uri"

ROOT = File.expand_path("..", __dir__)
tools = YAML.safe_load(File.read(File.join(ROOT, "_data/tools.yml")), permitted_classes: [Date])
contributors = YAML.safe_load(File.read(File.join(ROOT, "_data/contributors.yml")), permitted_classes: [Date])

links = [["Site", "https://holoruminant.eu"], ["Site", "https://cordis.europa.eu/project/id/101000213"]]
tools.each do |t|
  links << [t["name"], t["repo"]] if t["repo"]
  links << [t["name"], t["app_url"]] if t["app_url"]
  (t["papers"] || []).each do |p|
    links << [t["name"], "https://doi.org/#{p['doi']}"] if p["doi"]
    links << [t["name"], p["url"]] if p["url"]
  end
end
contributors.each do |c|
  links << [c["name"], "https://github.com/#{c['github']}"] if c["github"]
  links << [c["name"], "https://orcid.org/#{c['orcid']}"] if c["orcid"]
  links << [c["name"], c["website"]] if c["website"]
end

def fetch(url, limit = 10)
  return [nil, "too many redirects"] if limit.zero?
  uri = URI(url)
  Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 15, read_timeout: 20) do |http|
    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = "HoloRuminant-link-check (+https://holoruminant.github.io)"
    res = http.request(req)
    if res.is_a?(Net::HTTPRedirection) && res["location"]
      return fetch(URI.join(url, res["location"]).to_s, limit - 1)
    end
    [res.code.to_i, nil]
  end
rescue StandardError => e
  [nil, e.class.name]
end

broken = []
links.uniq.each do |owner, url|
  code, err = fetch(url)
  status =
    if code && code < 400 then "ok"
    elsif [401, 403, 429].include?(code) then "warn"
    else "FAIL"
    end
  puts format("%-5s %-4s %-28s %s", status, code || "-", owner[0, 28], url)
  broken << "#{owner}: #{url} (#{code || err})" if status == "FAIL"
end

if broken.empty?
  puts "\nAll links respond."
else
  warn "\nBroken links:\n  " + broken.join("\n  ")
  exit 1
end
