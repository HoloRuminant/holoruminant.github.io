#!/usr/bin/env ruby
# Validates _data/tools.yml and _data/contributors.yml against the schema in README.md.
# Usage: ruby scripts/validate_data.rb
require "yaml"
require "date"

ROOT = File.expand_path("..", __dir__)
TYPES = ["Tool", "Workflow", "Pipeline", "R package", "Web app"].freeze
STATUSES = ["available", "restricted"].freeze
KINDS = ["publication", "preprint", "software", "in-preparation"].freeze
URL = %r{\Ahttps?://\S+\z}

def blank?(v)
  v.nil? || v.to_s.strip.empty?
end

def load(name)
  path = File.join(ROOT, "_data", name)
  data = YAML.safe_load(File.read(path), permitted_classes: [Date])
  abort "#{name} must be a list" unless data.is_a?(Array)
  data
rescue Psych::Exception => e
  abort "#{name} is not valid YAML: #{e.message}"
end

errors = []
tools = load("tools.yml")
contributors = load("contributors.yml")

# Tools
names = []
tools.each_with_index do |t, i|
  unless t.is_a?(Hash)
    errors << "tools.yml entry #{i + 1}: not a mapping"
    next
  end
  label = blank?(t["name"]) ? "tools.yml entry #{i + 1}" : t["name"]
  %w[name description type status].each do |f|
    errors << "#{label}: missing required field '#{f}'" if blank?(t[f])
  end
  errors << "#{label}: duplicate tool name" if names.include?(t["name"])
  names << t["name"]
  errors << "#{label}: invalid type '#{t['type']}'" unless blank?(t["type"]) || TYPES.include?(t["type"])
  errors << "#{label}: invalid status '#{t['status']}'" unless blank?(t["status"]) || STATUSES.include?(t["status"])
  %w[repo app_url].each do |f|
    errors << "#{label}: '#{f}' must be an http(s) URL" unless blank?(t[f]) || t[f].to_s =~ URL
  end
  if t["status"] == "restricted" && (!blank?(t["repo"]) || !blank?(t["app_url"]))
    errors << "#{label}: restricted tools must not have a repo or app_url"
  end

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
    errors << "#{pl}: DOI should start with '10.'" unless blank?(p["doi"]) || p["doi"].to_s.start_with?("10.")
    errors << "#{pl}: 'url' must be an http(s) URL" unless blank?(p["url"]) || p["url"].to_s =~ URL
  end
end

# Contributors
people = []
contributors.each_with_index do |c, i|
  unless c.is_a?(Hash)
    errors << "contributors.yml entry #{i + 1}: not a mapping"
    next
  end
  label = blank?(c["name"]) ? "contributors.yml entry #{i + 1}" : c["name"]
  %w[name institute].each do |f|
    errors << "#{label}: missing required field '#{f}'" if blank?(c[f])
  end
  errors << "#{label}: duplicate contributor name" if people.include?(c["name"])
  people << c["name"]
  unless blank?(c["github"]) || c["github"].to_s =~ /\A[A-Za-z0-9][A-Za-z0-9-]{0,38}\z/
    errors << "#{label}: 'github' must be a GitHub username only, not a URL"
  end
  unless blank?(c["orcid"]) || c["orcid"].to_s =~ /\A\d{4}-\d{4}-\d{4}-\d{3}[\dX]\z/
    errors << "#{label}: 'orcid' must look like 0000-0002-1825-0097 (no URL)"
  end
  errors << "#{label}: 'website' must be an http(s) URL" unless blank?(c["website"]) || c["website"].to_s =~ URL
  unless blank?(c["photo"]) || File.exist?(File.join(ROOT, "assets/img/contributors", c["photo"].to_s))
    errors << "#{label}: photo '#{c['photo']}' not found in assets/img/contributors/"
  end
  next if c["tools"].nil?
  unless c["tools"].is_a?(Array)
    errors << "#{label}: 'tools' must be a list"
    next
  end
  c["tools"].each do |tn|
    errors << "#{label}: tool '#{tn}' is not in tools.yml (check the spelling)" unless names.include?(tn)
  end
end

if errors.empty?
  puts "Data OK (#{tools.size} tools, #{contributors.size} contributors)"
else
  warn errors.map { |e| "ERROR: #{e}" }
  exit 1
end
