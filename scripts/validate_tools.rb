#!/usr/bin/env ruby
# Validates _data/tools.yml against the schema documented in README.md.
require "yaml"

FILE = File.expand_path("../_data/tools.yml", __dir__)
TYPES = ["Tool", "Workflow", "Pipeline", "R package", "Web app"].freeze
STATUSES = ["available", "restricted"].freeze
KINDS = ["publication", "preprint", "software", "in-preparation"].freeze

def blank?(v)
  v.nil? || v.to_s.strip.empty?
end

begin
  tools = YAML.safe_load(File.read(FILE))
rescue Psych::Exception => e
  abort "tools.yml is not valid YAML: #{e.message}"
end

abort "tools.yml must be a list of tools" unless tools.is_a?(Array)

errors = []
tools.each_with_index do |t, i|
  label = t.is_a?(Hash) && !blank?(t["name"]) ? t["name"] : "entry #{i + 1}"
  unless t.is_a?(Hash)
    errors << "#{label}: not a mapping"
    next
  end
  %w[name description type status].each do |f|
    errors << "#{label}: missing required field '#{f}'" if blank?(t[f])
  end
  errors << "#{label}: invalid type '#{t['type']}'" unless blank?(t["type"]) || TYPES.include?(t["type"])
  errors << "#{label}: invalid status '#{t['status']}'" unless blank?(t["status"]) || STATUSES.include?(t["status"])
  %w[repo app_url].each do |f|
    errors << "#{label}: '#{f}' must be an http(s) URL" unless blank?(t[f]) || t[f].to_s =~ %r{\Ahttps?://\S+\z}
  end
  errors << "#{label}: restricted tools must not have a repo or app_url" if t["status"] == "restricted" && (!blank?(t["repo"]) || !blank?(t["app_url"]))
  papers = t["papers"]
  next if papers.nil?
  unless papers.is_a?(Array)
    errors << "#{label}: 'papers' must be a list"
    next
  end
  papers.each_with_index do |p, j|
    pl = "#{label}, paper #{j + 1}"
    unless p.is_a?(Hash)
      errors << "#{pl}: not a mapping"
      next
    end
    errors << "#{pl}: missing 'label'" if blank?(p["label"])
    errors << "#{pl}: invalid kind '#{p['kind']}'" unless KINDS.include?(p["kind"])
    errors << "#{pl}: store the DOI without the https://doi.org/ prefix" if p["doi"].to_s =~ %r{\Ahttps?://|doi\.org}i
    errors << "#{pl}: 'url' must be an http(s) URL" unless blank?(p["url"]) || p["url"].to_s =~ %r{\Ahttps?://\S+\z}
  end
end

if errors.empty?
  puts "tools.yml OK (#{tools.size} tools)"
else
  warn errors.map { |e| "ERROR: #{e}" }
  exit 1
end
